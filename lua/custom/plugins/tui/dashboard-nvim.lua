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
              desc = '  Switch Project (~/src/Javascript/)',
              group = 'Label',
              key = 'p',
              action = function()
                require('telescope.builtin').find_files {
                  prompt_title = 'Pick a Project',
                  cwd = '~/src/Javascript/',
                  find_command = { 'fd', '--type', 'd', '--max-depth', '1', '--strip-cwd-prefix' },
                  attach_mappings = function(_, map)
                    local actions = require 'telescope.actions'
                    local action_state = require 'telescope.actions.state'

                    map('i', '<CR>', function(prompt_bufnr)
                      local entry = action_state.get_selected_entry()
                      local project_path = entry.path or entry[1]

                      actions.close(prompt_bufnr)
                      vim.cmd('cd ' .. vim.fn.fnameescape(project_path))
                      print('[📂] CWD set to: ' .. project_path)
                    end)

                    return true
                  end,
                }
              end,
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
                local target = vim.fn.expand '~/.dotfiles'
                vim.cmd('cd ' .. target)
                require('telescope.builtin').find_files {
                  prompt_title = 'Dotfiles',
                  cwd = target,
                  hidden = true,
                }
              end, -- Use inline function for custom picker
              key = 'd',
            },
            {
              desc = ' Neovim dotfiles',
              group = 'Number',
              action = function()
                local target = vim.fn.expand '~/.dotfiles/.config/nvim'
                vim.cmd('cd ' .. target)
                require('telescope.builtin').find_files {
                  prompt_title = 'Neovim dotfiles',
                  path = target,
                  cwd = target,
                  respect_gitignore = true,
                  hidden = true,
                  grouped = true,
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
