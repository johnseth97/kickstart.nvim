return {
  {
    'nvim-lualine/lualine.nvim',
    event = 'BufReadPost',
    opts = function(_, opts)
      local capsule_theme = {
        normal = {
          a = { fg = '#1e2030', bg = '#7aa2f7', gui = 'bold' },
          b = { fg = '#c0caf5', bg = '#3b4261' },
          c = { fg = '#828bb8' },
        },
        insert = { a = { fg = '#1e2030', bg = '#9ece6a', gui = 'bold' } },
        visual = { a = { fg = '#1e2030', bg = '#bb9af7', gui = 'bold' } },
        replace = { a = { fg = '#1e2030', bg = '#f7768e', gui = 'bold' } },
        command = { a = { fg = '#1e2030', bg = '#e0af68', gui = 'bold' } },
        inactive = {
          a = { fg = '#828bb8', bg = '#292e42' },
          b = { fg = '#565f89', bg = '#292e42' },
          c = { fg = '#565f89' },
        },
      }

      local function custom_location()
        local line = tonumber(vim.fn.line '.') or 0
        local total_lines = tonumber(vim.fn.line '$') or 0
        local col = tonumber(vim.fn.col '.') or 0
        local total_cols = (tonumber(vim.fn.col '$') or 1) - 1
        return string.format('[%d/%d] %d:%d', line, total_lines, col, total_cols)
      end

      opts.options = {
        icons_enabled = true,
        theme = capsule_theme,
        component_separators = '',
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          -- Agentic needs the winbar, while lualine provides its visible footers.
          -- Disabling both leaves Neovim's bare, black default statuslines behind.
          statusline = {},
          winbar = { 'AgenticChat', 'AgenticInput', 'AgenticCode', 'AgenticFiles', 'AgenticDiagnostics', 'AgenticTodos' },
        },
        ignore_focus = {},
        always_divide_middle = true,
        always_show_tabline = true,
        globalstatus = false,
        refresh = {
          statusline = 100,
          tabline = 100,
          winbar = 100,
        },
        disabled_winbar_filetypes = {
          statusline = { 'NvimTree_1', 'lazy', 'help' },
          winbar = {},
        },
      }

      opts.sections = {
        lualine_a = { { 'mode', separator = { left = '' }, right_padding = 2 } },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { 'filename', 'filesize' },
        lualine_x = { 'encoding', require('codex').status(), require('easy-dotnet.ui-modules.jobs').lualine },
        lualine_y = { 'progress' },
        lualine_z = { { custom_location, separator = { right = '' }, left_padding = 2 } },
      }

      opts.inactive_sections = {
        lualine_a = { { 'filename', separator = { left = '' }, right_padding = 2 } },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = { { custom_location, separator = { right = '' }, left_padding = 2 } },
      }

      opts.tabline = opts.tabline or {}
      opts.winbar = opts.winbar or {}
      opts.inactive_winbar = opts.inactive_winbar or {}
      opts.extensions = opts.extensions or {}

      table.insert(opts.sections.lualine_x, require('snacks.profiler').status())
    end,
  },
}
