return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- Add your options here
    -- Example: enable profiler
    profiler = { enabled = true },
    dim = { enabled = true },
    scratch = { enabled = true },
    statuscolumn = { enabled = true },
    scroll = { enabled = true },
    scope = { enabled = true },
    -- Directory startup remains an explicit file picker; the normal explorer
    -- keys below open Snacks' persistent sidebar.
    explorer = { enabled = true, replace_netrw = false },
    -- Route vim.notify through Snacks so Agentic lifecycle hooks are visible
    -- even while working in another split or tab.
    notifier = {
      enabled = true,
      timeout = 5000,
      style = 'fancy',
    },
    -- Agentic delegates provider/model/session selectors to Snacks' vim.ui.select.
    -- Keep its normal-mode list movement aligned with the j/k/l/; layout while
    -- leaving insert-mode search text completely untouched.
    picker = {
      sources = {
        projects = {
          dev = { '~/src' },
          projects = {
            '~/.dotfiles',
            '~/.dotfiles/common/.config/nvim',
          },
          patterns = { '.git' },
          max_depth = 3,
        },
      },
      win = {
        input = {
          keys = {
            ['<C-h>'] = { 'toggle_hidden', mode = { 'n', 'i' } },
            ['<C-i>'] = { 'toggle_ignored', mode = { 'n', 'i' } },
            ['j'] = false,
            ['k'] = 'list_down',
            ['l'] = 'list_up',
            [';'] = false,
          },
        },
        list = {
          keys = {
            ['<C-h>'] = 'toggle_hidden',
            ['<C-i>'] = 'toggle_ignored',
            ['j'] = false,
            ['k'] = 'list_down',
            ['l'] = 'list_up',
            [';'] = false,
          },
        },
      },
    },
  },
  keys = {
    {
      '<leader>sf',
      function()
        Snacks.picker.files()
      end,
      desc = '[S]earch [F]iles',
    },
    {
      '<leader>sg',
      function()
        Snacks.picker.grep()
      end,
      desc = '[S]earch by [G]rep',
    },
    {
      '<leader>sh',
      function()
        Snacks.picker.help()
      end,
      desc = '[S]earch [H]elp',
    },
    {
      '<leader>sk',
      function()
        Snacks.picker.keymaps()
      end,
      desc = '[S]earch [K]eymaps',
    },
    {
      '<leader>ss',
      function()
        Snacks.picker.lsp_symbols()
      end,
      desc = '[S]earch document [S]ymbols',
    },
    {
      '<leader>sS',
      function()
        Snacks.picker.lsp_workspace_symbols()
      end,
      desc = '[S]earch workspace [S]ymbols',
    },
    {
      '<leader>sP',
      function()
        Snacks.picker.pickers()
      end,
      desc = '[S]earch [P]ickers',
    },
    {
      '<leader>sw',
      function()
        Snacks.picker.grep_word()
      end,
      mode = { 'n', 'x' },
      desc = '[S]earch current [W]ord',
    },
    {
      '<leader>sd',
      function()
        Snacks.picker.diagnostics()
      end,
      desc = '[S]earch [D]iagnostics',
    },
    {
      '<leader>sr',
      function()
        Snacks.picker.resume()
      end,
      desc = '[S]earch [R]esume',
    },
    {
      '<leader>s.',
      function()
        Snacks.picker.recent()
      end,
      desc = '[S]earch Recent Files',
    },
    {
      '<leader><leader>',
      function()
        Snacks.picker.buffers()
      end,
      desc = '[ ] Find existing buffers',
    },
    {
      '<leader>/',
      function()
        Snacks.picker.lines()
      end,
      desc = '[/] Fuzzily search in current buffer',
    },
    {
      '<leader>s/',
      function()
        Snacks.picker.grep_buffers()
      end,
      desc = '[S]earch [/] in Open Files',
    },
    {
      '<leader>sn',
      function()
        Snacks.picker.files { cwd = vim.fn.stdpath 'config' }
      end,
      desc = '[S]earch [N]eovim files',
    },
    {
      '<leader>sc',
      function()
        Snacks.picker.files { cwd = vim.fn.expand '~/.dotfiles', hidden = true }
      end,
      desc = '[S]earch Dotfiles/[C]onfig',
    },
    {
      '<leader>gl',
      function()
        Snacks.picker.git_log()
      end,
      desc = '[G]it [L]og',
    },
    {
      '<leader>gf',
      function()
        Snacks.picker.git_log_file()
      end,
      desc = '[G]it history for [F]ile',
    },
    {
      '<leader>gL',
      function()
        Snacks.picker.git_log_line()
      end,
      desc = '[G]it history for [L]ine',
    },
    {
      '\\',
      function()
        require('custom.window').toggle_explorer()
      end,
      desc = 'Toggle Explorer',
    },
    {
      '<leader>e',
      function()
        require('custom.window').toggle_explorer()
      end,
      desc = 'File [E]xplorer',
    },
    { -- snacks.profiler
      '<leader>pp',
      function()
        Snacks.profiler.toggle()
      end,
    },
    {
      '<leader>ph',
      function()
        Snacks.profiler.toggle_highlights()
      end,
      desc = 'Profiler Highlights',
    },
    {
      '<leader>.',
      function()
        Snacks.scratch()
      end,
      desc = 'Toggle Scratch Buffer',
    },
    {
      '<leader>S',
      function()
        Snacks.scratch.select()
      end,
      desc = 'Select Scratch Buffer',
    },
  },
  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create some toggle mappings
        Snacks.toggle.option('spell', { name = 'Spelling' }):map '<leader>us'
        Snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>uw'
        Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map '<leader>uL'
        Snacks.toggle.diagnostics():map '<leader>ud'
        Snacks.toggle.line_number():map '<leader>ul'
        Snacks.toggle.option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map '<leader>uc'
        Snacks.toggle.treesitter():map '<leader>uT'
        Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):map '<leader>ub'
        Snacks.toggle.inlay_hints():map '<leader>uh'
        Snacks.toggle.indent():map '<leader>ug'
        Snacks.toggle.dim():map '<leader>uD'
      end,
    })
  end,
}
