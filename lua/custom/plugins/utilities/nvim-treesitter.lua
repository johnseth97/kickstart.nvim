return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    event = 'BufReadPost',
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby', 'lua' },
        disable = function(_, bufnr)
          return vim.wo[vim.api.nvim_get_current_win()].diff
        end,
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
    config = function(_, opts)
      -- 1) Standard TS setup:
      require('nvim-treesitter.configs').setup(opts)

      -- -- 2) Whenever any window-option 'diff' changes, stop TS in that buffer:
      -- vim.api.nvim_create_autocmd('OptionSet', {
      --   pattern = 'diff',
      --   callback = function(args)
      --     local bufnr = args.buf
      --     if vim.api.nvim_buf_get_option(bufnr, 'filetype') ~= '' and vim.wo[args.win].diff then
      --       -- stop the highlighter for this buffer
      --       require('vim.treesitter.highlighter').stop(bufnr)
      --     end
      --   end,
      -- })
    end,
  },
}
