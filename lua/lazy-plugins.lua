-- init.lua (or wherever you call require('lazy').setup)
require('lazy').setup {
  spec = {
    -- 1) Mason & friends first, on the same early file-open events
    {
      'williamboman/mason.nvim',
      -- load Mason as soon as you open any file (or create a new one)
      event = { 'BufReadPre', 'BufNewFile' },
      opts = {}, -- your Mason UI opts, if any
      config = true, -- calls require('mason').setup()
    },
    {
      'williamboman/mason-lspconfig.nvim',
      event = { 'BufReadPre', 'BufNewFile' },
      dependencies = { 'williamboman/mason.nvim' },
      config = function()
        require('mason-lspconfig').setup {
          ensure_installed = { 'lua_ls', 'eslint', 'denols', 'rust_analyzer', 'clangd', 'pyright' },
          automatic_installation = true,
        }
      end,
    },
    {
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      event = { 'BufReadPre', 'BufNewFile' },
      dependencies = { 'williamboman/mason.nvim' },
      config = function()
        require('mason-tool-installer').setup {
          ensure_installed = {
            'stylua',
            'prettier',
            'prettierd',
            'lua_ls',
            'eslint',
            'denols',
            'rust_analyzer',
            'clangd',
            'pyright',
          },
        }
      end,
    },

    -- 2) Now your “import =” blocks and other single specs
    { import = 'custom.plugins.language.lazydev-nvim' },
    { import = 'custom.plugins.appearance' },
    { import = 'custom.plugins.language' },
    { import = 'custom.plugins.packs' },
    { import = 'custom.plugins.style' },
    { import = 'custom.plugins.tui' },
    { import = 'custom.plugins.utilities' },
    { import = 'kickstart.plugins' },
  },

  -- keep your other top-level settings unchanged:
  root = vim.fn.stdpath 'data' .. '/lazy',
  defaults = { lazy = true },
  install = { missing = true, colorscheme = { 'catppuccin', 'tokyonight' } },
  lockfile = vim.fn.stdpath 'data' .. '/lazy-lock.json',
  git = { timeout = 120, url_format = 'https://github.com/%s.git' },
  checker = { enabled = true },
  performance = {
    rtp = {
      disabled_plugins = { 'gzip', 'matchit', 'netrwPlugin', 'tarPlugin', 'tohtml', 'tutor' },
    },
  },
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤',
    },
  },
}
