return {
  {
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
  },
  -- Optional lualine component to show captured events
  -- when the profiler is running
  --  {
  --'nvim-lualine/lualine.nvim',
  --opts = function(_, opts)
  ---- Ensure the `sections` table exists before adding to it
  --opts.sections = opts.sections or {}
  --opts.sections.lualine_x = opts.sections.lualine_x or {}
  --
  ---- Add the Snacks profiler status to the `lualine_x` section
  --table.insert(opts.sections.lualine_x, require('snacks.profiler').status())
  --end,
  --},
}
