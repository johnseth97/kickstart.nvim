-- Snapshot before the launcher flag is cleared from child environments.
vim.g.dotfiles_mail_mode = vim.env.DOTFILES_MAIL == '1'

-- Init.lua
--
-- Options
--
-- Snacks profiler hook, must load before as much of the config as possibe
-- Otherwise, it won't be able to capture the events
if vim.env.PROF and not vim.g.dotfiles_mail_mode then
  local snacks = vim.fn.stdpath 'data' .. '/lazy/snacks.nvim'
  vim.opt.rtp = vim.opt.rtp + snacks

  require('snacks.profiler').startup {
    startup = {
      event = 'VimEnter',
      after = true,
      pick = true,
    },
    runtime = vim.env.VIMRUNTIME,
    thresholds = {},
    on_stop = {},
    highlights = {},
    pick = {},
    presets = {},
    globals = {},
    filter_mod = {},
    filter_fn = {},
    icons = {},
    autocmds = true,
    debug = false,
  }
end

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

require 'options'

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`
if vim.g.dotfiles_mail_mode then
  require 'custom.mail_keymaps'
else
  require 'keymaps'
end

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

if not vim.g.dotfiles_mail_mode then
  require 'autocommands'
end

-- [[ Custom User Commands ]]
-- johnseth97
if not vim.g.dotfiles_mail_mode then
  require 'usercommands'
  require 'ftdetect.github-actions'
end

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
require 'lazy-bootstrap'

-- [[ Configure and install plugins ]]
require 'lazy-plugins'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
