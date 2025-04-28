return {
  'nvim-telescope/telescope-project.nvim',
  cmd = 'Telescope',
  dependencies = { 'nvim-telescope/telescope.nvim', 'ahmedkhalf/project.nvim' },
  config = function()
    require('telescope').setup {
      extensions = {
        project = {
          base_dirs = { { '~/src', max_depth = 2 } },
          hidden_files = true,
          respect_gitignore = false,
          order_by = 'asc',
          -- show full path + title, not minimal w0 labels
          display_type = 'full',
          -- hide the workspace suffix entirely
          hide_workspace = true,
        },
      },
    }
    require('telescope').load_extension 'project'
  end,
}
