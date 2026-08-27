local M = {}

local ghostty_bundle_id = 'com.mitchellh.ghostty'
local is_macos = (vim.uv or vim.loop).os_uname().sysname == 'Darwin'

local function sanitize(value)
  return tostring(value or ''):gsub('[%z\7\27;\r\n]', ' '):gsub('%s+', ' '):gsub('^%s+', ''):gsub('%s+$', '')
end

local function write_to_tty(tty_path, sequence)
  local ok, tty = pcall(io.open, tty_path, 'w')
  if not ok or not tty then
    return
  end
  tty:write(sequence)
  tty:flush()
  tty:close()
end

local function write_ghostty_notification(title, message)
  local text = sanitize(title)
  local body = sanitize(message)
  if body ~= '' then
    text = text ~= '' and text .. ' — ' .. body or body
  end
  if text == '' then
    return
  end

  -- OSC 9 is Ghostty's documented desktop-notification sequence. Send to the
  -- terminal directly so Neovim does not render the control bytes in a buffer.
  local sequence = '\27]9;' .. text .. '\27\\'

  if vim.env.TMUX and vim.env.TMUX ~= '' then
    -- Route through tmux's own DCS passthrough (`set -g allow-passthrough on`
    -- in tmux.conf) rather than writing straight to the attached client's
    -- tty. A direct write to the client tty races tmux's own writes to that
    -- same physical terminal -- interleaved bytes there produced a corrupted
    -- escape sequence that blanked the status line and even flipped the
    -- terminal's background opacity, until a manual terminal reset. Writing
    -- to /dev/tty (this pane's own pty) instead hands the bytes to tmux,
    -- which serializes them into its own output stream safely.
    local wrapped = '\27Ptmux;' .. sequence:gsub('\27', '\27\27') .. '\27\\'
    write_to_tty('/dev/tty', wrapped)
    return
  end

  write_to_tty('/dev/tty', sequence)
end

local function ghostty_is_frontmost(callback)
  if not is_macos or vim.fn.executable 'osascript' == 0 then
    callback(nil)
    return
  end

  vim.system({
    'osascript',
    '-l',
    'JavaScript',
    '-e',
    'ObjC.import("AppKit"); $.NSWorkspace.sharedWorkspace.frontmostApplication.bundleIdentifier.js',
  }, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        callback(nil)
        return
      end
      callback(vim.trim(result.stdout) == ghostty_bundle_id)
    end)
  end)
end

local function tmux_pane_is_active(callback)
  local pane_id = vim.env.TMUX_PANE
  if not (vim.env.TMUX and pane_id and pane_id ~= '') then
    callback(nil)
    return
  end

  vim.system({
    'tmux',
    'display-message',
    '-p',
    '-t',
    pane_id,
    '#{session_attached} #{window_active} #{pane_active}',
  }, { text = true }, function(result)
    vim.schedule(function()
      local state = result.code == 0 and vim.trim(result.stdout) or ''
      local attached, window, pane = state:match '^(%d+) ([01]) ([01])$'
      if attached then
        callback(attached ~= '0' and window == '1' and pane == '1')
      else
        callback(nil)
      end
    end)
  end)
end

---Show a native Ghostty/macOS notification.
---When `when_unfocused` is true (the default), it is suppressed only while
---Ghostty is frontmost and this Neovim tmux pane is selected. A failed focus
---or tmux-state check is also suppressed deliberately: the in-editor
---notification still provides the reliable fallback.
---@param title string
---@param message? string
---@param opts? { when_unfocused?: boolean }
function M.native(title, message, opts)
  opts = opts or {}
  if opts.when_unfocused == false then
    write_ghostty_notification(title, message)
    return
  end

  tmux_pane_is_active(function(is_active)
    -- A different tmux pane/window is foreground work, even if its Ghostty
    -- window is focused, so surface the agent result as a native notification.
    if is_active == false then
      write_ghostty_notification(title, message)
      return
    end

    ghostty_is_frontmost(function(is_frontmost)
      if is_frontmost == false then
        write_ghostty_notification(title, message)
      end
    end)
  end)
end

---Show the normal Neovim notification and, when requested, an unfocused-only
---native Ghostty notification. Other plugins can use this as their common
---notification entry point.
---@param message string
---@param level? number
---@param opts? table
function M.notify(message, level, opts)
  opts = opts or {}
  local native = opts.native
  local native_title = opts.native_title or opts.title or 'Neovim'
  local native_when_unfocused = opts.native_when_unfocused
  local notify_opts = vim.tbl_extend('force', {}, opts)
  notify_opts.native = nil
  notify_opts.native_title = nil
  notify_opts.native_when_unfocused = nil

  vim.notify(message, level, notify_opts)

  if native then
    M.native(native_title, message, { when_unfocused = native_when_unfocused ~= false })
  end
end

return M
