return {
  { -- Telescope core
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      local telescope = require 'telescope'

      telescope.setup {
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
          project = {
            base_dirs = { { '~/src', max_depth = 3 } },
            hidden_files = true,
            respect_gitignore = false,
            order_by = 'asc',
            display_type = 'full',
            hide_workspace = true,
          },
          file_browser = {
            -- Directory startup is handled by the Snacks VimEnter autocmd.
            hijack_netrw = false,
          },
        },
        defaults = {},
        pickers = {},
      }

      -- Make Telescope transparent
      local function set_transparent_telescope()
        local hl = vim.api.nvim_set_hl
        hl(0, 'TelescopeNormal', { bg = 'NONE' })
        hl(0, 'TelescopeBorder', { bg = 'NONE' })
        hl(0, 'TelescopePromptNormal', { bg = 'NONE' })
        hl(0, 'TelescopePromptBorder', { bg = 'NONE' })
        hl(0, 'TelescopePreviewNormal', { bg = 'NONE' })
        hl(0, 'TelescopePreviewBorder', { bg = 'NONE' })
        hl(0, 'TelescopeResultsNormal', { bg = 'NONE' })
        hl(0, 'TelescopeResultsBorder', { bg = 'NONE' })
      end
      -- Apply immediately and whenever the colorscheme changes
      set_transparent_telescope()
      vim.api.nvim_create_autocmd('ColorScheme', {
        callback = set_transparent_telescope,
      })

      pcall(telescope.load_extension, 'fzf')
      pcall(telescope.load_extension, 'ui-select')
      pcall(telescope.load_extension, 'project')
      pcall(telescope.load_extension, 'file_browser')
    end,
  },

  { -- Telescope Project Extension
    'nvim-telescope/telescope-project.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    cmd = 'Telescope',
  },

  { -- Telescope File Browser Extension
    'nvim-telescope/telescope-file-browser.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    cmd = 'Telescope',
  },
}
