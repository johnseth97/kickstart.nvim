return {
  'nvim-telescope/telescope-media-files.nvim',
  cmd = 'Telescope',
  dependencies = { 'nvim-telescope/telescope.nvim', 'ahmedkhalf/project.nvim' },
  keys = {
    { '<leader>sm', '<cmd>Telescope media_files<cr>', desc = 'Telescope [s]earch [m]edia' },
  },
  config = function()
    require('telescope').setup {
      extensions = {
        media_files = {
          -- filetypes whitelist
          filetypes = { 'png', 'jpg', 'mp4', 'webm', 'pdf' },
          find_cmd = 'rg',
          -- find_cmd = 'fd',
          -- find_cmd = 'ag',
          -- find_cmd = 'git',
        },
      },
    }
    require('telescope').load_extension 'media_files'
  end,
}
