return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles' },
  keys = {
    { '<leader>do', '<cmd>DiffviewOpen<cr>', desc = 'Diffview Open' },
    { '<leader>dc', '<cmd>DiffviewClose<cr>', desc = 'Diffview Close' },
    { '<leader>dt', '<cmd>DiffviewToggle<cr>', desc = 'Diffview Toggle Files' },
  },
  config = function()
    require('diffview').setup()
  end,
}
