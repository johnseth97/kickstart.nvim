-- lua/custom/plugins/dotnet.lua
local on_attach = function(client, bufnr)
  local bufmap = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end
  bufmap('n', '<leader>dr', require('dap').continue, 'DAP: Continue')
  bufmap('n', '<leader>db', require('dap').toggle_breakpoint, 'DAP: Toggle Breakpoint')
  bufmap('n', '<leader>dso', require('dap').step_over, 'DAP: Step Over')
  bufmap('n', '<leader>dsi', require('dap').step_into, 'DAP: Step Into')
end

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

    -- 2) Mason + LSP
    require('mason').setup()
    require('mason-lspconfig').setup { ensure_installed = { 'omnisharp' } }

    -- Pin the capital-O “OmniSharp” binary that Mason put in stdpath("data")/mason/bin
    local mason_bin = vim.fn.stdpath 'data' .. '/mason/bin'
    local omnisharp_ex = mason_bin .. '/OmniSharp'

    local lspconfig = require 'lspconfig'
    lspconfig.omnisharp.setup {
      cmd = { omnisharp_ex, '--languageserver', '--hostPID', tostring(vim.fn.getpid()) },
      on_attach = on_attach,
      flags = { debounce_text_changes = 150 },
      root_dir = lspconfig.util.root_pattern('*.sln', '.git'),
      settings = {
        RoslynExtensionsOptions = {
          enableAnalyzersSupport = true,
          organizeImportsOnFormat = true,
          organizeImportsOnSave = true,
          logLevel = 'debug',
        },
        FormattingOptions = {
          enableEditorConfigSupport = true,
        },
      },
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

    -- 4) (Optional) if you’d rather not hard-code omnisharp_ex,
    --    add Mason’s bin to your shell PATH in ~/.zshrc:
    --    export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"
  end,
}
