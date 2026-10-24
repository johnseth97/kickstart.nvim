return {
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  lazy = false,
  init = function()
    -- Use explicit C indentation instead of guessing from mixed tabs/spaces.
    vim.g.sleuth_c_heuristics = 0
    vim.g.sleuth_cpp_heuristics = 0
  end,
}
