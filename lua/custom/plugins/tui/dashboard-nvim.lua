return {
  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      -- project.nvim for the center Recent Projects
      {
        'ahmedkhalf/project.nvim',
        dependencies = { 'nvim-telescope/telescope.nvim' },
        config = function()
          require('project_nvim').setup {
            detection_methods = { 'pattern' },
            patterns = { '.git' },
            base_dirs = { { '~/src', max_depth = 2 } },
            show_hidden = true,
            respect_gitignore = false,
          }
        end,
      },
      -- telescope-project.nvim for “All projects”
      {
        'nvim-telescope/telescope-project.nvim',
        dependencies = { 'nvim-telescope/telescope.nvim' },
        config = function()
          require('telescope').setup {
            extensions = {
              project = {
                base_dirs = { { '~/src', max_depth = 2 } },
                hidden_files = true,
                respect_gitignore = false,
                -- you can tweak order_by = "asc" or "recent"
              },
            },
          }
          require('telescope').load_extension 'project'
        end,
      },
      -- your file‑browser extension, if you’re using it elsewhere
      {
        'nvim-telescope/telescope-file-browser.nvim',
        dependencies = { 'nvim-telescope/telescope.nvim' },
      },
    },
    config = function()
      local db = require 'dashboard'
      local tbuiltin = require 'telescope.builtin'

      db.setup {
        theme = 'hyper',
        config = {
          week_header = { enable = true },

          -- top‑bar shortcuts
          shortcut = {
            { desc = '󰊳  Update', group = '@property', action = 'Lazy update', key = 'u' },
            {
              desc = '  Src (filenames)',
              group = 'DiagnosticHint',
              key = 's',
              action = function()
                require('telescope.builtin').find_files {
                  prompt_title = 'Src Files',
                  cwd = vim.fn.expand '~',
                  hidden = true, -- include dotfiles
                  no_ignore = true, -- don’t respect .gitignore
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
                tbuiltin.find_files { cwd = tgt, hidden = true }
              end,
            },
            {
              desc = '  Neovim dotfiles',
              group = 'Number',
              key = 'v',
              action = function()
                local tgt = vim.fn.expand '~/.dotfiles/.config/nvim'
                vim.cmd('cd ' .. tgt)
                tbuiltin.find_files {
                  cwd = tgt,
                  hidden = true,
                  respect_gitignore = true,
                }
              end,
            },
            {
              -- ← this now calls telescope-project.nvim’s “project” picker
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

          -- center “Recent Projects” powered by project.nvim
          project = {
            enable = true,
            limit = 8,
            icon = '  ',
            label = 'Recent Projects:',
            action = function(path)
              -- cd into it and open a file picker
              vim.cmd('cd ' .. path)
              tbuiltin.find_files { cwd = path, hidden = true }
            end,
          },
        },
      }
    end,
  },
}
