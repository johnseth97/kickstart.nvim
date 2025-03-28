-- helpers/lsp_util.lua
local M = {}

function M.is_deno_project(root_dir)
  local util = require 'lspconfig.util'
  return util.root_pattern('deno.json', 'deno.jsonc')(root_dir) ~= nil
end

return M
