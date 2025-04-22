return {
  {
    'nvim-telescope/telescope-project.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    config = function()
      require('telescope').setup {
        extensions = {
          project = {
            -- scan your ~/src/<lang>/<repo> tree, two levels deep
            base_dirs = { { '~/src', max_depth = 2 } },
            -- show hidden projects (dot‑starts) if any
            hidden_files = true,
            -- don’t error if you haven’t cloned every language folder yet
            ignore_missing_dirs = true,
            -- sort alphabetically (or "recent")
            order_by = 'asc',
            -- show full path + title, not minimal w0 labels
            display_type = 'full',
            -- hide the workspace suffix entirely
            hide_workspace = true,
          },
        },
      }
      -- load under the singular “project” name
      require('telescope').load_extension 'project'
    end,
  },
}
