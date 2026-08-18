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
      -- ToggleTerm needs editor-style terminal keys, not Zsh's vi keymaps.
      -- This reaches only the child process created by ToggleTerm.
      env = {
        DISABLE_TERM_VIM_MODE = '1',
      },
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
