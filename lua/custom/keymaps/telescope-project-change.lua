-- /lua/custom/keymaps/telesocpe-project-change.lua
-- -- -- Change project root directory with telescope file browser
--
--
vim.keymap.set('n', '<leader>cr', function()
  Snacks.picker.projects()
end, { desc = '[C]hange project [R]oot' })
