-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
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
--
-- Remap jkl; to hjkl in normal mode
--  This is a personal preference, but I find it easier to use the home row keys
-- Map 'j' to move left while supporting motions like '3j'
vim.keymap.set('n', 'j', 'h', { noremap = true, desc = 'Move cursor left' })

-- Map 'k' to move down while supporting motions like '3k'
vim.keymap.set('n', 'k', 'j', { noremap = true, desc = 'Move cursor down' })

-- Map 'l' to move up while supporting motions like '3l'
vim.keymap.set('n', 'l', 'k', { noremap = true, desc = 'Move cursor up' })

-- Map ';' to move right while supporting motions like '3;'
vim.keymap.set('n', ';', 'l', { noremap = true, desc = 'Move cursor right' })

--
-- TIP: Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use j to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use ; to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use k to move!!"<CR>')
--
-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
-- Remap split navigation
vim.keymap.set('n', '<C-j>', '<C-w>j', { noremap = true, desc = 'Move focus to the left split' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true, desc = 'Move focus to the bottom split' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { noremap = true, desc = 'Move focus to the top split' })
vim.keymap.set('n', '<C-;>', '<C-w>;', { noremap = true, desc = 'Move focus to the right split' })
