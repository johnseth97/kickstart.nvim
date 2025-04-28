return {
  'neovim/nvim-lspconfig',
  ft = {
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
    { 'hrsh7th/cmp-nvim-lsp', event = 'InsertEnter' },
  },
  config = function()
    local lspconfig = require 'lspconfig'
    local cmp_nvim_lsp = require 'cmp_nvim_lsp'

    -- detect both your "real" config path and stdpath('config')
    local std_cfg = vim.fn.stdpath 'config'
    local dotcfg = vim.fn.expand '~/.dotfiles/.config/nvim'

    -- Setup LuaLS
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, cmp_nvim_lsp.default_capabilities())

    lspconfig.lua_ls.setup {
      capabilities = capabilities,
      settings = {
        Lua = {
          runtime = {
            version = 'LuaJIT',
            path = vim.split(package.path, ';'),
          },
          diagnostics = {
            globals = { 'vim', 'describe', 'it', 'before_each', 'after_each', 'pending', 'assert', 'eq' },
            disable = { 'lowercase-global' },
          },
          workspace = {
            -- index all of your config
            library = {
              [std_cfg .. '/lua'] = true,
              [dotcfg .. '/lua'] = true,
              -- if you have lua/custom
              [dotcfg .. '/lua/custom'] = true,
              -- index lazy.nvim itself so you can jump into its source
              [vim.fn.stdpath 'data' .. '/lazy/lazy.nvim/lua'] = true,
            },
            checkThirdParty = false,
          },
          completion = { callSnippet = 'Replace' },
          telemetry = { enable = false },
        },
      },
    }

    -- Your other servers
    local servers = {
      clangd = {
        cmd = { 'clangd', '--compile-commands-dir=.' },
        capabilities = capabilities,
        settings = {
          clangd = {
            args = {
              '-I/opt/homebrew/Cellar/GMP/6.3.0/include',
              '-L/opt/homebrew/Cellar/GMP/6.3.0/lib',
            },
          },
        },
      },
      denols = {
        root_dir = lspconfig.util.root_pattern('deno.json', 'deno.jsonc'),
        init_options = {
          enable = true,
          lint = true,
          unstable = true,
          suggest = {
            imports = {
              hosts = {
                ['https://deno.land'] = true,
                ['https://esm.sh'] = true,
              },
            },
          },
        },
        capabilities = capabilities,
      },
      eslint = {
        root_dir = lspconfig.util.root_pattern('.eslintrc', '.eslintrc.js', '.eslintrc.json'),
        settings = { format = { enable = false } },
        on_attach = function(client)
          client.server_capabilities.documentFormattingProvider = false
        end,
        capabilities = capabilities,
      },
      -- lua_ls is done above
    }

    -- Actually iterate and setup each server
    for name, opts in pairs(servers) do
      lspconfig[name].setup(opts)
    end

    -- LspAttach keymaps (unchanged)
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
        -- add any others you like…
      end,
    })
  end,
}
