-- LSP configuration
return {
map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
}
