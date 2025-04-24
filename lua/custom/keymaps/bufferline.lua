-- lua/keymaps/bufferline.lua

-- ensure true colors (only needs to be set once)
vim.opt.termguicolors = true

-- ordinal nav: <C-b>1–9,0
for i = 1, 9 do
  vim.keymap.set('n', ('<C-b>%d'):format(i), function()
    require('bufferline.commands').go_to(i)
  end, { desc = 'Go to buffer ' .. i })
end
vim.keymap.set('n', '<C-b>0', function()
  require('bufferline.commands').go_to(10)
end, { desc = 'Go to buffer 10' })

-- close buffer
vim.keymap.set('n', '<C-b>x', '<cmd>bdelete<CR>', { desc = 'Close current buffer' })
