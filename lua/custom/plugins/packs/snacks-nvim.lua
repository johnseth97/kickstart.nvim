return {
  'folke/snacks.nvim',
  opts = function()
    -- Snacks Profiler for Neovim, used to profile startup time and keybindings
    -- Toggle the profiler
    Snacks.toggle.profiler():map '<leader>pp'
    -- Toggle the profiler highlights
    Snacks.toggle.profiler_highlights():map '<leader>ph'
  end,
  keys = {
    {
      '<leader>ps',
      function()
        Snacks.profiler.scratch()
      end,
      desc = 'Profiler Scratch Buffer',
    },
  },
}
