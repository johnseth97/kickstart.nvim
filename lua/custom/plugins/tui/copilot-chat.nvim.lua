-- copilot-chat.nvim
return {
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'github/copilot.vim' }, -- keep inline completions
      { 'nvim-lua/plenary.nvim', branch = 'master' },
      { 'nvim-telescope/telescope.nvim', optional = true }, -- nice to have
    },
    build = 'make tiktoken', -- macOS/Linux
    -- keep your quick toggle
    keys = {
      {
        '<leader>cc',
        function()
          require('CopilotChat').toggle()
        end,
        desc = 'Toggle [c]opilot [c]hat popup',
      },
    },
    opts = {
      {
        -- ---- your settings preserved ----
        system_prompt = 'COPILOT_INSTRUCTIONS',
        model = 'gpt-4o',
        agent = 'copilot',
        context = nil,
        sticky = nil,
        temperature = 0.1,
        headless = false,
        stream = nil,
        callback = nil,
        remember_as_sticky = true,
        window = {
          layout = 'float',
          width = 0.5,
          height = 0.8,
          relative = 'editor',
          border = 'single',
          title = 'Copilot Chat',
          zindex = 1,
        },
        show_help = true,
        highlight_selection = true,
        highlight_headers = true,
        references_display = 'virtual',
        auto_follow_cursor = true,
        auto_insert_mode = false,
        insert_at_end = false,
        clear_chat_on_new_prompt = false,
        debug = false,
        log_level = 'info',
        proxy = nil,
        allow_insecure = false,
        chat_autocomplete = true,
        log_path = vim.fn.stdpath 'state' .. '/CopilotChat.log',
        history_path = vim.fn.stdpath 'data' .. '/copilotchat_history',
        question_header = '# User ',
        answer_header = '# Copilot ',
        error_header = '# Error ',
        separator = '───',
        providers = { copilot = {}, github_models = {}, copilot_embeddings = {} },
        contexts = {
          buffer = {},
          buffers = {},
          file = {},
          files = {},
          git = {},
          url = {},
          register = {},
          quickfix = {},
          system = {},
        },
        prompts = {
          Explain = { prompt = 'Write an explanation for the selected code as paragraphs of text.', system_prompt = 'COPILOT_EXPLAIN' },
          Review = { prompt = 'Review the selected code.', system_prompt = 'COPILOT_REVIEW' },
          Fix = {
            prompt = 'There is a problem in this code. Identify the issues and rewrite the code with fixes. Explain what was wrong and how your changes address the problems.',
          },
          Optimize = {
            prompt = 'Optimize the selected code to improve performance and readability. Explain your optimization strategy and the benefits of your changes.',
          },
          Docs = { prompt = 'Please add documentation comments to the selected code.' },
          Tests = { prompt = 'Please generate tests for my code.' },
          Commit = {
            prompt = 'Write commit message for the change with commitizen convention. Keep the title under 50 characters and wrap message at 72 characters. Format as a gitcommit code block.',
            context = 'git:staged',
          },
        },
        mappings = {
          complete = { insert = '<Tab>' },
          close = { normal = 'q', insert = '<C-c>' },
          reset = { normal = '<C-l>', insert = '<C-l>' },
          submit_prompt = { normal = '<CR>', insert = '<C-s>' },
          toggle_sticky = { normal = 'grr' },
          clear_stickies = { normal = 'grx' },
          accept_diff = { normal = '<C-y>', insert = '<C-y>' },
          jump_to_diff = { normal = 'gj' },
          quickfix_answers = { normal = 'gqa' },
          quickfix_diffs = { normal = 'gqd' },
          yank_diff = { normal = 'gy', register = '"' },
          show_diff = { normal = 'gd', full_diff = false },
          show_info = { normal = 'gi' },
          show_context = { normal = 'gc' },
          show_help = { normal = 'gh' },
        },
      },
    },
    config = function(_, opts)
      local chat = require 'CopilotChat'
      chat.setup(opts)

      local select_ctx = require 'CopilotChat.select'

      -- Find the “best” terminal buffer without changing focus
      local function find_terminal_buf()
        local cur = vim.api.nvim_get_current_buf()
        if vim.bo[cur].buftype == 'terminal' then
          return cur
        end

        -- Prefer a terminal in the current tabpage
        local wins = vim.api.nvim_tabpage_list_wins(0)
        for _, win in ipairs(wins) do
          local b = vim.api.nvim_win_get_buf(win)
          if vim.bo[b].buftype == 'terminal' then
            return b
          end
        end

        -- Otherwise, pick the most recently used terminal buffer globally
        local choice, last = nil, -1
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buftype == 'terminal' then
            local info = vim.fn.getbufinfo(b)[1]
            if info and info.lastused and info.lastused > last then
              last = info.lastused
              choice = b
            end
          end
        end
        return choice
      end

      local function read_terminal_output(bufnr, max_lines)
        if not bufnr or not vim.api.nvim_buf_is_loaded(bufnr) then
          return nil, 'No terminal buffer found.'
        end
        local total = vim.api.nvim_buf_line_count(bufnr)
        local start = math.max(0, total - (max_lines or 200))
        local lines = vim.api.nvim_buf_get_lines(bufnr, start, total, false)
        if #lines == 0 then
          return 'Terminal buffer is empty.'
        end
        return table.concat(lines, '\n')
      end

      -- ---------- context helpers ----------
      local function diag_text_for_buf(bufnr)
        local diags = vim.diagnostic.get(bufnr)
        if #diags == 0 then
          return 'No diagnostics.'
        end
        local name = vim.api.nvim_buf_get_name(bufnr)
        local out = { ('Diagnostics for %s'):format(name), '' }
        for _, d in ipairs(diags) do
          local sev = (vim.diagnostic.severity[d.severity] or d.severity)
          local pos = ('%d:%d'):format(d.lnum + 1, (d.col or 0) + 1)
          table.insert(out, ('[%s] %s %s'):format(sev, pos, (d.message or ''):gsub('\n', ' ')))
        end
        return table.concat(out, '\n')
      end

      local function quickfix_text()
        local qf = vim.fn.getqflist { items = 0, title = 0 }
        if not qf.items or #qf.items == 0 then
          return 'Quickfix list is empty.'
        end
        local out = { ('Quickfix: %s'):format(qf.title or ''), '' }
        for _, it in ipairs(qf.items) do
          local file = it.bufnr and vim.api.nvim_buf_get_name(it.bufnr) or it.filename or ''
          local lnum, col = it.lnum or 0, it.col or 0
          local text = it.text or ''
          table.insert(out, ('%s:%d:%d %s'):format(file, lnum, col, text))
        end
        return table.concat(out, '\n')
      end

      local function ask_about_latest_terminal()
        local term_buf = find_terminal_buf()
        local text, err = read_terminal_output(term_buf, 200)
        if not text and err then
          vim.notify(err, vim.log.levels.WARN)
          return
        end
        chat.ask(('This is recent terminal output. Explain the failure and propose a fix:\n\n```\n%s\n```'):format(text))
      end

      -- Works from normal mode
      vim.keymap.set('n', '<leader>aT', ask_about_latest_terminal, { desc = 'AI: Ask about recent terminal output' })
      -- Works from terminal mode (no need to leave insert/terminal mode)
      vim.keymap.set('t', '<leader>aT', ask_about_latest_terminal, { desc = 'AI: Ask about recent terminal output' })

      local function current_file_git_diff()
        local file = vim.fn.expand '%:p'
        if file == '' then
          return 'No file.'
        end
        local cmd = { 'git', 'diff', '--unified=0', '--', file }
        local res = vim.fn.systemlist(cmd)
        if vim.v.shell_error ~= 0 or #res == 0 then
          return 'No diff or git error.'
        end
        return table.concat(res, '\n')
      end

      -- ---------- keymaps (VSCode-like agent UX) ----------
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { desc = 'AI: ' .. desc })
      end

      -- Chat open / toggle (you already had <leader>cc)
      map('n', '<leader>aC', function()
        chat.toggle()
      end, 'Toggle Chat')

      -- Visual selection flows
      map('v', '<leader>aa', function()
        chat.ask('Answer questions about this selection:', { selection = select_ctx.visual })
      end, 'Ask about selection')

      map('v', '<leader>ae', function()
        vim.cmd 'CopilotChatExplain'
      end, 'Explain selection')
      map('v', '<leader>ar', function()
        vim.cmd 'CopilotChatFix'
      end, 'Refactor / fix selection')
      map('v', '<leader>at', function()
        vim.cmd 'CopilotChatTests'
      end, 'Generate tests for selection')

      -- File-wide
      map('n', '<leader>af', function()
        chat.ask('Answer questions about this file:', { selection = select_ctx.buffer })
      end, 'Ask about current file')

      -- Diagnostics of current buffer
      map('n', '<leader>ad', function()
        local text = diag_text_for_buf(0)
        chat.ask(('Given these diagnostics, propose a minimal fix as a patch:\n\n%s'):format(text))
      end, 'Ask about diagnostics (buffer)')

      -- Quickfix list (e.g., grep/lint results)
      map('n', '<leader>aq', function()
        local text = quickfix_text()
        chat.ask(('Given this quickfix list, propose fixes or a prioritized plan:\n\n%s'):format(text))
      end, 'Ask about quickfix list')

      -- Git diff for current file
      map('n', '<leader>ag', function()
        local diff = current_file_git_diff()
        chat.ask(('Here is the git diff for this file. Review and suggest improvements or fixes:\n\n%s'):format(diff))
      end, 'Ask about current file git diff')

      -- Apply last patch from chat
      map('n', '<leader>aA', function()
        chat.apply()
      end, 'Apply last AI patch')
    end,
  },
}
