-- For `plugins/markview.lua` users.
return {
  'OXY2DEV/markview.nvim',
  ft = { 'markdown', 'codecompanion' },
  opts = {
    preview = {
      filetypes = { 'markdown', 'codecompanion' },
      ignore_buftypes = {},
    },
  },
  -- For blink.cmp's completion
  -- source
  -- dependencies = {
  --     "saghen/blink.cmp"
  -- },
}
