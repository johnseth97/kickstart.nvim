-- autopairs
-- https://github.com/windwp/nvim-autopairs

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  -- Optional dependency
  dependencies = vim.g.dotfiles_mail_mode and {} or { 'hrsh7th/nvim-cmp' },
  config = function()
    require('nvim-autopairs').setup {}
    if vim.g.dotfiles_mail_mode then
      return
    end
    -- If you want to automatically add `(` after selecting a function or method
    local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
    local cmp = require 'cmp'
    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
  end,
}
