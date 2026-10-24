-- Topcoat embeds a token DSL, not an ordinary Rust block, in view!/attributes!.
-- Reuse Rust's grammar while giving these projects their own query set.
local M = {}
local initialized = false

function M.start(bufnr)
  if vim.bo[bufnr].filetype ~= 'rust' or not vim.fs.root(bufnr, 'Topcoat.toml') then
    return false
  end
  if not initialized then
    local parser = vim.api.nvim_get_runtime_file('parser/rust.*', false)[1]
    if not parser then return false end
    vim.treesitter.language.add('topcoat_rust', { path = parser, symbol_name = 'rust' })
    local files = vim.treesitter.query.get_files('rust', 'injections')
    local parts = {}
    for _, file in ipairs(files) do
      local source = table.concat(vim.fn.readfile(file), '\n')
      source = source:gsub('(#not%-any%-of%? @_macro_name)', '%1 "view" "attributes" "module_router" "stylesheet"')
      source = source:gsub('injection.language "rust"', 'injection.language "topcoat_rust"')
      table.insert(parts, source)
    end
    table.insert(parts, [[
(token_tree
  "@" . (identifier) . "=" .
  (string_literal (string_content) @injection.content)
  (#set! injection.language "javascript"))
(token_tree
  "<" . (identifier) @_tag . ">" .
  (string_literal (string_content) @injection.content)
  (#eq? @_tag "script")
  (#set! injection.language "javascript"))
]])
    vim.treesitter.query.set('topcoat_rust', 'injections', table.concat(parts, '\n'))
    initialized = true
  end
  -- rust-analyzer classifies embedded JavaScript as a Rust string at priority
  -- 125. Keep query priorities in the supported range and let Tree-sitter
  -- handle these mixed-language buffers. Other LSP features remain enabled.
  vim.lsp.semantic_tokens.enable(false, { bufnr = bufnr })
  vim.treesitter.start(bufnr, 'topcoat_rust')
  return true
end

return M
