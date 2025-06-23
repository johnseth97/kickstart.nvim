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

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'DiffviewFiles', 'DiffviewFileHistory', 'DiffviewPanel', 'diff', 'NvimTree' },
  callback = function()
    local opts = { buffer = true, noremap = true, desc = 'Remap navigation for Diffview buffers' }

    -- Navigation
    vim.keymap.set('n', 'j', 'h', opts)
    vim.keymap.set('n', 'k', 'j', opts)
    vim.keymap.set('n', 'l', 'k', opts)
    vim.keymap.set('n', ';', 'l', opts)

    -- Window switching (optional)
    vim.keymap.set('n', '<C-j>', '<C-w>h', opts)
    vim.keymap.set('n', '<C-k>', '<C-w>j', opts)
    vim.keymap.set('n', '<C-l>', '<C-w>k', opts)
    vim.keymap.set('n', '<C-;>', '<C-w>l', opts)
  end,
})

vim.api.nvim_create_autocmd('OptionSet', {
  pattern = 'diff',
  callback = function()
    if vim.opt.diff:get() then
      local opts = { buffer = true, noremap = true }

      -- Movement remaps
      vim.keymap.set('n', 'j', 'h', opts)
      vim.keymap.set('n', 'k', 'j', opts)
      vim.keymap.set('n', 'l', 'k', opts)
      vim.keymap.set('n', ';', 'l', opts)

      -- Window navigation
      vim.keymap.set('n', '<C-j>', '<C-w>h', opts)
      vim.keymap.set('n', '<C-k>', '<C-w>j', opts)
      vim.keymap.set('n', '<C-l>', '<C-w>k', opts)
      vim.keymap.set('n', '<C-;>', '<C-w>l', opts)
    end
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'man',
  callback = function()
    local opts = { buffer = true, noremap = true, desc = 'Remap man navigation' }

    vim.keymap.set({ 'n', 'o' }, 'j', 'h', opts)
    vim.keymap.set({ 'n', 'o' }, 'k', 'j', opts)
    vim.keymap.set({ 'n', 'o' }, 'l', 'k', opts)
    vim.keymap.set({ 'n', 'o' }, ';', 'l', opts)

    vim.keymap.set({ 'v', 'o' }, 'j', 'h', opts)
    vim.keymap.set({ 'v', 'o' }, 'k', 'j', opts)
    vim.keymap.set({ 'v', 'o' }, 'l', 'k', opts)
    vim.keymap.set({ 'v', 'o' }, ';', 'l', opts)

    -- Optional split nav
    vim.keymap.set('n', '<C-j>', '<C-w>h', opts)
    vim.keymap.set('n', '<C-k>', '<C-w>j', opts)
    vim.keymap.set('n', '<C-l>', '<C-w>k', opts)
    vim.keymap.set('n', '<C-;>', '<C-w>l', opts)
  end,
})
