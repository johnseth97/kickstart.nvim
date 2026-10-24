local function capsule_header(window_name)
  return function(parts, session_state)
    local text = require('agentic.ui.window_decoration')._build_default_header(window_name, parts, session_state)
    if window_name == 'input' then
      text = text .. ' | stop: <C-s> | options: <localLeader>o'
    end
    -- Agentic installs this value as a winbar/statusline format string.
    text = text:gsub('%%', '%%%%')
    return '%#AgenticCapsuleEdge#%#AgenticCapsule# ' .. text .. ' %#AgenticCapsuleEdge#'
  end
end

local context_glyphs = { '○', '󰪞', '󰪟', '󰪠', '󰪡', '󰪢', '󰪣', '󰪤', '󰪥' }

local function context_glyph(percent)
  -- Nerd Font's circle-slice glyphs provide eight useful, compact stages.
  return context_glyphs[math.min(math.ceil(percent / 12.5) + 1, #context_glyphs)]
end

local function chat_header(parts, session_state)
  local header = { parts.title }

  local usage = ''
  if session_state then
    -- The provider already appears in the model display name. Showing both
    -- turns "Local llama-swap" into three variations of the same label.
    local model = session_state:get_model_name()
    if model and model ~= '' then
      model = model:gsub('^.*/', ''):gsub('%s*%b()', '')
      table.insert(header, model)
    end

    local mode = session_state:get_mode_name()
    if mode and mode ~= '' then
      table.insert(header, mode)
    end

    local used = session_state:get_context_used_raw()
    local size = session_state:get_context_size_raw()
    if used and size and size > 0 then
      local percent = math.floor((used / size) * 100 + 0.5)
      table.insert(header, string.format('%s/%s', session_state:get_context_used(), session_state:get_context_size()))
      usage = context_glyph(percent)
    end
  end

  local text = table.concat(header, ' · '):gsub('%%', '%%%%')
  local right = usage ~= '' and ('%= ' .. usage .. ' ') or ''
  return '%#AgenticCapsuleEdge#%#AgenticCapsule# ' .. text .. right .. '%#AgenticCapsuleEdge#'
end

return {
  'carlos-algms/agentic.nvim',
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
    settings = {
      -- Keep focus in the prompt after sending so follow-up turns are frictionless.
      move_cursor_to_chat_on_submit = false,
    },
    hooks = {
      -- Keep the in-editor notification, and use macOS only when Ghostty is
      -- unfocused so the desktop banner is an off-screen attention signal.
      -- ACP sends this only when an agent is blocked on an approval. The
      -- notification persists until the agent's eventual completion replaces it.
      on_request_permission = function(data)
        local tool = data.request.toolCall
        local label = tool.title or tool.kind or 'action'
        require('custom.notifications').notify('Waiting for your approval: ' .. label, vim.log.levels.WARN, {
          title = 'Agentic',
          id = 'agentic-session-' .. data.session_key,
          timeout = false,
          native = true,
          native_title = 'Agentic: approval needed',
        })
      end,
      -- Fires for foreground and background sessions. Reusing the session id
      -- clears a persistent approval notice and leaves a short final status.
      on_response_complete = function(data)
        require('custom.notifications').notify(
          data.success and 'Agent finished responding' or 'Agent stopped with an error',
          data.success and vim.log.levels.INFO or vim.log.levels.ERROR,
          {
            title = 'Agentic',
            id = 'agentic-session-' .. data.session_key,
            timeout = 5000,
            native = true,
            native_title = data.success and 'Agentic: response complete' or 'Agentic: error',
          }
        )
      end,
    },
    headers = {
      chat = chat_header,
      input = capsule_header 'input',
      code = capsule_header 'code',
      files = capsule_header 'files',
      diagnostics = capsule_header 'diagnostics',
      todos = capsule_header 'todos',
    },
    windows = {
      position = 'right',
      width = '44%',
    },
  },
  config = function(_, opts)
    require('agentic').setup(opts)

    local function apply_capsule_theme()
      local c = require('custom.omarchy_theme').colors()
      vim.api.nvim_set_hl(0, 'AgenticTitle', { fg = c.fg, bold = true })
      vim.api.nvim_set_hl(0, 'AgenticCapsule', { fg = c.fg, bg = c.fg_gutter, bold = true })
      vim.api.nvim_set_hl(0, 'AgenticCapsuleEdge', { fg = c.fg_gutter })
    end

    apply_capsule_theme()
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = vim.api.nvim_create_augroup('AgenticCapsuleTheme', { clear = true }),
      callback = apply_capsule_theme,
    })
  end,
}
