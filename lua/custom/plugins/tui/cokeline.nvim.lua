-- Colours are looked up per render, so they follow Omarchy theme switches.
local function palette()
  return require('custom.omarchy_theme').colors()
end

local function capsule_bg(buffer)
  return buffer.is_focused and palette().teal or palette().bg_highlight
end

local function capsule_fg(buffer)
  return buffer.is_focused and palette().bg_dark or palette().fg_dark
end

local function apply_highlights()
  vim.api.nvim_set_hl(0, 'CokelineFill', { bg = 'NONE' })
end

local spec = {
  'willothy/nvim-cokeline',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  lazy = false,
  config = function(_, opts)
    apply_highlights()
    require('cokeline').setup(opts)

    vim.api.nvim_create_autocmd('ColorScheme', {
      group = vim.api.nvim_create_augroup('CokelineCapsuleTheme', { clear = true }),
      callback = apply_highlights,
    })
  end,
  opts = {
    show_if_buffers_are_at_least = 1,
    fill_hl = 'CokelineFill',
    default_hl = {
      fg = function()
        return palette().fg_dark
      end,
      bg = 'NONE',
    },
    buffers = {
      filter_valid = function(buffer)
        return not vim.startswith(buffer.filetype, 'Agentic')
      end,
      focus_on_delete = 'next',
      new_buffers_position = 'last',
      delete_on_right_click = true,
    },
    mappings = {
      cycle_prev_next = true,
    },
    history = {
      enabled = true,
      size = 10,
    },
    components = {
      {
        text = '',
        fg = capsule_bg,
        bg = 'NONE',
      },
      {
        text = function(buffer)
          return string.format(' %d ', buffer.index)
        end,
        fg = capsule_fg,
        bg = capsule_bg,
        bold = function(buffer)
          return buffer.is_focused
        end,
      },
      {
        text = function(buffer)
          return buffer.devicon.icon
        end,
        fg = function(buffer)
          return buffer.devicon.color
        end,
        bg = capsule_bg,
      },
      {
        text = function(buffer)
          local prefix = buffer.unique_prefix or ''
          return prefix .. buffer.filename .. ' '
        end,
        fg = capsule_fg,
        bg = capsule_bg,
        bold = function(buffer)
          return buffer.is_focused
        end,
      },
      {
        text = function(buffer)
          return buffer.is_modified and '● ' or ''
        end,
        fg = function()
          return palette().yellow
        end,
        bg = capsule_bg,
      },
      {
        text = '󰅖',
        fg = capsule_fg,
        bg = capsule_bg,
        on_click = function(_, _, button, _, buffer)
          if button == 'l' then
            buffer:delete()
          end
        end,
      },
      {
        text = ' ',
        fg = capsule_bg,
        bg = 'NONE',
      },
    },
  },
}

if vim.g.dotfiles_mail_mode then
  local tabs = require 'custom.mail_tabs'
  spec.opts.history.enabled = false
  spec.opts.rendering = { max_buffer_width = 42 }
  spec.opts.buffers.filter_valid = function(buffer)
    return tabs.entries[buffer.number] ~= nil
  end
  spec.opts.buffers.delete_on_right_click = false
  spec.opts.buffers.new_buffers_position = function(a, b)
    return tabs.entries[a.number].order < tabs.entries[b.number].order
  end
  local function fg(buffer)
    return tabs.active == buffer.number and palette().bg_dark or palette().fg_dark
  end
  local function bg(buffer)
    return tabs.active == buffer.number and palette().teal or palette().bg_highlight
  end
  local function click(_, _, button, _, buffer)
    if button == 'l' then
      tabs.focus(buffer.number)
    elseif button == 'r' or button == 'm' then
      tabs.close(buffer.number)
    end
  end
  local function prefix(buffer)
    local entry = tabs.entries[buffer.number]
    local icon = entry.kind == 'draft' and '󰷉' or '󰇮'
    return (' %d %s '):format(buffer.index, icon) .. (entry.kind == 'draft' and 'Draft · ' or '')
  end
  spec.opts.components = {
    { text = '', fg = bg, bg = 'NONE', on_click = click, truncation = { priority = 1 } },
    { text = prefix, fg = fg, bg = bg, on_click = click, truncation = { priority = 2 } },
    {
      text = function(buffer)
        local close = tabs.entries[buffer.number].kind == 'root' and '' or '󰅖'
        local marker = buffer.is_modified and '● ' or ''
        local fixed = vim.fn.strdisplaywidth(prefix(buffer) .. '' .. marker .. close .. ' ' .. ' ')
        return tabs.subject(buffer.number, math.max(1, 42 - fixed)) .. ' '
      end,
      fg = fg,
      bg = bg,
      on_click = click,
      truncation = { priority = 100, direction = 'right' },
    },
    {
      text = function(buffer)
        return buffer.is_modified and '● ' or ''
      end,
      fg = fg,
      bg = bg,
      on_click = click,
      truncation = { priority = 2 },
    },
    {
      text = function(buffer)
        return tabs.entries[buffer.number].kind == 'root' and '' or '󰅖'
      end,
      fg = fg,
      bg = bg,
      truncation = { priority = 2 },
      on_click = function(_, _, button, _, buffer)
        if button == 'l' then
          tabs.close(buffer.number)
        end
      end,
    },
    { text = ' ', fg = bg, bg = 'NONE', on_click = click, truncation = { priority = 1 } },
  }
end
return spec
