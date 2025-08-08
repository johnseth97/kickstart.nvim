return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'hrsh7th/cmp-nvim-lsp',
  },
  config = function()
    local lspconfig = require 'lspconfig'
    local mason_lspconfig = require 'mason-lspconfig'
    local cmp_nvim_lsp = require 'cmp_nvim_lsp'

    local capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(), cmp_nvim_lsp.default_capabilities())

    local std_cfg = vim.fn.stdpath 'config'
    local dotcfg = vim.fn.expand '~/.dotfiles/.config/nvim'

    local servers = {
      lua_ls = {
        settings = {
          Lua = {
            runtime = {
              version = 'LuaJIT',
              path = vim.split(package.path, ';'),
            },
            diagnostics = {
              globals = { 'vim' },
              disable = { 'lowercase-global' },
            },
            workspace = {
              library = {
                [std_cfg .. '/lua'] = true,
                [dotcfg .. '/lua'] = true,
                [dotcfg .. '/lua/custom'] = true,
                [vim.fn.stdpath 'data' .. '/lazy/lazy.nvim/lua'] = true,
              },
              checkThirdParty = false,
            },
            completion = { callSnippet = 'Replace' },
            telemetry = { enable = false },
          },
        },
      },
      clangd = {
        cmd = { 'clangd', '--compile-commands-dir=.' },
      },
      denols = {
        root_dir = lspconfig.util.root_pattern('deno.json', 'deno.jsonc'),
        init_options = {
          enable = true,
          lint = true,
          unstable = true,
        },
      },
      eslint = {
        root_dir = lspconfig.util.root_pattern('.eslintrc', '.eslintrc.js', '.eslintrc.json'),
        settings = { format = { enable = false } },
        on_attach = function(client)
          client.server_capabilities.documentFormattingProvider = false
        end,
      },
      omnisharp = {
        cmd = {
          vim.fn.stdpath 'data' .. '/mason/bin/omnisharp',
          '--languageserver',
          '--hostPID',
          tostring(vim.fn.getpid()),
        },
        root_dir = require('lspconfig.util').root_pattern('*.sln', '*.csproj', '.git'),
        enable_editorconfig_support = true,
        enable_ms_build_load_projects_on_demand = false,
        enable_roslyn_analyzers = true,
        organize_imports_on_format = true,
        enable_import_completion = true,
      },
    }

    -- 🛠 Explicit setup — this is what prevents "attach everything"
    mason_lspconfig.setup {
      ensure_installed = vim.tbl_keys(servers),
      automatic_installation = true, -- 🔴 IMPORTANT!
      automatic_enable = false,
      automatic_setup = false,
    }

    -- manually wire up only the defined servers
    for server_name, opts in pairs(servers) do
      opts.capabilities = vim.tbl_deep_extend('force', {}, capabilities, opts.capabilities or {})
      lspconfig[server_name].setup(opts)
    end

    -- Keymaps
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(ev)
        local buf = ev.buf
        local map = function(keys, fn, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, fn, { buffer = buf, desc = 'LSP: ' .. desc })
        end
        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto Definition')
        map('gr', require('telescope.builtin').lsp_references, '[G]oto References')
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode Action')
      end,
    })
  end,
}
