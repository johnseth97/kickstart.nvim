return { -- Mini.nvim: Collection of various small independent plugins/modules
  'echasnovski/mini.nvim',
  event = vim.g.dotfiles_mail_mode and 'InsertEnter' or 'BufReadPost',
  ft = vim.g.dotfiles_mail_mode and 'mail' or nil,
  config = function()
    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
    --  - ci'  - [C]hange [I]nside [']quote
    require('mini.ai').setup { n_lines = 500 }

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup()

    -- Git integration for Neovim, :Git <command>
    if not vim.g.dotfiles_mail_mode then
      require('mini.git').setup()
    end

    -- ... and there is more!
    --  Check out: https://github.com/echasnovski/mini.nvim
  end,
}
