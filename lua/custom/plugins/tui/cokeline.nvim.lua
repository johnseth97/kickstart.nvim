local function capsule_bg(buffer)
  return buffer.is_focused and '#4fd6be' or '#292e42'
end

local function capsule_fg(buffer)
  return buffer.is_focused and '#1e2030' or '#828bb8'
end

local function apply_highlights()
  vim.api.nvim_set_hl(0, 'CokelineFill', { bg = 'NONE' })
end

return {
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
      fg = '#828bb8',
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
        fg = '#e0af68',
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
