local M = {}

M.smart_toggle_term = function()
  if vim.fn.mode() == 't' then
    -- If we're in terminal mode, just toggle (close)
    vim.cmd 'ToggleTerm'
  else
    -- Toggleterm opens a split from the current window. Avoid splitting an
    -- Agentic panel, while retaining direct terminal-mode close behavior.
    require('custom.window').toggle_terminal()
  end
end

return M
