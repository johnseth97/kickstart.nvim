-- lua/custom/plugins/dotnet.lua
return {
  'GustavEikaas/easy-dotnet.nvim',
  ft = { 'cs', 'fs', 'vb' },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'neovim/nvim-lspconfig',
    'mfussenegger/nvim-dap',
  },
  config = function()
    -- 1) EasyDotnet
    require('easy-dotnet').setup {
      background_scanning = false,
    }

    -- LSP and Mason ownership lives in lsp-config.lua.
    -- DAP for .NET Core via netcoredbg.
    local dap = require 'dap'
    dap.adapters.netcoredbg = {
      type = 'executable',
      command = 'netcoredbg', -- ensure this is in your PATH
      args = { '--interpreter=vscode' },
    }
    dap.configurations.cs = {
      {
        type = 'netcoredbg',
        name = 'Launch .NET DLL',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to DLL: ', vim.fn.getcwd() .. '/', 'file')
        end,
      },
    }

  end,
}
