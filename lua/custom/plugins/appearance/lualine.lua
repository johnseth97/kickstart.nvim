return {
  {
    'nvim-lualine/lualine.nvim',
    lazy = false,
    opts = function(_, opts)
      local function custom_location()
        local line = tonumber(vim.fn.line '.') or 0
        local total_lines = tonumber(vim.fn.line '$') or 0
        local col = tonumber(vim.fn.col '.') or 0
        local total_cols = (tonumber(vim.fn.col '$') or 1) - 1

        return string.format('[%d/%d] %d:%d', line, total_lines, col, total_cols)
      end
      -- Set up default options for lualine
      opts.options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = ' ', right = ' ' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
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

      -- Define active sections
      opts.sections = opts.sections
        or {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { 'filename', 'filesize' },
          lualine_x = { 'encoding' },
          lualine_y = { 'progress' },
          lualine_z = { custom_location },
        }

      -- Define inactive sections
      opts.inactive_sections = opts.inactive_sections
        or {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { 'filename' },
          lualine_x = { custom_location },
          lualine_y = {},
          lualine_z = {},
        }

      -- Define tabline and winbar sections
      opts.tabline = opts.tabline or {}
      opts.winbar = opts.winbar or {}
      opts.inactive_winbar = opts.inactive_winbar or {}
      opts.extensions = opts.extensions or {}

      -- Add the Snacks profiler status to the `lualine_x` section
      table.insert(opts.sections.lualine_x, require('snacks.profiler').status())
    end,
  },
}
