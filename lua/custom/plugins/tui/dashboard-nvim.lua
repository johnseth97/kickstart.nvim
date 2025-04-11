return {
  { -- Dashboard
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    config = function()
      require('dashboard').setup {
        theme = 'hyper',
        config = {
          week_header = {
            enable = true,
          },
          shortcut = {
            { desc = '󰊳 Update', group = '@property', action = 'Lazy update', key = 'u' },
            {
              icon = ' ',
              icon_hl = '@variable',
              desc = 'Files',
              group = 'Label',
              action = 'Telescope find_files',
              key = 'f',
            },
            {
              desc = ' Src',
              group = 'DiagnosticHint',
              action = function()
                require('telescope').extensions.file_browser.file_browser {
                  path = '~/src',
                  respect_gitignore = false,
                  hidden = true,
                  grouped = true,
                }
              end,
              key = 's',
            },
            {
              desc = ' dotfiles',
              group = 'Number',
              action = function()
                require('telescope.builtin').find_files {
                  prompt_title = 'Dotfiles',
                  cwd = vim.fn.expand '~/.dotfiles',
                  hidden = true,
                }
              end, -- Use inline function for custom picker
              key = 'd',
            },
            {
              desc = ' Neovim dotfiles',
              group = 'Number',
              action = function()
                require('telescope.builtin').find_files {
                  prompt_title = 'Neovim dotfiles',
                  path = '~/.dotfiles/.config/nvim',
                  cwd = vim.fn.expand '~/.dotfiles/.config/nvim',
                  respect_gitignore = true,
                  hidden = true,
                  grouped = true,
                  select_buffer = true,
                }
              end,
              key = 'v',
            },
          },
        },
      }
    end,
    dependencies = { { 'nvim-tree/nvim-web-devicons' } },
  },
}
