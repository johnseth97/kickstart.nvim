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
      vim.cmd('cd ' .. argv[1]) -- Set CWD to the opened directory
      require('telescope.builtin').find_files {
        prompt_title = 'Find File in ' .. argv[1],
        cwd = argv[1],
        hidden = true,
        follow = true,
        no_ignore = true,
      }
    end
  end,
})
