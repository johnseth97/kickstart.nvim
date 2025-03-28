return { -- Terminal Splits
  'akinsho/toggleterm.nvim',
  version = '*',
  keys = {
    { '<leader>T', ':ToggleTerm<CR>', { silent = true }, desc = '[T]oggle terminal' },
  },
  config = function()
    require('toggleterm').setup {
      direction = 'horizontal',
      start_in_insert = true,
    }

    -- load the helper
    local util = require 'helpers.util'

    -- Dynamic binding: smart toggle with function
    vim.keymap.set({ 'n', 't' }, '||', util.smart_toggle_term, {
      noremap = true,
      silent = true,
      desc = 'Smart [T]erminal toggle',
    })
  end,
}
