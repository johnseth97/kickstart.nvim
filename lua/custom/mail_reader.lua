local M = {}

function M.setup(opts)
  opts = opts or {}
  local email, state = require 'himalaya.email', require 'himalaya.state'
  local tabs = require 'custom.mail_tabs'
  tabs.setup()
  local original_selected = email.get_selected_envelope
  local reading, records = nil, {}

  local function root_window()
    return state.main_popup and state.main_popup.winid
  end

  email.get_selected_envelope = function()
    return reading and reading.envelope or original_selected()
  end

  email.close = function()
    local previous = reading
    reading, state.email_visible = nil, false
    local win = root_window()
    if win and vim.api.nvim_win_is_valid(win) and state.main then
      vim.api.nvim_set_current_win(win)
      vim.api.nvim_win_set_buf(win, state.main)
      if previous then
        local cursor = vim.deepcopy(previous.cursor)
        for index, envelope in ipairs(state.current_envelopes) do
          if envelope.id == previous.envelope.id then
            cursor[1] = index
            break
          end
        end
        cursor[1] = math.min(cursor[1], vim.api.nvim_buf_line_count(state.main))
        vim.api.nvim_win_set_cursor(win, cursor)
      end
      state.main_popup.border:set_text('top', ' Emails ', 'center')
      require('himalaya.ui.layout').update_page_footer()
      tabs.active = state.main
    end
  end

  local function show(record)
    if not vim.api.nvim_buf_is_valid(record.buf) then
      return
    end
    local win = root_window()
    if not win or not vim.api.nvim_win_is_valid(win) then
      return
    end
    -- Restore the backend context before allowing reply/move/flag actions.
    if state.current_account ~= record.account or state.current_folder ~= record.folder then
      email.close()
      state.current_account, state.current_folder = record.account, record.folder
      require('himalaya.cache').clear()
      require('custom.mail').refresh()
    end
    reading = record
    state.email, state.selected_email_id, state.email_visible = record.buf, record.envelope.id, true
    tabs.active = record.buf
    vim.api.nvim_set_current_win(win)
    vim.api.nvim_win_set_buf(win, record.buf)
    state.main_popup.border:set_text('top', ' Email · q returns to messages ', 'center')
    state.main_popup.border:set_text('bottom', '', 'left')
    if opts.on_show then
      opts.on_show()
    end
  end

  local function fetch(record)
    local request = {}
    record.request = request
    require('himalaya.cli.message').read({
      id = record.envelope.id,
      mailbox = record.folder,
      account = record.account,
      seen = true,
    }, function(err, content)
      vim.schedule(function()
        if record.request ~= request or not tabs.entries[record.buf] or not vim.api.nvim_buf_is_valid(record.buf) then
          return
        end
        vim.bo[record.buf].modifiable = true
        local text = err and 'Could not read this message. Return to the list and reopen to retry.' or (content or ''):gsub('\r\n', '\n'):gsub('\r', '')
        vim.api.nvim_buf_set_lines(record.buf, 0, -1, false, vim.split(text, '\n', { plain = true }))
        vim.bo[record.buf].modifiable, vim.bo[record.buf].modified = false, false
        record.request = nil
        record.loaded = not err
        if not err then
          local seen = false
          for _, flag in ipairs(record.envelope.flags or {}) do
            if flag == 'seen' or (type(flag) == 'table' and flag.iana == 'seen') then
              seen = true
            end
          end
          if not seen then
            record.envelope.flags = record.envelope.flags or {}
            table.insert(record.envelope.flags, { iana = 'seen', raw = '\\Seen' })
            if state.current_account == record.account and state.current_folder == record.folder then
              require('himalaya.ui.envelope_list').render(state.main, state.current_envelopes)
              local cache = require 'himalaya.cache'
              cache.adjust_folder_unread(record.folder, -1)
              if state.sidebar and cache.get_folders() then
                require('himalaya.ui.folder_list').render(state.sidebar, cache.get_folders())
              end
            end
          end
        end
      end)
    end)
  end

  email.open = function()
    local win = root_window()
    if not win or not vim.api.nvim_win_is_valid(win) then
      return
    end
    if reading then
      show(reading)
      return
    end
    local envelope = original_selected()
    if not envelope or not envelope.id then
      return
    end
    local key = vim.json.encode { state.current_account, state.current_folder, envelope.id }
    local record = records[key]
    if not record or not vim.api.nvim_buf_is_valid(record.buf) then
      record = {
        envelope = envelope,
        cursor = vim.api.nvim_win_get_cursor(win),
        account = state.current_account,
        folder = state.current_folder,
        buf = vim.api.nvim_create_buf(true, true),
      }
      records[key] = record
      vim.bo[record.buf].swapfile, vim.bo[record.buf].undofile = false, false
      vim.api.nvim_buf_set_name(record.buf, 'mail://message/' .. record.buf)
      vim.api.nvim_buf_set_lines(record.buf, 0, -1, false, { 'Loading message…' })
      vim.bo[record.buf].filetype = 'himalaya-email'
      vim.bo[record.buf].modifiable = false
      tabs.register(record.buf, {
        kind = 'message',
        title = envelope.subject or '(no subject)',
        focus = function()
          show(record)
          local seen = false
          for _, flag in ipairs(record.envelope.flags or {}) do
            if flag == 'seen' or (type(flag) == 'table' and flag.iana == 'seen') then
              seen = true
            end
          end
          if (not record.loaded or not seen) and not record.request then
            fetch(record)
          end
        end,
        close = function()
          records[key] = nil
          record.request = nil
          if reading == record then
            email.close()
          end
        end,
      })
    else
      record.envelope, record.cursor = envelope, vim.api.nvim_win_get_cursor(win)
    end
    show(record)
    local seen = false
    for _, flag in ipairs(envelope.flags or {}) do
      if flag == 'seen' or (type(flag) == 'table' and flag.iana == 'seen') then
        seen = true
      end
    end
    if (not record.loaded or not seen) and not record.request then
      fetch(record)
    end
  end

  -- Register the actual message-list buffer as the pinned first bar entry.
  M.attach = function()
    tabs.root = state.main
    tabs.register(state.main, { kind = 'root', title = 'Mail', focus = email.close })
    tabs.active = state.main
  end

  local folder = require 'himalaya.folder'
  for _, action in ipairs { 'switch_to', 'next', 'previous' } do
    local original = folder[action]
    folder[action] = function(...)
      email.close()
      return original(...)
    end
  end
end

return M
