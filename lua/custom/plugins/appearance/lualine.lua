return {
  {
    'nvim-lualine/lualine.nvim',
    cond = not vim.g.dotfiles_mail_mode,
    event = 'BufReadPost',
    opts = function(_, opts)
      -- A function, so lualine rebuilds it on every ColorScheme and the
      -- capsules follow Omarchy theme switches.
      local function capsule_theme()
        local c = require('custom.omarchy_theme').colors()
        return {
          normal = {
            a = { fg = c.bg_dark, bg = c.blue, gui = 'bold' },
            b = { fg = c.fg, bg = c.fg_gutter },
            -- Fill the middle (c, and x which reuses it) with the section shade,
            -- like the tmux status bar, instead of StatusLine's near-black.
            c = { fg = c.fg_dark, bg = c.fg_gutter },
          },
          insert = { a = { fg = c.bg_dark, bg = c.green, gui = 'bold' } },
          visual = { a = { fg = c.bg_dark, bg = c.magenta, gui = 'bold' } },
          replace = { a = { fg = c.bg_dark, bg = c.red, gui = 'bold' } },
          command = { a = { fg = c.bg_dark, bg = c.yellow, gui = 'bold' } },
          inactive = {
            a = { fg = c.fg_dark, bg = c.bg_highlight },
            b = { fg = c.comment, bg = c.bg_highlight },
            c = { fg = c.comment, bg = c.fg_gutter },
          },
        }
      end

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
