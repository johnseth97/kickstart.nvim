return {
  'nvim-tree/nvim-tree.lua',
  version = '*',
  cmd = { 'NvimTreeToggle' },
  init = function()
    vim.keymap.set('n', '\\', '<cmd>NvimTreeToggle<CR>', { desc = 'Toggle Explorer', silent = true })
    vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', { desc = 'File [E]xplorer', silent = true })
  end,
  opts = {
    hijack_netrw = false,
    update_focused_file = {
      enable = true,
      update_cwd = true,
    },
    view = {
      width = 35,
    },
    on_attach = function(bufnr)
      local api = require 'nvim-tree.api'
      -- Default mappings must be set before changing any mappings
      api.config.mappings.default_on_attach(bufnr)
      -- Optional: Customize the mappings
      local function map(lhs, rhs)
        vim.keymap.set('n', lhs, rhs, { buffer = bufnr, noremap = true, silent = true })
      end

      -- Optional: Map `\` to close the tree
      map('\\', api.tree.close)
    end,
  },
}
