-- /lua/custom/keymaps/navigation.lua
--
-- Remap jkl; to hjkl in normal mode
vim.keymap.set({ 'n', 'o' }, 'j', 'h', { noremap = true, desc = 'Move cursor left' })
vim.keymap.set({ 'n', 'o' }, 'k', 'j', { noremap = true, desc = 'Move cursor down' })
vim.keymap.set({ 'n', 'o' }, 'l', 'k', { noremap = true, desc = 'Move cursor up' })
vim.keymap.set({ 'n', 'o' }, ';', 'l', { noremap = true, desc = 'Move cursor right' })
--
-- Remap jkl; to hjkl in visual mode
vim.keymap.set({ 'v', 'o' }, 'j', 'h', { noremap = true, desc = 'Move cursor left' })
vim.keymap.set({ 'v', 'o' }, 'k', 'j', { noremap = true, desc = 'Move cursor down' })
vim.keymap.set({ 'v', 'o' }, 'l', 'k', { noremap = true, desc = 'Move cursor up' })
vim.keymap.set({ 'v', 'o' }, ';', 'l', { noremap = true, desc = 'Move cursor right' })
--
--Disable arrow keys in normal mode
vim.keymap.set({ 'n', 'o' }, '<left>', '<cmd>echo "Use j to move!!"<CR>')
vim.keymap.set({ 'n', 'o' }, '<right>', '<cmd>echo "Use ; to move!!"<CR>')
vim.keymap.set({ 'n', 'o' }, '<up>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set({ 'n', 'o' }, '<down>', '<cmd>echo "Use k to move!!"<CR>')
--
-- Remap split navigation
vim.keymap.set('n', '<C-j>', '<C-w>h', { noremap = true, desc = 'Move focus to the left split' })
vim.keymap.set('n', '<C-k>', '<C-w>j', { noremap = true, desc = 'Move focus to the bottom split' })
vim.keymap.set('n', '<C-l>', '<C-w>k', { noremap = true, desc = 'Move focus to the top split' })
vim.keymap.set('n', '<C-;>', '<C-w>l', { noremap = true, desc = 'Move focus to the right split' })
