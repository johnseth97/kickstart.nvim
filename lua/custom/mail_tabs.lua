-- Mail-only buffer-bar entries. Closing a tab never operates on server mail.
local M = { entries = {}, serial = 0 }
local focusing = false

local function redraw()
  vim.cmd.redrawtabline()
end

function M.ordered()
  local result = {}
  for buf, entry in pairs(M.entries) do
    if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
      result[#result + 1] = entry
    end
  end
  table.sort(result, function(a, b)
    return a.order < b.order
  end)
  return result
end

function M.register(buf, entry)
  M.serial = M.serial + 1
  entry.buf, entry.order = buf, entry.kind == 'root' and 0 or M.serial
  M.entries[buf] = entry
  vim.bo[buf].buflisted, vim.bo[buf].bufhidden = true, 'hide'
  redraw()
end

function M.focus(buf)
  local entry = M.entries[buf]
  if not entry or focusing then
    return
  end
  focusing = true
  local ok, err = pcall(entry.focus)
  focusing = false
  if not ok then
    error(err)
  end
  M.active = buf
  redraw()
end

function M.focus_index(index)
  local entry = M.ordered()[index]
  if entry then
    M.focus(entry.buf)
  end
end

function M.close(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local entry = M.entries[buf]
  if not entry or entry.kind == 'root' then
    return
  end
  local function discard()
    if entry.close then
      entry.close()
    end
    M.entries[buf] = nil
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
    redraw()
  end
  if entry.kind == 'draft' and vim.bo[buf].modified then
    vim.ui.select({ 'Cancel', 'Discard draft view' }, { prompt = 'Discard unsaved changes? (:w saves a server draft)' }, function(choice)
      if choice == 'Discard draft view' then
        discard()
      end
    end)
  else
    discard()
  end
end

function M.register_draft(buf, account)
  M.register(buf, {
    kind = 'draft',
    title = 'Draft · ' .. account,
    focus = function()
      local wins = vim.fn.win_findbuf(buf)
      if #wins > 0 then
        vim.api.nvim_set_current_win(wins[1])
      else
        vim.cmd 'tabnew'
        vim.api.nvim_set_current_buf(buf)
      end
    end,
    close = function()
      local wins = vim.fn.win_findbuf(buf)
      for _, win in ipairs(wins) do
        local tab = vim.api.nvim_win_get_tabpage(win)
        if #vim.api.nvim_tabpage_list_wins(tab) == 1 and #vim.api.nvim_list_tabpages() > 1 then
          vim.api.nvim_set_current_win(win)
          vim.bo[buf].modified = false
          vim.cmd 'tabclose'
        end
      end
      if M.root then
        M.focus(M.root)
      end
    end,
  })
  M.active = buf
  vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'BufLeave' }, {
    buffer = buf,
    callback = function()
      local entry = M.entries[buf]
      if not entry then
        return
      end
      entry.title = 'Draft · ' .. account
      for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
        if line == '' then
          break
        end
        local subject = line:match '^Subject:%s*(.+)'
        if subject then
          entry.title = 'Draft · ' .. subject
          redraw()
          break
        end
      end
      redraw()
    end,
  })
end

function M.label(buf)
  local entry = M.entries[buf]
  if not entry then
    return ''
  end
  -- Cokeline can truncate text after receiving it. Use a literal percent glyph
  -- rather than %% escaping, which truncation could split into statusline code.
  return ((entry.title or '(no subject)'):gsub('[%z\1-\31\127]', ' '):gsub('%%', '％'))
end

function M.subject(buf, width)
  local text = M.label(buf)
  if M.entries[buf].kind == 'draft' then
    text = text:gsub('^Draft · ', '')
  end
  if vim.fn.strdisplaywidth(text) <= width then
    return text
  end
  local count = vim.fn.strchars(text)
  while count > 0 and vim.fn.strdisplaywidth(vim.fn.strcharpart(text, 0, count)) > width - 1 do
    count = count - 1
  end
  local shortened = vim.fn.strcharpart(text, 0, count)
  local word = shortened:match '^(.*)%s+%S*$'
  if word and vim.fn.strdisplaywidth(word) >= (width - 1) * 0.6 then
    shortened = word
  end
  return shortened:gsub('%s+$', '') .. '…'
end

function M.setup()
  vim.api.nvim_create_autocmd('BufEnter', {
    callback = function(event)
      if M.entries[event.buf] and not focusing then
        M.focus(event.buf)
      end
    end,
  })
  vim.api.nvim_create_autocmd('BufDelete', {
    callback = function(event)
      local entry = M.entries[event.buf]
      M.entries[event.buf] = nil
      if entry and entry.close and entry.kind ~= 'draft' then
        entry.close()
      end
      redraw()
    end,
  })
  if vim.g.dotfiles_mail_mode then
    for index = 1, 10 do
      local target = index
      vim.keymap.set('n', '<C-b>' .. (index == 10 and '0' or index), function()
        M.focus_index(target)
      end, { desc = 'Open mail tab ' .. index })
    end
    vim.keymap.set('n', '<C-b>x', function()
      M.close()
    end, { desc = 'Close mail tab view' })
  end
end

return M
