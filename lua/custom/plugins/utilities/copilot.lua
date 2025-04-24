return {
  { -- GitHub Copilot plugin
    'github/copilot.vim',
    cmd = 'Copilot panel',
    config = function()
      -- Set up the keymap to open the Copilot panel using the correct command
      vim.api.nvim_set_keymap('n', '<leader>cp', '<cmd>Copilot panel<CR>', { noremap = true, silent = true, desc = 'Open the Copilot panel' })
      vim.keymap.set('n', '<leader>cw', function()
        -- Setting the global Vim variable from Lua
        vim.g.copilot_workspace_folders = { vim.fn.getcwd() }

        -- Optionally, print a confirmation message
        print('Copilot workspace folder set to: ' .. vim.fn.getcwd())
      end, { desc = 'Set Copilot workspace folder to current directory' })
    end,
  },
}
