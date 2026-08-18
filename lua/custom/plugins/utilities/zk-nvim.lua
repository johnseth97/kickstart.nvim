return {
  'zk-org/zk-nvim',
  name = 'zk',

  cmd = {
    'ZkNew',
    'ZkNotes',
    'ZkTags',
    'ZkBacklinks',
    'ZkLinks',
    'ZkIndex',
    'ZkCd',
    'ZkBuffers',
    'ZkInsertLink',
    'ZkInsertLinkAtSelection',
    'ZkMatch',
    'ZkNewFromTitleSelection',
    'ZkNewFromContentSelection',
  },

  init = function()
    vim.env.ZK_NOTEBOOK_DIR = vim.fn.expand '~/notes'
  end,

  ft = 'markdown',

  opts = {
    picker = 'telescope',

    picker_options = {
      telescope = require('telescope.themes').get_ivy(),
    },

    lsp = {
      config = {
        name = 'zk',
        cmd = { 'zk', 'lsp' },
        filetypes = { 'markdown' },
      },

      auto_attach = {
        enabled = true,
      },
    },

    tags = {
      multi_select_strategy = 'AND',
    },
  },

  config = function(_, opts)
    require('zk').setup(opts)
    require('custom.ft.markdown').setup()
  end,
}
