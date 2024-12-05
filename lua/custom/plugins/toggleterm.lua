return { -- Terminal Splits
  'akinsho/toggleterm.nvim',
  version = '*',
  config = true,
  keys = {
    { '<leader>T', ':ToggleTerm<CR>', { silent = true }, desc = '[T]oggle terminal' },
  },
}
