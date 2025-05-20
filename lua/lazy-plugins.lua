---@type LazyConfig
local lazy_config = {
  local_spec = function()
    return {}
  end,
  spec = {
    {
      'catppuccin/nvim',
      name = 'catppuccin',
      priority = 1000,
      lazy = false,
      opts = {
        transparent_background = true,
        flavour = 'macchiato',
      },
      config = function(_, opts)
        require('catppuccin').setup(opts)
        vim.cmd.colorscheme 'catppuccin-macchiato'
        vim.cmd.hi 'Comment gui=none'
      end,
    },
    {
      'williamboman/mason.nvim',
      event = { 'BufReadPre', 'BufNewFile' },
      opts = {},
      config = true,
    },
    {
      'williamboman/mason-lspconfig.nvim',
      event = { 'BufReadPre', 'BufNewFile' },
      dependencies = { 'williamboman/mason.nvim' },
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

    -- Import plugin groups
    { import = 'custom.plugins.language.lazydev-nvim' },
    { import = 'custom.plugins.language.dap' },
    { import = 'custom.plugins.appearance' },
    { import = 'custom.plugins.language' },
    { import = 'custom.plugins.packs' },
    { import = 'custom.plugins.style' },
    { import = 'custom.plugins.tui' },
    { import = 'custom.plugins.utilities' },
    { import = 'kickstart.plugins' },
  },

  root = vim.fn.stdpath 'data' .. '/lazy',
  defaults = { lazy = true },
  install = { missing = true, colorscheme = { 'catppuccin' } },
  lockfile = vim.fn.stdpath 'data' .. '/lazy-lock.json',
  git = {
    timeout = 120,
    url_format = 'https://github.com/%s.git',
    log = { '--since=3 days ago' },
    filter = true,
  },
  checker = {
    enabled = true,
    concurrency = nil,
    notify = false,
    frequency = 3600,
  },
  performance = {
    cache = { enabled = true },
    reset_packpath = true,
    rtp = {
      disabled_plugins = { 'gzip', 'matchit', 'netrwPlugin', 'tarPlugin', 'tohtml', 'tutor' },
    },
  },
  change_detection = {
    enabled = true,
    notify = true,
  },
  readme = {
    enabled = true,
    root = vim.fn.stdpath 'state' .. '/lazy/readme',
    files = { 'README.md', 'lua/**/README.md' },
    skip_if_doc_exists = true,
  },
  state = vim.fn.stdpath 'state' .. '/lazy/state.json',
  profiling = {
    loader = false,
    require = false,
  },
  dev = {
    path = '~/projects',
    patterns = {},
    fallback = false,
  },
  ui = {
    size = { width = 0.8, height = 0.8 },
    wrap = true,
    border = 'none',
    title = nil,
    title_pos = 'center',
    pills = true,
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
  debug = false,
  diff = {
    cmd = 'diff',
  },
  headless = nil, -- you can override to true/false to force behavior
  pkg = nil, -- used for packager configs (optional)
  rocks = nil, -- for luarocks
}

require('lazy').setup(lazy_config)
