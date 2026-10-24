return {
  'knownasnaffy/himalaya.nvim',
  -- The README lags the v2 implementation. Review adapters before updating.
  commit = 'e20f70b51dbb61db4eb33872317e7a8d1f99a0e6',
  cmd = 'Himalaya',
  dependencies = { 'MunifTanjim/nui.nvim', 'folke/snacks.nvim' },
  keys = {
    {
      '<leader>om',
      function()
        require('custom.mail').start()
      end,
      desc = '[O]pen [M]ail',
    },
  },
  config = function()
    require('custom.mail').setup()
  end,
}
