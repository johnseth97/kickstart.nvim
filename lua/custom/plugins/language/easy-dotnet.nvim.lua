-- lua/custom/plugins/dotnet.lua
return {
  'GustavEikaas/easy-dotnet.nvim',
  ft = { 'cs', 'fs', 'vb' },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'neovim/nvim-lspconfig',
    'mfussenegger/nvim-dap',
  },
  config = function()
    -- 1) EasyDotnet
    require('easy-dotnet').setup {
      background_scanning = false,
    }

    -- 2) Ensure OmniSharp is installed via Mason (LSP setup is done in lsp-config.lua)
    require('mason').setup()
    require('mason-lspconfig').setup {
      ensure_installed = { 'omnisharp' },
      -- leave automatic_* false, you’re handling setup yourself in lsp-config.lua
      automatic_installation = true,
      automatic_setup = false,
    }

    -- 3) DAP for .NET Core via netcoredbg
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
          return vim.fn.input('Path to DLL: ', vim.fn.getcwd() .. '/bin/Debug/net9.0/SagepointDashboard.dll', 'file')
        end,
      },
    }

    -- DAP keymaps are set via on_attach above; your central LSP config
    -- should hook on_attach into omnisharp so they apply to C# buffers.
    -- If not, you can move that on_attach into lsp-config.lua’s omnisharp entry.
  end,
}
