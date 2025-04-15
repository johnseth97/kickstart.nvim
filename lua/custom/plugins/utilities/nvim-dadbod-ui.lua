return {
  'kristijanhusak/vim-dadbod-ui',
  dependencies = {
    'tpope/vim-dadbod',
    { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' } },
  },
  cmd = {
    'DBUI',
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUIFindBuffer',
  },
  event = 'VeryLazy',
  config = function()
    vim.g.db_ui_dotenv_variable_prefix = '__DISABLED__'
    local handle = io.popen 'printenv'
    local result = handle:read '*a'
    handle:close()

    local connections = {}

    for line in result:gmatch '[^\r\n]+' do
      local key, value = line:match '^(.-)=(.*)$'
      if key and key:match '^DATABASE_' then
        local suffix = key:gsub('^DATABASE_', '')
        local name = suffix:gsub('_', ' '):upper()

        -- Extract database name from URL for path fallback
        local db_path = value:match '.*/(.*)'
        db_path = db_path or name

        table.insert(connections, {
          name = name,
          url = value,
          path = 'default', -- stub for UI schema tree
        })

        print('[DBUI] Added connection: ' .. name)
      end
    end

    if #connections > 0 then
      vim.g.dbs = connections
      print('[DBUI] ' .. #connections .. ' connections registered.')
    else
      print '[DBUI] No DATABASE_* env vars found.'
    end
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_save_location = vim.fn.stdpath 'data' .. '/db_ui'
  end,
}
