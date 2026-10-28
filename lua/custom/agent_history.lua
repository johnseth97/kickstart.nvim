local M = {}

local function available_providers()
  local Config = require 'agentic.config'
  local ACPHealth = require 'agentic.acp.acp_health'
  local providers = {}

  for id, provider in pairs(Config.acp_providers) do
    if ACPHealth.is_command_available(provider.command) then
      providers[#providers + 1] = {
        id = id,
        name = provider.name or id,
      }
    end
  end

  table.sort(providers, function(a, b)
    return a.name:lower() < b.name:lower()
  end)

  return providers
end

local function align_options_navigation()
  local buffer = vim.api.nvim_get_current_buf()
  local down = vim.fn.maparg('j', 'n', false, true).callback
  local up = vim.fn.maparg('k', 'n', false, true).callback

  if type(down) ~= 'function' or type(up) ~= 'function' then
    return
  end

  local opts = { buffer = buffer, silent = true }
  vim.keymap.set('n', 'j', '<Nop>', opts)
  vim.keymap.set('n', 'k', down, opts)
  vim.keymap.set('n', 'l', up, opts)
  vim.keymap.set('n', ';', '<Nop>', opts)
end

local function select_provider(prompt, callback)
  local providers = available_providers()

  if #providers == 0 then
    vim.notify('No configured Agentic providers are available', vim.log.levels.WARN)
    return
  end

  vim.ui.select(providers, {
    prompt = prompt,
    format_item = function(item)
      return item.name
    end,
  }, callback)
end

function M.new()
  select_provider('New conversation with:', function(provider)
    if not provider then
      return
    end

    local SessionRegistry = require 'agentic.session_registry'
    SessionRegistry.create_with_current_session_guard(function(session)
      session:add_selection_or_file_to_session()
      SessionRegistry.show_session(session.session_key)
      session:on_session_ready(function(ready_session)
        ready_session.config_options:_show_options_modal()
        vim.cmd 'stopinsert'
        align_options_navigation()
      end)
    end, provider.id)
  end)
end

function M.restore()
  select_provider('History provider:', function(provider)
    if not provider then
      return
    end

    -- List against the chosen provider's agent directly. Creating a session
    -- just to borrow its agent would leave an empty one behind on every
    -- cancelled pick, and the restore below builds its own.
    local agent = require('agentic.acp.agent_instance').get_instance(provider.id)
    if not agent then
      vim.notify('Could not start ' .. provider.name, vim.log.levels.WARN)
      return
    end

    agent:when_ready(function()
      agent:list_sessions(vim.fn.getcwd(), function(result, err)
        vim.schedule(function()
          if err or not result then
            vim.notify('Failed to list ' .. provider.name .. ' history: ' .. (err and err.message or 'unknown error'), vim.log.levels.WARN)
            return
          end

          local items = {}
          for _, saved in ipairs(result.sessions or {}) do
            local date = saved.updatedAt and saved.updatedAt:sub(1, 16):gsub('T', ' ') or 'unknown date'
            items[#items + 1] = {
              display = string.format('%s - %s', date, saved.title or '(no title)'),
              session_id = saved.sessionId,
            }
          end

          if #items == 0 then
            vim.notify('No saved ' .. provider.name .. ' conversations found', vim.log.levels.INFO)
            return
          end

          local capabilities = agent.agent_capabilities
          if not capabilities or not capabilities.loadSession then
            vim.notify(provider.name .. ' does not support loading sessions', vim.log.levels.WARN)
            return
          end

          vim.ui.select(items, {
            prompt = provider.name .. ' history:',
            format_item = function(item)
              return item.display
            end,
          }, function(choice)
            if not choice then
              return
            end

            -- `restore_by_id` resolves its own context from the *current*
            -- session, which is not this provider, so go through `replace`
            -- with an explicit agent to land in the provider that was picked.
            require('agentic.session_registry').replace(nil, provider.id, { kind = 'load', session_id = choice.session_id }, { agent = agent })
          end)
        end)
      end)
    end, function(ready_err)
      vim.notify('Could not reach ' .. provider.name .. ': ' .. (ready_err and ready_err.message or 'provider unavailable'), vim.log.levels.WARN)
    end)
  end)
end

function M.pick()
  vim.ui.select({
    { name = 'New conversation', action = M.new },
    { name = 'Resume saved conversation', action = M.restore },
  }, {
    prompt = 'Agent sessions:',
    format_item = function(item)
      return item.name
    end,
  }, function(choice)
    if choice then
      choice.action()
    end
  end)
end

return M
