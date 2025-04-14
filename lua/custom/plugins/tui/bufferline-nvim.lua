return {
  'akinsho/bufferline.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  lazy = false,
  version = '*',
  config = function()
    vim.opt.termguicolors = true
    local cp = require('catppuccin.palettes').get_palette 'macchiato'

    require('bufferline').setup {
      options = {
        style_preset = require('bufferline').style_preset.minimal,
        numbers = function(opts)
          return string.format('%s', opts.ordinal) .. ' '
        end,
      },
      highlights = {
        fill = {
          bg = cp.mantle,
        },
        background = {
          bg = cp.mantle,
          fg = cp.surface1,
        },
        buffer_selected = {
          fg = cp.green,
          bg = cp.base,
          bold = true,
        },
        indicator_selected = {
          fg = cp.green,
          bg = cp.base,
        },
        numbers = {
          fg = cp.peach,
          bg = cp.mantle,
        },
        numbers_selected = {
          fg = cp.green,
          bg = cp.base,
          bold = true,
        },
        separator = {
          fg = cp.mantle,
          bg = cp.mantle,
        },
        separator_visible = {
          fg = cp.mantle,
          bg = cp.mantle,
        },
        separator_selected = {
          fg = cp.base,
          bg = cp.base,
        },
        close_button = {
          fg = cp.mantle,
          bg = cp.mantle,
        },
        close_button_visible = {
          fg = cp.mantle,
          bg = cp.mantle,
        },
        close_button_selected = {
          fg = cp.base,
          bg = cp.base,
        },
        modified = {
          fg = cp.peach,
          bg = cp.mantle,
        },
        modified_selected = {
          fg = cp.green,
          bg = cp.base,
        },
        duplicate = {
          fg = cp.overlay0,
          bg = cp.mantle,
          italic = true,
        },
        duplicate_selected = {
          fg = cp.green,
          bg = cp.base,
          italic = true,
        },
      },
    }

    -- Ordinal nav keymaps on <C-b>1–9
    for i = 1, 9 do
      vim.keymap.set('n', ('<C-b>%d'):format(i), function()
        require('bufferline.commands').go_to(i)
      end, { desc = 'Go to buffer ' .. i })
    end
    vim.keymap.set('n', '<C-b>0', function()
      require('bufferline.commands').go_to(10)
    end, { desc = 'Go to buffer 10' })

    -- Close current buffer with <C-b><C-c>
    vim.keymap.set('n', '<C-b>x', '<cmd>bdelete<CR>', { desc = 'Close current buffer' })
  end,
}
