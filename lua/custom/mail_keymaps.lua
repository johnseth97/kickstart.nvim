-- Mail keeps navigation and composition conveniences without editor integrations.
require 'custom.keymaps.navigation'
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<leader>un', function()
  Snacks.notifier.show_history()
end, { desc = 'Notification history' })
vim.keymap.set('n', '<leader>us', function()
  vim.wo.spell = not vim.wo.spell
end, { desc = 'Toggle spelling' })
vim.keymap.set('n', '<leader>uw', function()
  vim.wo.wrap = not vim.wo.wrap
end, { desc = 'Toggle wrapping' })
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'mail',
  callback = function()
    vim.opt_local.spell = true
  end,
})
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
})
