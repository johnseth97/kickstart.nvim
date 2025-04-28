-- /lua/custom/plugins/tui/dashboard-nvim.lua

return {
  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    opts = {
      theme = 'hyper',
      hide = {
        statusline = true,
        winbar = true,
        tabline = false, -- keep your bufferline visible
      },
      config = {
        week_header = { enable = true },

        shortcut = {
          {
            desc = '󰊳  Update',
            group = '@property',
            key = 'u',
            action = 'Lazy update',
          },
          {
            desc = '  Src (filenames)',
            group = 'DiagnosticHint',
            key = 's',
            action = function()
              require('telescope.builtin').find_files {
                prompt_title = 'Src Files',
                cwd = vim.fn.expand '~',
                hidden = true,
                no_ignore = true,
              }
            end,
          },
          {
            desc = '  dotfiles',
            group = 'Number',
            key = 'd',
            action = function()
              local tgt = vim.fn.expand '~/.dotfiles'
              vim.cmd('cd ' .. tgt)
              require('telescope.builtin').find_files { cwd = tgt, hidden = true }
            end,
          },
          {
            desc = '  Neovim dotfiles',
            group = 'Number',
            key = 'v',
            action = function()
              local tgt = vim.fn.expand '~/.dotfiles/.config/nvim'
              vim.cmd('cd ' .. tgt)
              require('telescope.builtin').find_files {
                cwd = tgt,
                hidden = true,
                respect_gitignore = true,
              }
            end,
          },
          {
            desc = '  All projects',
            group = 'Label',
            key = 'p',
            action = function()
              require('telescope').extensions.project.project {
                hidden = true,
                respect_gitignore = false,
                grouped = true,
              }
            end,
          },
        },
      },
    },
  },
}
