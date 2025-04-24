-- lua/custom/plugins/mason.lua
return {
  'williamboman/mason.nvim',
  cmd = { 'Mason', 'MasonInstall', 'MasonUninstall', 'MasonLog' },
  opts = {}, -- or your custom UI settings
  config = true, -- calls `require('mason').setup()` for you
}
