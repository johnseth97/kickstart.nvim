-- /lua/custom/plugins/tui/dashboard-nvim.lua
return {
  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    cond = vim.env.DOTFILES_MAIL ~= '1',
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
        project = { enable = false },

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
              Snacks.picker.files {
                prompt_title = 'Src Files',
                cwd = vim.fn.expand '~',
                hidden = true,
                ignored = true,
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
              Snacks.picker.files { cwd = tgt, hidden = true }
            end,
          },
          {
            desc = '  Neovim dotfiles',
            group = 'Number',
            key = 'v',
            action = function()
              local tgt = vim.fn.expand '~/.dotfiles/common/.config/nvim'
              vim.cmd('cd ' .. tgt)
              Snacks.picker.files {
                cwd = tgt,
                hidden = true,
              }
            end,
          },
          {
            desc = '  All projects',
            group = 'Label',
            key = 'p',
            action = function()
              Snacks.picker.projects()
            end,
          },
          {
            desc = '󰎞  Notes',
            group = 'Label',
            key = 'n',
            action = function()
              vim.cmd 'ZkNotes'
            end,
          },
        },
      },
    },
  },
}
