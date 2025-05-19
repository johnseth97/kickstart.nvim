-- lua/custom/plugins/tui/project-nvim.lua
return {
  'ahmedkhalf/project.nvim',
  event = 'BufReadPost',
  dependencies = { 'nvim-telescope/telescope.nvim' },
  config = function()
    -- explicitly require the correct module and pass your opts
    require('project_nvim').setup {
      detection_methods = { 'pattern' },
      patterns = { '.git' },
      base_dirs = {
        { '~/src/', max_depth = 2 },
        { '~/.dotfiles/', max_depth = 1 },
        { '~/.dotfiles/.config/nvim/', max_depth = 1 },
      },
      show_hidden = true,
      respect_gitignore = false,
    }
  end,
}
