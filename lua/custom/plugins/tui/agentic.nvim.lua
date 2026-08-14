return {
  'carlos-algms/agentic.nvim',
  keys = {
    {
      '<leader>A',
      function()
        require('agentic').toggle()
      end,
      desc = 'Agent: Toggle panel',
    },
    {
      '<leader>aa',
      function()
        require('agentic').new_session_with_provider()
      end,
      desc = 'Agent: New session (choose agent)',
    },
    {
      '<leader>ai',
      function()
        require('agentic').add_selection_or_file_to_context()
      end,
      mode = { 'n', 'v' },
      desc = 'Agent: Add file or selection',
    },
    {
      '<leader>ah',
      function()
        require('custom.agent_history').pick()
      end,
      desc = 'Agent: History',
    },
    {
      '<leader>aA',
      function()
        require('agentic').new_session { provider = 'claude-agent-acp' }
      end,
      desc = 'Agent: Anthropic Claude',
    },
    {
      '<leader>aC',
      function()
        require('agentic').new_session { provider = 'codex-acp' }
      end,
      desc = 'Agent: ChatGPT Codex',
    },
    {
      '<leader>aL',
      function()
        require('agentic').new_session { provider = 'opencode-acp' }
      end,
      desc = 'Agent: New local session',
    },
  },
  opts = {
    provider = 'opencode-acp',
    acp_providers = {
      ['claude-agent-acp'] = {
        name = 'Anthropic Claude',
        command = 'claude-agent-acp',
      },
      ['codex-acp'] = {
        name = 'ChatGPT Codex',
        command = 'codex-acp',
      },
      ['opencode-acp'] = {
        name = 'Local llama-swap',
        command = 'opencode',
        args = { 'acp' },
      },
    },
    provider_switcher = {
      hide_unhealthy_providers = true,
    },
    windows = {
      position = 'right',
      width = '40%',
    },
  },
}
