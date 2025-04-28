-- lua/custom/plugins/tui/telescope-file-browser.lua
return {
  'nvim-telescope/telescope-file-browser.nvim',
  cmd = 'Telescope',
  dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' },
  config = function()
    require('telescope').setup {
      extensions = {
        file_browser = {
          hijack_netrw = true, -- replace netrw
        },
      },
    }
    -- load the extension after setup
    require('telescope').load_extension 'file_browser'
  end,
}
