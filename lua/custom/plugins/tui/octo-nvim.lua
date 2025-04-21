return {
  'pwntester/octo.nvim',
  requires = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    -- OR 'ibhagwan/fzf-lua',
    -- OR 'folke/snacks.nvim',
    'nvim-tree/nvim-web-devicons',
  },
  keys = {
    { '<leader>go', '<cmd>Octo<CR>', desc = '🐙 [g]ithub [o]cto' },
  },
  config = function()
    require('octo').setup()
  end,
}
