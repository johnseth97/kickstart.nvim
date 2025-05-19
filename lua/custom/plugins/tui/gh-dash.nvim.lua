return {
  'johnseth97/gh-dash.nvim',
  lazy = true,
  cmd = { 'GHdash', 'GHdashToggle' },
  keys = {
    {
      '<leader>gd',
      function()
        require('gh_dash').toggle()
      end,
      desc = 'Toggle gh-dash popup',
    },
  },
  opts = {
    keymaps = {}, -- disable internal mapping
    border = 'rounded',
    width = 0.8,
    height = 0.8,
    autoinstall = true,
  },
}
