return { --Nvim Tree
  'nvim-tree/nvim-tree.lua',
  version = '*',
  lazy = false,
  cmd = 'NvimTreeToggle',
  keys = {
    { '\\', ':NvimTreeToggle<CR>', desc = 'NvimTree Toggle', silent = true },
    { '<leader>e', ':NvimTreeToggle<CR>', { silent = true }, desc = 'File [E]xplorer' },
  },
  opts = {
    filesystem = {
      window = {
        mappings = {
          ['\\'] = 'close_window',
        },
      },
    },
  },
  config = function()
    require('nvim-tree').setup {
      update_focused_file = {
        enable = true,
        update_cwd = true,
      },
    }
  end,
}
