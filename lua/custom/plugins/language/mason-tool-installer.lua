-- lua/custom/plugins/mason-tool-installer.lua
return {
  'WhoIsSethDaniel/mason-tool-installer.nvim',
  event = 'VeryLazy',
  dependencies = { 'williamboman/mason.nvim' },
  config = function()
    require('mason-tool-installer').setup {
      ensure_installed = {
        'lua_ls',
        'eslint',
        'denols',
        'rust_analyzer',
        'clangd',
        'pyright',
        'stylua',
        'prettierd',
        'prettier',
      },
    }
  end,
}
