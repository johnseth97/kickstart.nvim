-- /lua/custom/keymaps/telesocpe-project-change.lua
-- -- -- Change project root directory with telescope file browser
--
--
vim.keymap.set('n', '<leader>cr', function()
  require('telescope').extensions.file_browser.file_browser {
    path = vim.fn.getcwd(),
    respect_gitignore = false,
    hidden = true,
    grouped = true,
    mappings = {
      ['i'] = {
        ['<C-t>'] = function(prompt_bufnr)
          local action_state = require 'telescope.actions.state'
          local actions = require 'telescope.actions'

          local selected_entry = action_state.get_selected_entry()
          local path = selected_entry.path

          -- Change Neovim's working directory globally
          if vim.fn.isdirectory(path) == 1 then
            vim.api.nvim_set_current_dir(path)
            print('Working directory changed to: ' .. path)

            -- Update nvim-tree to reflect the new working directory
            require('nvim-tree.api').tree.change_root(path)
          end

          actions.close(prompt_bufnr)
        end,
      },
    },
  }
end, { desc = '[C]hange Project [R]oot Directory' })
