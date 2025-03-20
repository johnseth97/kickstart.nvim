--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.

require('lazy').setup {
  spec = {
    { import = 'custom.plugins.appearance' }, -- This will import all files under lua/custom/plugins
    { import = 'custom.plugins.language' },
    { import = 'custom.plugins.packs' },
    { import = 'custom.plugins.style' },
    { import = 'custom.plugins.tui' },
    { import = 'custom.plugins.utilities' },
    { import = 'kickstart.plugins' },
  },
  root = vim.fn.stdpath 'data' .. '/lazy',
  defaults = { lazy = true },
  install = {
    missing = true,
    colorscheme = { 'catppuccin', 'tokyonight' },
  },
  lockfile = vim.fn.stdpath 'data' .. '/lazy-lock.json',
  git = {
    timeout = 120,
    url_format = 'https://github.com/%s.git',
  },
  checker = {
    enabled = true,
  },
  performance = {
    rtp = {
      disabled_plugins = { 'gzip', 'matchit', 'netrwPlugin', 'tarPlugin', 'tohtml', 'tutor' },
    },
  },
  require 'kickstart.plugins.autopairs',
  require 'kickstart.plugins.lint',
  require 'kickstart.plugins.debug',
  require 'kickstart.plugins.lint',
  require 'kickstart.plugins.indent_line',
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
      lazy = '💤 ',
    },
  },
}
