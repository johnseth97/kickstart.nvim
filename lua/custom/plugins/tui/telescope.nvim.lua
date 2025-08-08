return {
  { -- Telescope core
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    branch = '0.1.x',
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
      local actions = require 'telescope.actions'
      local builtin = require 'telescope.builtin'

      telescope.setup {
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
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

      -- Optional: wrap search pickers
      local function make_toggleable(picker_fn)
        return function(initial_opts)
          local opts = vim.deepcopy(initial_opts or {})
          local showDot = opts.hidden or false
          local noIgnore = opts.no_ignore or false

          opts.attach_mappings = function(_, map)
            map({ 'i', 'n' }, '<C-h>', function(prompt_bufnr)
              actions.close(prompt_bufnr)
              showDot = not showDot
              opts.hidden = showDot
              picker_fn(opts)
            end)
            map({ 'i', 'n' }, '<C-i>', function(prompt_bufnr)
              actions.close(prompt_bufnr)
              noIgnore = not noIgnore
              opts.no_ignore = noIgnore
              picker_fn(opts)
            end)
            return true
          end

          picker_fn(opts)
        end
      end

      local toggle_find_files = make_toggleable(builtin.find_files)
      local toggle_live_grep = make_toggleable(builtin.live_grep)

      -- Keymaps
      vim.keymap.set('n', '<leader>sf', toggle_find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sg', toggle_live_grep, { desc = '[S]earch by [G]rep' })

      -- Regular keymaps
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      -- Special overrides
      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })

      vim.keymap.set('n', '<leader>sc', function()
        builtin.find_files {
          prompt_title = 'Dotfiles',
          cwd = vim.fn.expand '~/.dotfiles',
          hidden = true,
        }
      end, { desc = '[S]earch Dotfiles/[C]onfig' })
    end,
  },

  { -- Telescope Project Extension
    'nvim-telescope/telescope-project.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    config = function()
      require('telescope').load_extension 'project'
    end,
    cmd = 'Telescope',
  },

  { -- Telescope File Browser Extension
    'nvim-telescope/telescope-file-browser.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    config = function()
      require('telescope').load_extension 'file_browser'
    end,
    cmd = 'Telescope',
  },
}
