return {

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {
        markdown = { 'markdownlint' },
        lua = { 'luacheck' },
        sh = { 'shellcheck' },
        dockerfile = { 'hadolint' },
        yaml = { 'yamllint' },
        typescript = { 'eslint' },
        javascript = { 'eslint' },
        javascriptreact = { 'eslint' },
        typescriptreact = { 'eslint' },
        jsonn = { 'eslint' },
      }

      -- Override luacheck to recognize `vim` and other globals
      lint.linters.luacheck = {
        cmd = 'luacheck',
        stdin = true,
        args = {
          '--globals',
          'vim', -- whitelist `vim` global
          '--globals',
          'use', -- whitelist `use` if present
          '--globals',
          'reload', -- whitelist other custom globals
          '--', -- end of globals flags
          '-', -- read from stdin
        },
        stream = 'stdout',
        ignore_exitcode = true,
        parser = require('lint.parser').from_errorformat('%f:%l:%c: %m', {
          source = 'luacheck',
        }),
      }

      -- Create autocommand which carries out the actual linting
      -- on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
