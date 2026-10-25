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
          -- Same pills as the tmux bar: the mode/location (a/z) in the session
          -- pill's colour, the info pills (b/y) in the directory pill's blue,
          -- and the middle (c, and x which reuses it) transparent.
          normal = {
            a = { fg = c.bg_dark, bg = c.green, gui = 'bold' },
            b = { fg = c.bg_dark, bg = c.blue },
            c = { fg = c.fg_dark, bg = 'NONE' },
          },
          -- Green is now normal mode's, and blue the info pills', so insert and
          -- command take yellow and orange to stay distinct.
          insert = { a = { fg = c.bg_dark, bg = c.yellow, gui = 'bold' } },
          visual = { a = { fg = c.bg_dark, bg = c.magenta, gui = 'bold' } },
          replace = { a = { fg = c.bg_dark, bg = c.red, gui = 'bold' } },
          command = { a = { fg = c.bg_dark, bg = c.orange, gui = 'bold' } },
          inactive = {
            a = { fg = c.fg_dark, bg = c.bg_highlight },
            b = { fg = c.comment, bg = c.bg_highlight },
            c = { fg = c.comment, bg = 'NONE' },
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
        lualine_a = { { 'mode', separator = { left = '', right = '' }, right_padding = 2 } },
        -- ( mode ) info ) on the left and ( info ( location ) on the right,
        -- like the tmux bar's pills; plugin status sits on the bar between.
        -- A component's separator option replaces both of its sides, so the
        -- mode and location name their inner joins as well as their outer ends.
        lualine_b = { 'branch', 'diff', 'diagnostics', 'filename', 'filesize' },
        lualine_c = {},
        lualine_x = { require('codex').status(), require('easy-dotnet.ui-modules.jobs').lualine },
        lualine_y = { 'encoding', 'progress' },
        lualine_z = { { custom_location, separator = { left = '', right = '' }, left_padding = 2 } },
      }

      opts.inactive_sections = {
        lualine_a = { { 'filename', separator = { left = '', right = '' }, right_padding = 2 } },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = { { custom_location, separator = { left = '', right = '' }, left_padding = 2 } },
      }

      opts.tabline = opts.tabline or {}
      opts.winbar = opts.winbar or {}
      opts.inactive_winbar = opts.inactive_winbar or {}
      opts.extensions = opts.extensions or {}

      table.insert(opts.sections.lualine_x, require('snacks.profiler').status())
    end,
  },
}
