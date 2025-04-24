return { -- Main LSP Configuration
  -- Main LSP Configuration
  'neovim/nvim-lspconfig',
  ft = { -- File types to load this plugin
    'c',
    'cpp',
    'lua',
    'python',
    'javascript',
    'typescript',
    'rust',
    'go',
    'sh',
    'bash',
    'html',
    'css',
    'json',
  },
  dependencies = {
    -- Automatically install LSPs and related tools to stdpath for Neovim
    { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    -- Allows extra capabilities provided by nvim-cmp
    { 'hrsh7th/cmp-nvim-lsp', event = 'InsertEnter' },
  },
  config = function()
    local lspconfig = require 'lspconfig'

    -- Configure Lua language server globally to recognize `vim` and Neovim runtime
    lspconfig.lua_ls.setup {
      settings = {
        Lua = {
          runtime = { version = 'LuaJIT' },
          diagnostics = { globals = { 'vim' } },
          workspace = { library = vim.api.nvim_get_runtime_file('', true) }, -- make the server aware of Neovim runtime files
          telemetry = { enable = false },
          completion = { callSnippet = 'Replace' },
        },
      },
    }

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local bufnr = event.buf
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
        end

        -- Standard LSP mappings using Telescope
        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          local hl_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = bufnr,
            group = hl_augroup,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = bufnr,
            group = hl_augroup,
            callback = vim.lsp.buf.clear_references,
          })
          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr })
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    -- Extend capabilities for nvim-cmp
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

    local servers = {
      clangd = {
        cmd = { 'clangd', '--compile-commands-dir=.' },
        capabilities = capabilities,
        settings = { clangd = { args = { '-I/opt/homebrew/Cellar/GMP/6.3.0/include', '-L/opt/homebrew/Cellar/GMP/6.3.0/lib' } } },
      },
      denols = {
        root_dir = require('lspconfig.util').root_pattern('deno.json', 'deno.jsonc'),
        init_options = {
          enable = true,
          lint = true,
          unstable = true,
          suggest = { imports = { hosts = { ['https://deno.land'] = true, ['https://esm.sh'] = true } } },
        },
      },
      eslint = {
        root_dir = require('lspconfig.util').root_pattern('.eslintrc', '.eslintrc.js', '.eslintrc.json'),
        settings = { format = { enable = false } },
        on_attach = function(client)
          client.server_capabilities.documentFormattingProvider = false
        end,
      },
      lua_ls = { capabilities = capabilities },
      -- Add other servers here...
    }
  end,
}
