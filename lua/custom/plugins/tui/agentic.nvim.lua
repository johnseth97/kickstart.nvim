local function capsule_header(window_name)
  return function(parts, session_state)
    local text = require('agentic.ui.window_decoration')._build_default_header(window_name, parts, session_state)
    return '%#AgenticCapsuleEdge#%#AgenticCapsule# ' .. text .. ' %#AgenticCapsuleEdge#'
  end
end

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
    headers = {
      chat = capsule_header 'chat',
      input = capsule_header 'input',
      code = capsule_header 'code',
      files = capsule_header 'files',
      diagnostics = capsule_header 'diagnostics',
      todos = capsule_header 'todos',
    },
    windows = {
      position = 'right',
      width = '40%',
    },
  },
  config = function(_, opts)
    require('agentic').setup(opts)

    local function apply_capsule_theme()
      vim.api.nvim_set_hl(0, 'AgenticTitle', { fg = '#c0caf5', bold = true })
      vim.api.nvim_set_hl(0, 'AgenticCapsule', { fg = '#c0caf5', bg = '#3b4261', bold = true })
      vim.api.nvim_set_hl(0, 'AgenticCapsuleEdge', { fg = '#3b4261' })
    end

    apply_capsule_theme()
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = vim.api.nvim_create_augroup('AgenticCapsuleTheme', { clear = true }),
      callback = apply_capsule_theme,
    })
  end,
}
