return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo', 'Format' },
  keys = {
    {
      '<leader>F',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = { c = true, cpp = true }
      local lsp_format_opt
      if disable_filetypes[vim.bo[bufnr].filetype] then
        lsp_format_opt = 'never'
      else
        lsp_format_opt = 'fallback'
      end
      return {
        timeout_ms = vim.bo[bufnr].filetype == 'rust' and 3000 or 500,
        lsp_format = lsp_format_opt,
      }
    end,
    formatters_by_ft = {
      c = { 'clang-format' },
      cpp = { 'clang-format' },
      lua = { 'stylua' },
      rust = { 'rustfmt', 'topcoat' },
      -- Conform can also run multiple formatters sequentially
      -- python = { "isort", "black" },
      --
      -- You can use 'stop_after_first' to run the first available formatter from the list
      javascript = { 'prettierd', 'prettier', stop_after_first = true },
      javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
      typescript = { 'prettierd', 'prettier', stop_after_first = true },
      typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
      json = { 'prettierd', 'prettier', stop_after_first = true },
    },
    formatters = {
      topcoat = {
        command = vim.fn.expand '~/.cargo/bin/topcoat',
        args = { 'fmt', '--stdin' },
        stdin = true,
        require_cwd = true,
        cwd = function(self, ctx)
          return require('conform.util').root_file { 'Topcoat.toml' }(self, ctx)
        end,
      },
      ['clang-format'] = {
        prepend_args = function(_, ctx)
          local config = vim.fs.find({ '.clang-format', '_clang-format' }, {
            path = vim.fs.dirname(ctx.filename),
            upward = true,
          })[1]
          -- Prefer project style; use our defaults for projects without one.
          return { '--style=file:' .. (config or vim.fn.stdpath 'config' .. '/clang-format.yaml') }
        end,
      },
    },
  },
}
