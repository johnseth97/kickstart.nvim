local M = {}

local augroup = vim.api.nvim_create_augroup('CustomZkMarkdown', { clear = true })

local function attach(bufnr)
  local ok, zk_util = pcall(require, 'zk.util')
  if not ok then
    return
  end

  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' or zk_util.notebook_root(path) == nil then
    return
  end

  vim.b[bufnr].zk_notebook = true

  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, {
      buffer = bufnr,
      silent = true,
      desc = 'zk: ' .. desc,
    })
  end

  local function insert_tag()
    require('zk').pick_tags({}, {
      title = 'Insert Tag',
      multi_select = false,
    }, function(tag)
      if not tag then
        return
      end

      local text = '#' .. tag.name
      local cursor = vim.api.nvim_win_get_cursor(0)
      local row, col = cursor[1] - 1, cursor[2]

      vim.api.nvim_buf_set_text(bufnr, row, col, row, col, { text })
      vim.api.nvim_win_set_cursor(0, { row + 1, col + #text })
    end)
  end

  map('n', '<CR>', vim.lsp.buf.definition, 'Follow link')
  map('n', 'K', vim.lsp.buf.hover, 'Preview link')
  map('n', '<localleader>l', '<cmd>ZkInsertLink<CR>', 'Insert link')
  map('v', '<localleader>l', ":'<,'>ZkInsertLinkAtSelection<CR>", 'Link selection')
  map('n', '<localleader>b', '<cmd>ZkBacklinks<CR>', 'Backlinks')
  map('n', '<localleader>o', '<cmd>ZkLinks<CR>', 'Outgoing links')
  map('n', '<localleader>t', insert_tag, 'Insert tag')
  map('n', '<localleader>r', function()
    require('zk').edit({ related = { path } }, { title = 'Related Notes' })
  end, 'Related notes')
  map('n', '<localleader>n', function()
    require('zk').new {
      dir = vim.fn.fnamemodify(path, ':h'),
      title = vim.fn.input 'Title: ',
    }
  end, 'New sibling note')
end

function M.setup()
  vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    pattern = 'markdown',
    callback = function(args)
      attach(args.buf)
    end,
  })

  if vim.bo.filetype == 'markdown' then
    attach(vim.api.nvim_get_current_buf())
  end
end

return M
