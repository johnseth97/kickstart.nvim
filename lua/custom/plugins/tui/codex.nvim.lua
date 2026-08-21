return {
  -- Fetch the maintained personal upstream instead of a machine-local checkout.
  'johnseth97/codex.nvim',
  lazy = true,
  keys = {
    {
      '<leader>cd',
      function()
        require('codex').toggle()
      end,
      desc = 'Toggle Codex popup',
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
