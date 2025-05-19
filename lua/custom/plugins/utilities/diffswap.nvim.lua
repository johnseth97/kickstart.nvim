return {
  'johnseth97/diffswap.nvim',
  dir = '~/src/Lua/diffswap.nvim/',
  as = 'diffswap.nvim',
  lazy = false,
  opts = {}, -- optional config
  config = function(_, opts)
    require('diffswap.config').setup(opts)
  end,
}
