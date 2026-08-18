return {
  'nvim-tree/nvim-tree.lua',
  version = '*',
  cmd = { 'NvimTreeToggle' },
  init = function()
    local function toggle_tree_from_editor()
      local loaded, api = pcall(require, 'nvim-tree.api')
      local tree = loaded and api.tree or nil
      local function toggle()
        if tree then
          tree.toggle()
        else
          -- Retain Lazy's command trigger for the first use of NvimTree.
          vim.cmd 'NvimTreeToggle'
        end
      end

      -- NvimTree opens a vertical split from the current window. When that is
      -- an Agentic panel, it momentarily splits the sidebar and causes a
      -- disruptive layout resize. Build the tree from an ordinary buffer
      -- instead, leaving the Agentic column intact.
      if (tree and tree.is_visible()) or not vim.bo.filetype:match '^Agentic' then
        toggle()
        return
      end

      for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local bufnr = vim.api.nvim_win_get_buf(winid)
        local config = vim.api.nvim_win_get_config(winid)
        if
          config.relative == ''
          and vim.bo[bufnr].buftype == ''
          and not vim.bo[bufnr].filetype:match '^Agentic'
        then
          vim.api.nvim_win_call(winid, toggle)
          return
        end
      end

      -- A tab with no ordinary buffer is unusual, but NvimTree can still
      -- handle it normally rather than leaving the keybinding inert.
      toggle()
    end

    vim.keymap.set('n', '\\', toggle_tree_from_editor, { desc = 'Toggle Explorer', silent = true })
    vim.keymap.set('n', '<leader>e', toggle_tree_from_editor, { desc = 'File [E]xplorer', silent = true })
  end,
  opts = {
    hijack_netrw = false,
    update_focused_file = {
      enable = true,
      update_cwd = true,
    },
    view = {
      width = 35,
      preserve_window_proportions = true,
    },
    on_attach = function(bufnr)
      local api = require 'nvim-tree.api'
      -- Default mappings must be set before changing any mappings
      api.config.mappings.default_on_attach(bufnr)
      -- Optional: Customize the mappings
      local function map(lhs, rhs)
        vim.keymap.set('n', lhs, rhs, { buffer = bufnr, noremap = true, silent = true })
      end

      -- Optional: Map `\` to close the tree
      map('\\', api.tree.close)
    end,
  },
}
