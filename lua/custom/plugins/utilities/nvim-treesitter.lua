local languages = {
  'bash',
  'c',
  'cpp',
  'css',
  'diff',
  'go',
  'html',
  'javascript',
  'json',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'python',
  'query',
  'rust',
  'toml',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
  'yaml',
}

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    local treesitter = require 'nvim-treesitter'
    treesitter.setup()
    treesitter.install(languages)

    vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile', 'BufWinEnter', 'FileType' }, {
      group = vim.api.nvim_create_augroup('user-treesitter-start', { clear = true }),
      callback = function(args)
        if vim.bo[args.buf].buftype ~= '' or vim.wo.diff then
          return
        end

        -- Telescope may preload a preview buffer with events suppressed, then
        -- reuse it when the selection is opened. Restore filetype detection
        -- before trying to attach Tree-sitter to that buffer.
        if vim.bo[args.buf].filetype == '' then
          local filetype = vim.filetype.match { buf = args.buf }
          if filetype then
            vim.bo[args.buf].filetype = filetype
          end
        end

        if vim.bo[args.buf].filetype == '' then
          return
        end

        local has_parser = pcall(vim.treesitter.start, args.buf)
        if has_parser and vim.bo[args.buf].filetype ~= 'ruby' then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
