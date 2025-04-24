vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
--
-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
--
-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Remap navigation from hjkl to jkl;
require 'custom.keymaps.navigation'

-- Reload the neovim config file
vim.keymap.set('n', '<leader>sv', '<cmd>source $MYVIMRC<CR>', { desc = 'Reload the Neovim config file' })

-- Launch the dashboard
vim.keymap.set('n', '<leader>da', function()
  vim.cmd 'Dashboard'
end, { desc = '[da]shboard' })

-- Launch the database UI
vim.keymap.set('n', '<leader>db', function()
  vim.cmd [[DBUI]]
end, { desc = '[d]ata[b]ase UI' })

-- Telescope file browser with project change
require 'custom.keymaps.telescope-project-change'

-- Bufferline navigation
require 'custom.keymaps.bufferline'
