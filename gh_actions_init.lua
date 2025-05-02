-- minimal_init.lua
-- 1) Bootstrap lazy.nvim itself into stdpath("data")/lazy/lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- 2) Use Lazy to manage only bloat.nvim
require('lazy').setup {
  { 'nickeb96/bloat.nvim', cmd = 'Bloat' },
}
