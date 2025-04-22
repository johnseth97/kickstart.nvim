return {
  'ahmedkhalf/project.nvim',
  lazy = false,
  dependencies = { 'nvim-telescope/telescope.nvim' },
  config = function()
    require('project_nvim').setup {
      -- automatically scan ~/src for any git repo, up to 3 levels deep
      base_dirs = {
        { '~/src', max_depth = 2 },
      },
      -- patterns it looks for to identify a project root
      patterns = { '.git' },
      -- show hidden files when scanning
      show_hidden = true,
      -- ignore your ~/.local/share or other big folders by name
      exclude_dirs = { '~/.local/share' },
      -- if you want it to silently `:cd` into new projects
      silent_chdir = false,
    }

    -- make sure telescope knows about it
    require('telescope').load_extension 'projects'
  end,
}
