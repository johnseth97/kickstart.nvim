local function attach_agentic_chat(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= 'AgenticChat' then
    return
  end

  -- Agentic maps this filetype to Markdown Tree-sitter. Keeping the custom
  -- filetype lets its chat-specific UI continue to work while Markview renders
  -- the transcript itself.
  require('markview.actions').attach(bufnr, { hybrid_mode = false })
end

return {
  'OXY2DEV/markview.nvim',
  ft = { 'markdown', 'codecompanion', 'AgenticChat' },
  opts = {
    preview = {
      filetypes = { 'markdown', 'codecompanion', 'AgenticChat' },
      ignore_buftypes = {},
      -- Use the explicit filetype list. Markview's default condition is for
      -- its experimental all-Tree-sitter-buffer mode and otherwise returns false.
      condition = function()
        return nil
      end,
    },
  },
  config = function(_, opts)
    require('markview').setup(opts)

    local group = vim.api.nvim_create_augroup('MarkviewAgenticChat', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
      group = group,
      pattern = 'AgenticChat',
      callback = function(args)
        vim.schedule(function()
          attach_agentic_chat(args.buf)
        end)
      end,
    })

    -- Lazy can load Markview during Agentic's FileType event, so also attach
    -- any chat buffer that already exists by the time setup finishes.
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      attach_agentic_chat(bufnr)
    end
  end,
}
