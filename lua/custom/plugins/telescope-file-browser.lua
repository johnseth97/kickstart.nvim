return {
  'nvim-telescope/telescope-file-browser.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' },
  require('telescope').setup {
    extensions = {
      file_browser = {
        hijack_netrw = true, -- Optional: Replace netrw with telescope-file-browser
      },
    },
  },
}
