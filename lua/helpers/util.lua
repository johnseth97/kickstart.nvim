local M = {}

M.smart_toggle_term = function()
  local term = require('toggleterm.terminal').get(1)

  if vim.fn.mode() == 't' then
    -- If we're in terminal mode, just toggle (close)
    vim.cmd 'ToggleTerm'
  else
    -- If already open, hide it — else open it
    if term and term:is_open() then
      vim.cmd 'ToggleTerm'
    else
      vim.cmd 'ToggleTerm'
      vim.cmd 'startinsert' -- optional: auto-enter insert mode
    end
  end
end

return M
