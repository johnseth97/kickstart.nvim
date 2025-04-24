-- lua/custom/plugins/fidget.nvim.lua
return {
  'j-hui/fidget.nvim',
  -- only load once an LSP actually attaches
  event = 'LspAttach',
  -- stub out the nvim-tree integration module before fidget.setup() runs
  init = function()
    package.loaded['fidget.integration.nvim-tree'] = { setup = function() end }
  end,
  opts = {
    -- your normal opts (minus any built-in nvim-tree bits)
    -- integration = { ['nvim-tree'] = { enable = false } },
    -- …
  },
}
