return {
  'johnseth97/codex.nvim',
  branch = 'patch-2',
  lazy = true,
  keys = {
    {
      '<leader>cc',
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
