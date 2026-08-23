local M = {}

local function is_editor_window(winid)
  local bufnr = vim.api.nvim_win_get_buf(winid)
  local config = vim.api.nvim_win_get_config(winid)
  return config.relative == '' and vim.bo[bufnr].buftype == '' and not vim.bo[bufnr].filetype:match '^Agentic'
end

---Run a split-opening action from a normal editor window when it was invoked
---from an Agentic panel. This keeps the Agentic column as a single pane.
---@param action fun()
function M.from_editor(action)
  if is_editor_window(vim.api.nvim_get_current_win()) then
    return action()
  end

  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_editor_window(winid) then
      return vim.api.nvim_win_call(winid, action)
    end
  end

  return action()
end

function M.toggle_explorer()
  local explorers = Snacks.picker.get { source = 'explorer' }
  if #explorers > 0 then
    for _, explorer in ipairs(explorers) do
      explorer:close()
    end
    return
  end

  M.from_editor(function()
    Snacks.explorer()
  end)
end

function M.toggle_terminal()
  M.from_editor(function()
    vim.cmd 'ToggleTerm'
  end)
end

return M
