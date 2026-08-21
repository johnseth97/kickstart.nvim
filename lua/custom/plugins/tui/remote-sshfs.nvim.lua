return {
  'nosduco/remote-sshfs.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim' },
  opts = {
    connections = {
      ssh_configs = {
        '/mnt/c/Users/EthanJohnson/.ssh/config',
      },
    },
    mounts = {
      base_dir = vim.fn.stdpath 'data' .. '/remote-sshfs/mounts/',
      unmount_on_exit = true,
    },
    handlers = {
      on_connect = { change_dir = true },
    },
  },
  config = function(_, opts)
    require('remote-sshfs').setup(opts)
    require('telescope').load_extension 'remote-sshfs'
  end,
  keys = {
    {
      '<leader>rc',
      function()
        require('telescope').extensions['remote-sshfs'].connections()
      end,
      desc = '[r]emote [c]onnect',
    },
    {
      '<leader>re',
      function()
        require('telescope').extensions['remote-sshfs'].edit()
      end,
      desc = '[r]emote [e]dit',
    },
  },
}
