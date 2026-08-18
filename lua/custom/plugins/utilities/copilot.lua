return {
  { -- GitHub Copilot plugin
    'github/copilot.vim',
    cmd = 'Copilot panel',
    event = 'InsertEnter',
    init = function()
      -- copilot.vim otherwise claims Tab with a nowait accept mapping.
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_enabled = 0
    end,
    config = function()
      vim.keymap.set('i', '<M-\\>', function()
        return vim.fn['copilot#Accept'] ''
      end, {
        expr = true,
        replace_keycodes = false,
        desc = 'Copilot: Accept suggestion',
      })

      vim.keymap.set('n', '<leader>cp', '<cmd>Copilot panel<CR>', {
        noremap = true,
        silent = true,
        desc = 'Open the Copilot panel',
      })

      vim.keymap.set('n', '<leader>ct', function()
        if vim.g.copilot_enabled == 0 then
          vim.cmd 'Copilot enable'
          print 'Copilot enabled'
        else
          vim.cmd 'Copilot disable'
          print 'Copilot disabled'
        end
      end, { desc = '[C]opilot [T]oggle' })

      vim.keymap.set('n', '<leader>cw', function()
        vim.g.copilot_workspace_folders = { vim.fn.getcwd() }
        print('Copilot workspace folder set to: ' .. vim.fn.getcwd())
      end, { desc = 'Set Copilot workspace folder to current directory' })
    end,
  },
}
