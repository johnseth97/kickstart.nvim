-- lua/custom/plugins/mason-lspconfig.lua
return {
  'williamboman/mason-lspconfig.nvim',
  event = 'LspAttach',
  dependencies = { 'williamboman/mason.nvim' },
  config = function()
    require('mason-lspconfig').setup {
      ensure_installed = { 'lua_ls', 'eslint', 'denols', 'rust_analyzer', 'clangd', 'pyright' },
      automatic_installation = true,
    }
  end,
}
