-- lua/custom/plugins/dap/osv.lua
return {
  {
    'jbyuki/one-small-step-for-vimkind',
    ft = 'lua', -- only load on Lua buffers
    dependencies = { 'mfussenegger/nvim-dap' },
    config = function()
      local dap = require 'dap'
      -- Tell DAP how to talk to the Neovim debug server
      dap.adapters.nlua = function(callback, config)
        callback {
          type = 'server',
          host = config.host or '127.0.0.1',
          port = config.port or 8086,
        }
      end

      -- Add an “attach” configuration for Lua files
      dap.configurations.lua = {
        {
          type = 'nlua',
          request = 'attach',
          name = 'Attach to Neovim',
          host = '127.0.0.1',
          port = 8086,
        },
      }

      -- Keymaps for launching & attaching
      vim.keymap.set('n', '<leader>dl', function()
        require('osv').launch { port = 8086 }
      end, { desc = 'DAP: Launch Neovim debug server' })
      vim.keymap.set('n', '<leader>da', function()
        require('dap').continue()
      end, { desc = 'DAP: Attach to Neovim' })
    end,
  },
}
