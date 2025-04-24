-- lua/custom/plugins/debug/dap.lua
return {
  'mfussenegger/nvim-dap',
  -- only load when you invoke one of these commands:
  cmd = {
    'DapContinue',
    'DapToggleBreakpoint',
    'DapStepOver',
    'DapStepInto',
    'DapStepOut',
    'DapRunToCursor',
    'DapTerminate',
    'DapToggleRepl',
  },
  init = function()
    -- register keymaps now, so they work even though dap.nvim isn’t loaded yet
    local km = vim.keymap.set
    km('n', '<F5>', '<Cmd>DapContinue<CR>', { desc = 'Debug: Continue' })
    km('n', '<F1>', '<Cmd>DapStepInto<CR>', { desc = 'Debug: Step Into' })
    km('n', '<F2>', '<Cmd>DapStepOver<CR>', { desc = 'Debug: Step Over' })
    km('n', '<F3>', '<Cmd>DapStepOut<CR>', { desc = 'Debug: Step Out' })
    km('n', '<leader>b', '<Cmd>DapToggleBreakpoint<CR>', { desc = 'Debug: Toggle Breakpoint' })
    km('n', '<leader>B', function()
      require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'Debug: Set Conditional Breakpoint' })
    km('n', '<F7>', '<Cmd>lua require("dapui").toggle()<CR>', { desc = 'Debug: Toggle UI' })
  end,

  dependencies = {
    -- 1) dap-ui
    {
      'rcarriga/nvim-dap-ui',
      -- load immediately after dap.nvim itself
      after = 'nvim-dap',
      config = function()
        require('dapui').setup {
          icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
          controls = {
            icons = {
              pause = '⏸',
              play = '▶',
              step_into = '⏎',
              step_over = '⏭',
              step_out = '⏮',
              step_back = 'b',
              run_last = '▶▶',
              terminate = '⏹',
              disconnect = '⏏',
            },
          },
        }
        local dap, dapui = require 'dap', require 'dapui'
        dap.listeners.after.event_initialized['dapui_config'] = dapui.open
        dap.listeners.before.event_terminated['dapui_config'] = dapui.close
        dap.listeners.before.event_exited['dapui_config'] = dapui.close
      end,
    },

    -- 2) Go adapter
    {
      'leoluz/nvim-dap-go',
      ft = 'go',
      config = function()
        require('dap-go').setup { delve = { detached = vim.fn.has 'win32' == 0 } }
      end,
    },

    -- 3) Mason integration for DAP adapters
    {
      'jay-babu/mason-nvim-dap.nvim',
      after = 'nvim-dap',
      dependencies = { 'williamboman/mason.nvim' },
      config = function()
        require('mason-nvim-dap').setup {
          automatic_installation = true,
          ensure_installed = { 'js-debug-adapter', 'delve' },
        }
      end,
    },

    -- 5) Some extra helper you had in your deps
    'nvim-neotest/nvim-nio',
  },
}
