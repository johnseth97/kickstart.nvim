-- lua/custom/plugins/tui/bufferline-nvim.lua
return {
  'akinsho/bufferline.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons', 'folke/tokyonight.nvim' },
  event = 'BufReadPost',
  opts = function()
    -- pull theme-provided highlights (respects transparent=true)
    local ok, integ = pcall(require, 'tokyonight.groups.integrations.bufferline')
    local highlights = ok and integ.get()
      or {
        -- fallback: force transparent if integration not found
        fill = { bg = 'NONE' },
        background = { bg = 'NONE' },
        separator = { fg = 'NONE', bg = 'NONE' },
        separator_visible = { fg = 'NONE', bg = 'NONE' },
        separator_selected = { fg = 'NONE', bg = 'NONE' },
        buffer_selected = { bg = 'NONE', bold = true },
        indicator_selected = { bg = 'NONE' },
        modified = { bg = 'NONE' },
        modified_selected = { bg = 'NONE' },
        close_button = { bg = 'NONE' },
        close_button_selected = { bg = 'NONE' },
      }

    return {
      options = {
        style_preset = require('bufferline').style_preset.minimal,
        always_show_bufferline = true,
        show_bufferline_when_empty = true,
      },
      highlights = {
        fill = { bg = 'NONE' },
        background = { bg = 'NONE' },
        tab = { bg = 'NONE' },
        tab_selected = { bg = 'NONE' },
        tab_close = { bg = 'NONE' },
        close_button = { bg = 'NONE' },
        close_button_visible = { bg = 'NONE' },
        close_button_selected = { bg = 'NONE' },
        buffer_visible = { bg = 'NONE' },
        buffer_selected = { bg = 'NONE' },
        separator = { bg = 'NONE' },
        separator_selected = { bg = 'NONE' },
        separator_visible = { bg = 'NONE' },
        modified = { bg = 'NONE' },
        modified_visible = { bg = 'NONE' },
        modified_selected = { bg = 'NONE' },
      },
    }
  end,
}
