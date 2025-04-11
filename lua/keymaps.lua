vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
--
-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
--
-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
--
-- Remap jkl; to hjkl in normal mode
vim.keymap.set({ 'n', 'o' }, 'j', 'h', { noremap = true, desc = 'Move cursor left' })
vim.keymap.set({ 'n', 'o' }, 'k', 'j', { noremap = true, desc = 'Move cursor down' })
vim.keymap.set({ 'n', 'o' }, 'l', 'k', { noremap = true, desc = 'Move cursor up' })
vim.keymap.set({ 'n', 'o' }, ';', 'l', { noremap = true, desc = 'Move cursor right' })
--
-- Remap jkl; to hjkl in visual mode
vim.keymap.set({ 'v', 'o' }, 'j', 'h', { noremap = true, desc = 'Move cursor left' })
vim.keymap.set({ 'v', 'o' }, 'k', 'j', { noremap = true, desc = 'Move cursor down' })
vim.keymap.set({ 'v', 'o' }, 'l', 'k', { noremap = true, desc = 'Move cursor up' })
vim.keymap.set({ 'v', 'o' }, ';', 'l', { noremap = true, desc = 'Move cursor right' })
--
--Disable arrow keys in normal mode
vim.keymap.set({ 'n', 'o' }, '<left>', '<cmd>echo "Use j to move!!"<CR>')
vim.keymap.set({ 'n', 'o' }, '<right>', '<cmd>echo "Use ; to move!!"<CR>')
vim.keymap.set({ 'n', 'o' }, '<up>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set({ 'n', 'o' }, '<down>', '<cmd>echo "Use k to move!!"<CR>')
--
-- Remap split navigation
vim.keymap.set('n', '<C-j>', '<C-w>h', { noremap = true, desc = 'Move focus to the left split' })
vim.keymap.set('n', '<C-k>', '<C-w>j', { noremap = true, desc = 'Move focus to the bottom split' })
vim.keymap.set('n', '<C-l>', '<C-w>k', { noremap = true, desc = 'Move focus to the top split' })
vim.keymap.set('n', '<C-;>', '<C-w>l', { noremap = true, desc = 'Move focus to the right split' })

-- Reload the neovim config file
vim.keymap.set('n', '<leader>sv', '<cmd>source $MYVIMRC<CR>', { desc = 'Reload the Neovim config file' })

-- Launch the dashboard
vim.keymap.set('n', '<leader>db', function()
  vim.cmd 'Dashboard'
end, { desc = '[D]ash[b]oard' })

-- Telescope file browser with project change
vim.keymap.set('n', '<leader>fb', function()
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
end, { desc = 'File Browser with Project Change' })
