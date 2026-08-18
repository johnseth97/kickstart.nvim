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
