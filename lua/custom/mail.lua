-- Integration for the pinned Himalaya v2 UI. Never manipulate mailbox files.
local M = { account_backends = {} }
local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = 'Mail' })
end
function M.guidance(reason)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(buf)
  vim.bo[buf].swapfile, vim.bo[buf].undofile = false, false
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    'Neovim Mail',
    '',
    reason,
    '',
    '1. Run the dotfiles bootstrap to install Himalaya v2 and supporting tools.',
    '2. Run :Lazy sync to install the pinned himalaya.nvim and NUI plugins.',
    '3. Create private Himalaya config outside your dotfiles checkout.',
    '   See docs/mail.md and docs/examples in the dotfiles project.',
    '4. Run himalaya --json account list and himalaya -a ACCOUNT account check',
    '   in a terminal. Complete Microsoft OAuth there when needed.',
    '5. Restart mail, or run :lua require("custom.mail").start()',
    '',
    'No accounts or credentials are provisioned automatically.',
  })
  vim.bo[buf].modifiable = false
end
local function state()
  return require 'himalaya.state'
end
local function run(args, account, callback, input, json)
  local opts = { account = account, stdin = input, preserve_callback = true }
  require('himalaya.cli')[json and 'run_json' or 'run'](args, function(err, result)
    vim.schedule(function()
      if err then
        if args[1] == 'account' then
          M.guidance 'Cannot list mail accounts. Check private Himalaya configuration in a terminal.'
        else
          notify('Himalaya failed. Check account configuration/authentication with `himalaya account check` in a terminal.', vim.log.levels.ERROR)
        end
        return
      end
      callback(result)
    end)
  end, opts)
end

local function draft_operation(account)
  if vim.tbl_contains(M.account_backends[account] or {}, 'msgraph') then
    -- Released v2 cannot append arbitrary messages through shared Graph add;
    -- Graph's protocol command creates a MIME draft in the Drafts folder.
    return { 'msgraph', 'messages', 'create', '--folder', 'drafts' }
  end
  return { 'message', 'add', '-m', 'drafts', '-f', 'draft' }
end

function M.refresh()
  local s = state()
  if s.email_visible then
    require('himalaya.email').close()
  end
  if not s.main then
    return
  end
  require('himalaya.cache').clear()
  s.current_page = 1
  -- Resolve the account's inbox before listing (upstream reload races these).
  local account = s.current_account
  run({ 'mailbox', 'list', '--counts' }, account, function(data)
    if account ~= s.current_account or not s.main then
      return
    end
    local folders = data.mailboxes or data
    require('himalaya.cache').set_folders(folders)
    require('himalaya.ui.folder_list').render(s.sidebar, folders)
    require('himalaya.page').reload()
  end, nil, true)
end

function M.mark_selection_read(first, last)
  local s = state()
  if vim.api.nvim_get_current_buf() ~= s.main then
    return
  end
  first, last = first or vim.fn.line 'v', last or vim.fn.line '.'
  if first > last then
    first, last = last, first
  end
  local ids = {}
  for row = first, last do
    local envelope = s.current_envelopes[row]
    if envelope and envelope.id then
      ids[#ids + 1] = envelope.id
    end
  end
  if #ids == 0 then
    return
  end
  local account, folder = s.current_account, s.current_folder
  require('himalaya.cli.flag').add({ account = account, mailbox = folder, ids = ids, flag = 'seen' }, function(err)
    vim.schedule(function()
      if err then
        notify('Could not mark selected messages read.', vim.log.levels.ERROR)
        return
      end
      notify(('Marked %d messages read.'):format(#ids))
      if s.is_open and s.current_account == account and s.current_folder == folder then
        M.refresh()
      end
    end)
  end)
end

function M.accounts()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == 'acwrite' and vim.bo[buf].filetype == 'mail' then
      notify('Finish or close the mail composition buffers before switching accounts.', vim.log.levels.WARN)
      return
    end
  end
  require('himalaya.ui.picker').select_account(function(account)
    M.account_backends[account.name] = account.backends or {}
    require('himalaya.email').close()
    require('himalaya.cache').clear()
    local s = state()
    s.current_account, s.current_folder = account.name, nil
    s.current_envelopes = {}
    M.refresh()
  end)
end

-- A plain editable form; MIME generation, threading and attachments stay in CLI.
local function edit_form(template, source, account)
  -- A separate tab keeps the editable form above the mail UI's floating panes.
  vim.cmd 'tabnew'
  local compose_tab = vim.api.nvim_get_current_tabpage()
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_name(buf, 'mail://compose/' .. buf)
  require('custom.mail_tabs').register_draft(buf, account)
  vim.bo[buf].buftype = 'acwrite'
  vim.bo[buf].bufhidden = 'hide'
  vim.bo[buf].swapfile = false
  vim.bo[buf].undofile = false
  vim.bo[buf].filetype = 'mail'
  local lines = {
    'To: ' .. table.concat(template.to or {}, ', '),
    'Cc: ' .. table.concat(template.cc or {}, ', '),
    'Bcc: ' .. table.concat(template.bcc or {}, ', '),
    'Subject: ' .. (template.subject or ''),
    '',
  }
  vim.list_extend(lines, vim.split((template.body or ''):gsub('\r', ''), '\n', { plain = true }))
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  local attachments, busy = {}, false
  local function submit(send)
    if busy then
      return
    end
    local content = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local args = vim.deepcopy(source)
    local fields = { To = '--to', Cc = '--cc', Bcc = '--bcc', Subject = '--subject' }
    local body_start
    local empty_headers, present_headers = {}, {}
    for i, line in ipairs(content) do
      if line == '' then
        body_start = i + 1
        break
      end
      local key, value = line:match '^(%a+):%s*(.*)$'
      if not fields[key] or present_headers[key] then
        notify('Use only To, Cc, Bcc and Subject headers, then a blank line.', vim.log.levels.ERROR)
        return
      end
      present_headers[key] = true
      if value ~= '' then
        vim.list_extend(args, { fields[key], value })
      else
        empty_headers[key:lower()] = true
      end
    end
    if vim.tbl_count(present_headers) ~= 4 then
      notify('Keep exactly one To, Cc, Bcc and Subject header.', vim.log.levels.ERROR)
      return
    end
    if not body_start then
      notify 'Separate headers and body with a blank line.'
      return
    end
    for _, path in ipairs(attachments) do
      vim.list_extend(args, { '--attach', path })
    end
    if args[2] ~= 'compose' then
      vim.list_extend(args, { '--posting-style', 'none' })
    end
    local body = table.concat(vim.list_slice(content, body_start), '\n')
    local function perform()
      busy = true
      -- Generate raw MIME first, then send or append it. Nothing is saved locally.
      require('himalaya.cli').run(args, function(err, raw)
        vim.schedule(function()
          if err then
            busy = false
            notify('Could not build message; check Himalaya in a terminal.', vim.log.levels.ERROR)
            return
          end
          -- Omitted reply flags inherit source recipients. Explicitly cleared
          -- form headers must also disappear from the generated MIME headers.
          local cleaned, dropping, in_headers = {}, false, true
          for _, line in ipairs(vim.split(raw:gsub('\r\n', '\n'), '\n', { plain = true })) do
            if in_headers then
              if line == '' then
                in_headers, dropping = false, false
              elseif not line:match '^%s' then
                dropping = empty_headers[(line:match '^([^:]+):' or ''):lower()] or false
              end
            end
            if not dropping then
              table.insert(cleaned, line)
            end
          end
          raw = table.concat(cleaned, '\n')
          local operation = send and { 'message', 'send' } or draft_operation(account)
          require('himalaya.cli').run(operation, function(op_err)
            vim.schedule(function()
              busy = false
              if op_err then
                notify(
                  'Operation failed; the buffer is retained. Check the backend before retrying: delivery may have succeeded before saving a sent copy failed.',
                  vim.log.levels.ERROR
                )
              else
                if vim.api.nvim_buf_is_valid(buf) then
                  vim.bo[buf].modified = false
                end
                notify(send and 'Message sent.' or 'Draft saved (new copy).')
                if send and source[2] == 'reply' then
                  require('himalaya.cli.flag').add({ account = account, mailbox = source[4], id = source[5], flag = 'answered' }, function(flag_err)
                    if flag_err then
                      vim.schedule(function()
                        notify('Sent, but marking the source answered failed.', vim.log.levels.WARN)
                      end)
                    end
                  end)
                end
                if send and vim.api.nvim_buf_is_valid(buf) then
                  if vim.api.nvim_get_current_tabpage() == compose_tab and #vim.api.nvim_tabpage_list_wins(compose_tab) == 1 then
                    vim.cmd 'tabclose'
                  end
                  vim.api.nvim_buf_delete(buf, { force = true })
                end
              end
            end)
          end, { account = account, stdin = raw, preserve_callback = true })
        end)
      end, { account = account, stdin = body, preserve_callback = true })
    end
    if send then
      vim.ui.select({ 'Cancel', 'Send' }, { prompt = 'Send this message using ' .. account .. '?' }, function(choice)
        if choice == 'Send' then
          perform()
        end
      end)
    else
      perform()
    end
  end
  vim.api.nvim_create_autocmd('BufWriteCmd', {
    buffer = buf,
    callback = function()
      submit(false)
    end,
  })
  vim.api.nvim_buf_create_user_command(buf, 'MailSend', function()
    submit(true)
  end, {})
  vim.api.nvim_buf_create_user_command(buf, 'MailAttach', function(opts)
    local path = vim.fn.fnamemodify(vim.fn.expand(opts.args), ':p')
    if vim.fn.filereadable(path) == 0 then
      notify('Attachment is not readable.', vim.log.levels.ERROR)
      return
    end
    table.insert(attachments, path)
    notify('Attached: ' .. path)
  end, { nargs = 1, complete = 'file' })
  vim.keymap.set('n', '<leader>ms', function()
    submit(true)
  end, { buffer = buf, desc = '[M]ail [S]end' })
  vim.keymap.set('n', '<leader>md', function()
    submit(false)
  end, { buffer = buf, desc = '[M]ail [D]raft' })
  notify('Compose: :w saves a draft; :MailSend sends; :MailAttach PATH attaches. Account: ' .. account)
end

function M.compose(mode)
  local s = state()
  local account = s.current_account
  local source_folder = s.current_folder
  local args = { 'message', mode == 'reply-all' and 'reply' or mode }
  local env = require('himalaya.email').get_selected_envelope()
  if mode == 'forward' and env and (env['has-attachment'] or env.has_attachment) then
    notify 'Himalaya 2.2.1 forwards text. Download source attachments with ga, then add them with :MailAttach PATH.'
  end
  if mode ~= 'compose' then
    if not env then
      return
    end
    vim.list_extend(args, { '-m', s.current_folder, tostring(env.id) })
  end
  -- Pass empty stdin to prevent CLI body reads from hanging.
  run(args, account, function(template)
    if mode ~= 'reply-all' then
      edit_form(template, args, account)
      return
    end
    -- Released 2.2.1 lacks --all (master has it). Derive additional recipients
    -- from the CLI's decoded headers, keeping Reply-To and threading in reply.
    run({ 'message', 'read', '-m', source_folder, tostring(env.id) }, account, function(message)
      local seen = {}
      local function email(address)
        return (address:match '<([^>]+)>' or address):lower()
      end
      if template.from then
        seen[email(template.from)] = true
      end
      for _, address in ipairs(template.to or {}) do
        seen[email(address)] = true
      end
      for _, address in ipairs(template.cc or {}) do
        seen[email(address)] = true
      end
      template.cc = template.cc or {}
      local headers = message.headers or {}
      -- 2.2.1 exposes mail-parser's parts; newer v2 exposes decoded headers.
      if not message.headers then
        for _, header in ipairs(((message.parts or {})[1] or {}).headers or {}) do
          if header.name == 'to' or header.name == 'cc' then
            headers[header.name] = ((header.value or {}).Address or {}).List or {}
          end
        end
      end
      for _, field in ipairs { 'to', 'cc' } do
        for _, address in ipairs(headers[field] or {}) do
          local value = address.email or address.address
          if value and not seen[value:lower()] then
            table.insert(template.cc, value)
            seen[value:lower()] = true
          end
        end
      end
      edit_form(template, args, account)
    end, nil, true)
  end, '', true)
end

-- Resume a saved RFC message without re-encoding its MIME parts or losing
-- References/In-Reply-To. This deliberately saves new copies, never deletes one.
function M.draft()
  local s = state()
  local env = require('himalaya.email').get_selected_envelope()
  if not env then
    return
  end
  local account = s.current_account
  run({ 'message', 'read', '-m', s.current_folder, '--raw', tostring(env.id) }, account, function(raw)
    -- A separate tab keeps the editable form above the mail UI's floating panes.
    vim.cmd 'tabnew'
    local compose_tab = vim.api.nvim_get_current_tabpage()
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_name(buf, 'mail://compose/' .. buf)
    require('custom.mail_tabs').register_draft(buf, account)
    vim.bo[buf].buftype, vim.bo[buf].bufhidden = 'acwrite', 'hide'
    vim.bo[buf].swapfile, vim.bo[buf].undofile = false, false
    vim.bo[buf].filetype = 'mail'
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(raw:gsub('\r\n', '\n'), '\n', { plain = true }))
    local busy = false
    local function submit(send)
      if busy then
        return
      end
      local function perform()
        busy = true
        local args = send and { 'message', 'send' } or draft_operation(account)
        local content = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n')
        require('himalaya.cli').run(args, function(err)
          vim.schedule(function()
            busy = false
            if err then
              notify('Operation failed; buffer retained. Check backend before retrying; delivery may already have succeeded.', vim.log.levels.ERROR)
              return
            end
            if vim.api.nvim_buf_is_valid(buf) then
              vim.bo[buf].modified = false
              if send then
                if vim.api.nvim_get_current_tabpage() == compose_tab and #vim.api.nvim_tabpage_list_wins(compose_tab) == 1 then
                  vim.cmd 'tabclose'
                end
                vim.api.nvim_buf_delete(buf, { force = true })
              end
            end
            notify(send and 'Message sent; original draft retained.' or 'Draft saved as a new copy.')
          end)
        end, { account = account, stdin = content, preserve_callback = true })
      end
      if send then
        vim.ui.select({ 'Cancel', 'Send' }, { prompt = 'Send edited MIME message using ' .. account .. '?' }, function(choice)
          if choice == 'Send' then
            perform()
          end
        end)
      else
        perform()
      end
    end
    vim.api.nvim_create_autocmd('BufWriteCmd', {
      buffer = buf,
      callback = function()
        submit(false)
      end,
    })
    vim.api.nvim_buf_create_user_command(buf, 'MailSend', function()
      submit(true)
    end, {})
    vim.keymap.set('n', '<leader>ms', function()
      submit(true)
    end, { buffer = buf, desc = '[M]ail [S]end' })
    notify 'Editing raw draft/MIME: :w saves a new copy; :MailSend sends. Preserve MIME headers and boundaries.'
  end)
end

local function focus_pane(name)
  if name == 'email' and state().email_visible then
    name = 'main'
  end
  local popup = state()[name .. '_popup']
  if popup and popup.winid and vim.api.nvim_win_is_valid(popup.winid) then
    vim.api.nvim_set_current_win(popup.winid)
  end
end

local function pane_keys()
  local s = state()
  local function cycle(step)
    local panes = {}
    for _, name in ipairs { 'sidebar', 'main', 'email' } do
      local popup = s[name .. '_popup']
      if popup and popup.winid and vim.api.nvim_win_is_valid(popup.winid) then
        panes[#panes + 1] = name
      end
    end
    for index, name in ipairs(panes) do
      if s[name .. '_popup'].winid == vim.api.nvim_get_current_win() then
        focus_pane(panes[(index - 1 + step) % #panes + 1])
        return
      end
    end
  end
  for _, buf in ipairs { s.sidebar, s.main, s.email } do
    if vim.api.nvim_buf_is_valid(buf) then
      local function map(key, callback, desc)
        vim.keymap.set('n', key, callback, { buffer = buf, desc = desc })
      end
      map('<Tab>', function()
        cycle(1)
      end, 'Next mail pane')
      map('<S-Tab>', function()
        cycle(-1)
      end, 'Previous mail pane')
      map('<C-w>j', function()
        focus_pane 'sidebar'
      end, 'Focus folders')
      map('<C-w>;', function()
        focus_pane 'main'
      end, 'Focus message list')
      map('<C-w>k', function()
        focus_pane 'email'
      end, 'Focus message reader')
      map('<C-w>l', function()
        focus_pane 'main'
      end, 'Focus message list')
    end
  end
end

local function fill_editor()
  local s = state()
  if not s.layout then
    return
  end
  s.layout:update {
    relative = 'editor',
    position = { row = vim.o.showtabline == 2 and 1 or 0, col = 0 },
    size = { width = vim.o.columns, height = vim.o.lines - (vim.o.showtabline == 2 and 1 or 0) },
  }
  -- NUI reuses this configuration when the reading pane opens or resizes.
  s.sidebar_popup.win_config.focusable = true
  vim.api.nvim_win_set_config(s.sidebar_popup.winid, { focusable = true })
  if vim.fn.has 'nvim-0.12' == 1 then
    vim.api.nvim_win_set_config(s.sidebar_popup.winid, { mouse = true })
  end
  pane_keys()
  for _, popup in ipairs { s.sidebar_popup, s.main_popup, s.email_popup } do
    if popup.winid and vim.api.nvim_win_is_valid(popup.winid) then
      for key, value in pairs { number = false, relativenumber = false, signcolumn = 'no', foldcolumn = '0', statuscolumn = '', winbar = '' } do
        vim.wo[popup.winid][key] = value
      end
    end
  end
end

local saved_chrome
local function hide_chrome()
  if not saved_chrome then
    saved_chrome = { showtabline = vim.o.showtabline, laststatus = vim.o.laststatus, ruler = vim.o.ruler }
  end
  vim.o.showtabline, vim.o.laststatus, vim.o.ruler = vim.g.dotfiles_mail_mode and 2 or 0, 0, false
end

function M.setup()
  require('custom.mail_reader').setup { on_show = pane_keys }
  local folder_list = require 'himalaya.ui.folder_list'
  local render_folders = folder_list.render
  folder_list.render = function(buf, folders)
    render_folders(buf, folders)
    local rows, row = {}, 0
    -- Match the renderer's tree traversal, including non-selectable parents;
    -- the flat folder_list omits those rows and cannot be indexed by cursor.
    local function walk(tree)
      for _, item in ipairs(tree) do
        row = row + 1
        rows[row] = item.name or false
        walk(item.children or {})
      end
    end
    walk(require('himalaya.domain.mailbox').parse_folders(folders))
    vim.keymap.set('n', '<CR>', function()
      local name = rows[vim.api.nvim_win_get_cursor(0)[1]]
      if name then
        require('himalaya.email').close()
        require('himalaya.folder').switch_to(name)
        focus_pane 'main'
      else
        notify 'Select a mailbox below this grouping folder.'
      end
    end, { buffer = buf, desc = 'Open selected folder' })
    vim.keymap.set('n', 'R', M.refresh, { buffer = buf, desc = 'Refresh mail' })
    vim.keymap.set('n', 'gA', M.accounts, { buffer = buf, desc = 'Switch account' })
    vim.keymap.set('n', 'gq', function()
      require('himalaya').close()
    end, { buffer = buf, desc = 'Close mail' })
  end
  local himalaya = require 'himalaya'
  local close = himalaya.close
  himalaya.close = function()
    require('himalaya.email').close()
    close()
    if saved_chrome then
      for option, value in pairs(saved_chrome) do
        vim.o[option] = value
      end
      saved_chrome = nil
    end
  end
  vim.api.nvim_create_autocmd('VimResized', {
    callback = function()
      if state().is_open and saved_chrome then
        fill_editor()
      end
    end,
  })
  local cli = require 'himalaya.cli'
  local build_cmd = cli.build_cmd
  local original_run = cli.run
  cli.run = function(args, callback, opts)
    opts = vim.tbl_extend('force', {}, opts or {})
    local account = opts.account or (args[1] ~= 'account' and state().current_account or nil)
    opts.account = account
    local folder = state().current_folder
    if args[1] == 'envelope' then
      for i, arg in ipairs(args) do
        if arg == '-m' then
          folder = args[i + 1]
        end
      end
    end
    original_run(args, function(err, result)
      -- Ignore late results from a previous account, so its envelopes cannot
      -- replace the current account's list while switching.
      local retained_read = args[1] == 'message' and args[2] == 'read'
      if not opts.preserve_callback and not retained_read and account and account ~= '' and account ~= state().current_account then
        return
      end
      if args[1] == 'envelope' and (folder ~= state().current_folder or not state().is_open) then
        return
      end
      callback(err, result)
    end, opts)
  end
  -- Do not leave actionable envelopes from the previous folder on screen while
  -- its replacement is loading. Upstream changes the folder before the list.
  local envelope = require 'himalaya.cli.envelope'
  local list = envelope.list
  local displayed_context
  envelope.list = function(opts, callback)
    opts = opts or {}
    local context = (opts.account or state().current_account) .. '\0' .. (opts.mailbox or opts.folder or state().current_folder or '')
    if context ~= displayed_context then
      state().current_envelopes = {}
      displayed_context = context
    end
    return list(opts, callback)
  end
  -- Upstream refresh/page calls omit account; always bind them to current UI.
  cli.build_cmd = function(args, opts)
    opts = vim.tbl_extend('force', {}, opts or {})
    if args[1] ~= 'account' and not opts.account then
      opts.account = state().current_account
    end
    return build_cmd(args, opts)
  end
  local maps = {
    ['<leader>ma'] = { M.accounts, desc = '[M]ail [A]ccount' },
    ['<leader>mf'] = function()
      require('himalaya.folder').picker()
    end,
    ['<leader>mr'] = { M.refresh, desc = '[M]ail [R]efresh' },
    ['R'] = M.refresh,
    ['gA'] = M.accounts,
    ['c'] = function()
      M.compose 'compose'
    end,
    ['gw'] = function()
      M.compose 'compose'
    end,
    ['r'] = function()
      M.compose 'reply'
    end,
    ['gr'] = function()
      M.compose 'reply'
    end,
    ['gR'] = function()
      M.compose 'reply-all'
    end,
    ['gf'] = function()
      M.compose 'forward'
    end,
    -- Archive uses the backend move picker: select the account's actual archive.
    ['<leader>mm'] = 'move',
    ['<leader>mA'] = 'move',
    ['gE'] = { M.draft, desc = 'Edit saved draft (raw MIME)' },
  }
  require('himalaya').setup {
    icons_enabled = vim.g.have_nerd_font,
    border = 'rounded',
    custom_select = function(items, opts, callback)
      Snacks.picker.select(items, opts, callback)
    end,
    keymaps = { listing = maps, email = maps },
  }
  -- Theme links override upstream fixed colors, including after a theme switch.
  local function highlights()
    for name, target in pairs {
      HimalayaUnread = 'DiagnosticInfo',
      HimalayaFolderActive = 'Directory',
      HimalayaFolder = 'Normal',
      HimalayaFolderDisabled = 'Comment',
    } do
      vim.api.nvim_set_hl(0, name, { link = target })
    end
  end
  vim.api.nvim_create_autocmd('ColorScheme', { callback = highlights })
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'himalaya-envelope-listing',
    callback = function(event)
      vim.keymap.set('x', 'gFa', function()
        M.mark_selection_read()
      end, { buffer = event.buf, desc = 'Mark selected messages read' })
    end,
  })
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'himalaya-*', 'mail' },
    callback = function()
      vim.bo.swapfile = false
      vim.bo.undofile = false
    end,
  })
  vim.schedule(highlights)
  vim.api.nvim_create_user_command('Himalaya', M.start, { force = true })
end

function M.start()
  -- These flags configure this instance only, not terminals/child editors.
  local requested = vim.env.DOTFILES_MAIL_ACCOUNT
  if vim.env.DOTFILES_MAIL == '1' then
    vim.o.shadafile = 'NONE'
    vim.o.swapfile, vim.o.undofile = false, false
  end
  vim.env.DOTFILES_MAIL, vim.env.DOTFILES_MAIL_ACCOUNT = nil, nil
  vim.schedule(function()
    if vim.fn.executable 'himalaya' == 0 then
      M.guidance 'Himalaya is missing from PATH.'
      return
    end
    local version = vim.fn.system { 'himalaya', '--version' }
    if not version:match 'himalaya v2%.' then
      M.guidance 'Mail requires Himalaya v2 (validated with 2.2.1). Upgrade with bootstrap/package manager.'
      return
    end
    require('lazy').load { plugins = { 'himalaya.nvim' } }
    if not pcall(require, 'himalaya') then
      notify('Install the mail plugin with :Lazy sync, then restart mail.', vim.log.levels.ERROR)
      return
    end
    run({ 'account', 'list' }, nil, function(data)
      local accounts = data.accounts or data
      local selected
      for _, account in ipairs(accounts) do
        M.account_backends[account.name] = account.backends or {}
        if (requested and requested ~= '' and account.name == requested) or ((not requested or requested == '') and (account.default or #accounts == 1)) then
          selected = account.name
        end
      end
      local function open(account)
        if not account then
          return
        end
        require('himalaya.cache').clear()
        state().current_account = account
        -- Open after VimEnter: upstream's pre-VimEnter native layout cannot read
        -- messages yet; its mature NUI layout retains sidebar and reading split.
        hide_chrome()
        require('himalaya').open()
        require('custom.mail_reader').attach()
        fill_editor()
      end
      if selected then
        open(selected)
      elseif #accounts == 0 then
        M.guidance 'No mail accounts configured.'
      elseif requested and requested ~= '' then
        notify('Requested account not found. Use `himalaya account list`. ', vim.log.levels.ERROR)
      else
        require('himalaya.ui.picker').select_account(function(account)
          open(account.name)
        end)
      end
    end, nil, true)
  end)
end

return M
