-- lua/custom/plugins/tui/bufferline-nvim.lua
return {
  'akinsho/bufferline.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  -- fire this right after UIEnter, once all the core startup is done
  event = 'VeryLazy',

  -- all of your `setup { … }` table goes here
  opts = function()
    -- make sure termguicolors is set before bufferline draws
    vim.opt.termguicolors = true

    local cp = require('catppuccin.palettes').get_palette 'macchiato'
    return {
      options = {
        -- your other options…
        style_preset = require('bufferline').style_preset.minimal,
        numbers = function(o)
          return string.format('%s', o.ordinal) .. ' '
        end,
        always_show_bufferline = true,
        show_bufferline_when_empty = true,
      },
      highlights = {
        fill = { bg = cp.mantle },
        background = { bg = cp.mantle, fg = cp.surface1 },
        buffer_selected = { fg = cp.green, bg = cp.base, bold = true },
        indicator_selected = { fg = cp.green, bg = cp.base },
        numbers = { fg = cp.peach, bg = cp.mantle },
        numbers_selected = { fg = cp.green, bg = cp.base, bold = true },
        separator = { fg = cp.mantle, bg = cp.mantle },
        separator_visible = { fg = cp.mantle, bg = cp.mantle },
        separator_selected = { fg = cp.base, bg = cp.base },
        close_button = { fg = cp.mantle, bg = cp.mantle },
        close_button_visible = { fg = cp.mantle, bg = cp.mantle },
        close_button_selected = { fg = cp.base, bg = cp.base },
        modified = { fg = cp.peach, bg = cp.mantle },
        modified_selected = { fg = cp.green, bg = cp.base },
        duplicate = { fg = cp.overlay0, bg = cp.mantle, italic = true },
        duplicate_selected = { fg = cp.green, bg = cp.base, italic = true },
      },
    }
  end,
} -- lua/custom/plugins/tui/bufferline-nvim.lua
