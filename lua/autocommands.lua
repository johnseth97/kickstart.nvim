-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
--
-- Always switch to insert mode when opening a terminal buffer
-- Hopefully this works
vim.api.nvim_create_autocmd({ 'TermOpen', 'BufEnter' }, {
  pattern = { '*' },
  callback = function()
    if vim.opt.buftype:get() == 'terminal' then
      vim.cmd ':startinsert'
    end
  end,
})

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    local argv = vim.fn.argv()
    if #argv == 1 and vim.fn.isdirectory(argv[1]) == 1 then
      local dir = vim.fn.fnamemodify(argv[1], ':p')
      vim.fn.chdir(dir)

      vim.schedule(function()
        Snacks.picker.files {
          prompt_title = 'Find File in ' .. argv[1],
          cwd = dir, -- use the absolute dir you just chdir'd to
          hidden = true,
          follow = true,
          ignored = true,
        }
      end)
    end
  end,
})
