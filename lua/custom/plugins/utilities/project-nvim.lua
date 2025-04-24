-- lua/custom/plugins/tui/project-nvim.lua
return {
  'ahmedkhalf/project.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-telescope/telescope.nvim' },
  config = function()
    -- explicitly require the correct module and pass your opts
    require('project_nvim').setup {
      detection_methods = { 'pattern' },
      patterns = { '.git' },
      base_dirs = { { '~/src', max_depth = 2 } },
      show_hidden = true,
      respect_gitignore = false,
    }
  end,
}
