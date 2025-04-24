-- lua/custom/plugins/language/lazydev.lua
return {
  {
    'folke/lazydev.nvim',
    ft = 'lua', -- only load when you open a .lua buffer
    opts = {
      -- Tell lazydev exactly which folders to index
      library = {
        -- Your “real” dotfiles path:
        vim.fn.expand '~/.dotfiles/.config/nvim/lua',
        -- The standard $XDG_CONFIG_HOME path:
        vim.fn.stdpath 'config' .. '/lua',
      },
      -- Turn on the two integrations you need:
      integrations = {
        --  • Make LuaLS treat your entire config dir as a workspace
        lspconfig = true,
        --  • Auto-inject a `lazydev` completion source for require()/module names
        cmp = true,
        --  • (you can leave coq=false unless you use coq.nvim)
        coq = false,
      },
      -- Optional: only enable if no .luarc.json in root
      enabled = function(root_dir)
        return not vim.uv.fs_stat(root_dir .. '/.luarc.json')
      end,
    },
    -- No need for a separate config() here—
    -- lazy.nvim will call require("lazydev").setup(opts) for you.
  },

  -- Then, make sure cmp knows about lazydev as a source:
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = { 'folke/lazydev.nvim' },
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      -- Put lazydev *before* the LSP source so you get path completions first
      table.insert(opts.sources, 1, { name = 'lazydev', group_index = 0 })
    end,
  },
}
