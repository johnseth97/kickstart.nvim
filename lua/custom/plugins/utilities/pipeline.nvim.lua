return {
  'topaxi/pipeline.nvim',
  cmd = { 'Pipeline' },
  keys = {
    { '<leader>ga', '<cmd>Pipeline<cr>', desc = '[g]ithub [a]ctions status via pipeline.nvim' },
  },
  -- optional, you can also install and use `yq` instead.
  build = 'make',
  opts = {},
}
