-- Read Omarchy or ~/.config/theme/colors.toml. Hosts can select the native
-- Aether theme; the existing Tokyo Night palette still supplies UI capsules.
-- Without either palette, keep the configured stock Tokyo Night style.
local M = {}

local state_dir = vim.fn.expand '~/.local/state/omarchy/current'
local colors_toml = state_dir .. '/theme/colors.toml'
local omarchy = vim.uv.fs_stat(colors_toml) ~= nil
if not omarchy then
  state_dir = (vim.env.XDG_CONFIG_HOME or vim.fn.expand '~/.config') .. '/theme'
  colors_toml = state_dir .. '/colors.toml'
end

-- What the UI capsules (lualine, cokeline, agentic) were hand-tuned to before
-- following Omarchy; still used verbatim on hosts without it.
local fallback = {
  bg_dark = '#1e2030',
  bg_highlight = '#292e42',
  blue = '#7aa2f7',
  comment = '#565f89',
  dark5 = '#737aa2',
  fg = '#c0caf5',
  fg_dark = '#828bb8',
  fg_gutter = '#3b4261',
  green = '#9ece6a',
  magenta = '#bb9af7',
  orange = '#ff9e64',
  red = '#f7768e',
  teal = '#4fd6be',
  yellow = '#e0af68',
}

local current = fallback

local function read_colors_toml()
  local file = io.open(colors_toml, 'r')
  if not file then
    return nil
  end
  local colors = {}
  for line in file:lines() do
    local key, value = line:match '^%s*([%w_]+)%s*=%s*"([^"]*)"'
    if key then
      colors[key] = value
    end
  end
  file:close()
  -- Many themes define only color0-15/accent; omarchy-theme-color maps those
  -- onto the named slots (blue, magenta, muted ...) used below, as the tmux
  -- and Starship palettes do. Explicit names in colors.toml win.
  if vim.fn.executable 'omarchy-theme-color' == 1 then
    for _, line in ipairs(vim.fn.systemlist { 'omarchy-theme-color', '--file', colors_toml, '--all' }) do
      local key, value = line:match '^([%w_]+)\t(#%x%x%x%x%x%x)$'
      if key and colors[key] == nil then
        colors[key] = value
      end
    end
  end
  -- Standalone palettes need the same ANSI-to-name mapping without an
  -- Omarchy executable. Explicit names (and Omarchy's derived values) win.
  local names = {
    black = 0,
    red = 1,
    green = 2,
    yellow = 3,
    blue = 4,
    magenta = 5,
    cyan = 6,
    white = 7,
    bright_black = 8,
    bright_red = 9,
    bright_green = 10,
    bright_yellow = 11,
    bright_blue = 12,
    bright_magenta = 13,
    bright_cyan = 14,
    bright_white = 15,
    muted = 8,
  }
  for name, index in pairs(names) do
    colors[name] = colors[name] or colors['color' .. index]
  end
  return colors
end

-- Map Omarchy's palette slots onto tokyonight's, deriving the in-between
-- shades tokyonight expects but colors.toml doesn't carry.
local function tokyonight_palette(c)
  local function pick(...)
    for _, key in ipairs { ... } do
      if c[key] then
        return c[key]
      end
    end
  end

  local bg, fg_dark = c.background, pick('foreground', 'bright_foreground')
  local blue, green, red, yellow = c.blue, c.green, c.red, c.yellow
  if not (bg and fg_dark and blue and green and red and yellow) then
    return nil
  end

  local blend = require('tokyonight.util').blend
  local fg = pick('bright_foreground', 'foreground')
  local muted = pick 'muted' or blend(fg_dark, 0.3, bg)
  local comment = pick('dark_foreground', 'muted') or blend(fg_dark, 0.5, bg)
  local cyan = pick('cyan', 'bright_cyan', 'blue')
  local bright_cyan = pick('syntax_cyan', 'bright_cyan', 'cyan', 'blue')

  return {
    bg = bg,
    bg_dark = pick 'dark_background' or blend(bg, 0.8, '#000000'),
    bg_dark1 = pick('darker_background', 'dark_background') or blend(bg, 0.6, '#000000'),
    -- A subtle lift (cursor line, inactive buffer tabs), not the theme's
    -- selection, which is often a bright accent.
    bg_highlight = (c.lighter_background ~= bg and c.lighter_background) or blend(fg, 0.1, bg),
    blue = blue,
    blue0 = blend(blue, 0.45, bg),
    blue1 = bright_cyan,
    blue2 = bright_cyan,
    blue5 = blend(bright_cyan, 0.6, fg),
    blue6 = blend(bright_cyan, 0.3, fg),
    blue7 = blend(blue, 0.3, bg),
    comment = comment,
    cyan = bright_cyan,
    dark3 = blend(comment, 0.7, muted),
    dark5 = blend(comment, 0.6, fg_dark),
    fg = fg,
    fg_dark = pick 'secondary_foreground' or fg_dark,
    -- Background lifted 15% toward the foreground, the way tokyonight gets
    -- #3b4261; lualine's sections and the tmux bar share this shade.
    fg_gutter = blend(fg_dark, 0.15, bg),
    green = green,
    green1 = blend(green, 0.5, bright_cyan),
    green2 = cyan,
    magenta = pick('bright_magenta', 'magenta'),
    magenta2 = pick('bright_red', 'red'),
    orange = pick('orange', 'bright_yellow', 'yellow'),
    purple = pick('magenta', 'bright_magenta'),
    red = red,
    red1 = blend(red, 0.75, '#000000'),
    teal = blend(green, 0.4, bright_cyan),
    terminal_black = muted,
    yellow = yellow,
    git = {
      add = blend(green, 0.8, bg),
      change = blend(blue, 0.7, bg),
      delete = blend(red, 0.7, bg),
    },
  }
end

--- The palette the current colorscheme was built from (tokyonight key names).
function M.colors()
  return current
end

function M.editor_theme()
  local colors = read_colors_toml()
  return colors and colors.neovim_theme or 'tokyonight'
end

---@param opts tokyonight.Config
function M.apply(opts)
  opts = vim.deepcopy(opts)
  local omarchy = read_colors_toml()
  local palette = omarchy and tokyonight_palette(omarchy)

  if palette and omarchy.neovim_theme == 'aether' then
    -- Use the author's actual syntax rules, not just their colours applied
    -- to Tokyo Night's rules. Keep our capsule palette and transparency.
    current = palette
    require('aether').setup {
      transparent = opts.transparent,
      styles = opts.styles,
      colors = {
        bg = omarchy.background,
        bg_dark = omarchy.background,
        bg_highlight = omarchy.muted,
        fg = omarchy.foreground,
        fg_dark = omarchy.secondary_foreground or omarchy.white,
        comment = omarchy.muted,
        red = omarchy.red,
        orange = omarchy.orange or omarchy.bright_red,
        yellow = omarchy.yellow,
        green = omarchy.green,
        cyan = omarchy.syntax_cyan or omarchy.cyan,
        blue = omarchy.blue,
        purple = omarchy.magenta,
        magenta = omarchy.bright_magenta,
      },
    }
    vim.cmd.colorscheme 'aether'
    return
  end

  if palette then
    -- tokyonight only treats the style named "day" as light (it forces
    -- 'background' to match the style), so a light theme takes that slot.
    local light = omarchy.mode == 'light'
    local style = light and 'day' or 'omarchy'
    rawset(require('tokyonight.colors').styles, style, palette)
    opts.style, opts.light_style = style, 'day'
    -- Settle 'background' up front with no colors_name set: flipping it while
    -- one is loaded makes nvim re-source the old scheme (e.g. tokyonight-day)
    -- on top of this one.
    vim.g.colors_name = nil
    vim.o.background = light and 'light' or 'dark'
  end

  local on_colors = opts.on_colors
  opts.on_colors = function(colors)
    current = palette and colors or fallback
    if on_colors then
      on_colors(colors)
    end
  end

  require('tokyonight').setup(opts)
  vim.cmd.colorscheme 'tokyonight'
end

-- `omarchy theme set` swaps the theme directory in, then rewrites
-- theme.generation (theme.name on older releases); debounce the burst.
local function watch(opts)
  local handle = vim.uv.new_fs_event()
  local timer = vim.uv.new_timer()
  if not (handle and timer) then
    return
  end
  handle:start(state_dir, {}, function(err, filename)
    local changed = omarchy and (filename == 'theme.generation' or filename == 'theme.name') or (not omarchy and filename == 'colors.toml')
    if err or not changed then
      return
    end
    timer:stop()
    timer:start(
      150,
      0,
      vim.schedule_wrap(function()
        M.apply(opts)
      end)
    )
  end)
end

---@param opts tokyonight.Config
function M.setup(opts)
  M.apply(opts)
  if vim.uv.fs_stat(state_dir) then
    watch(opts)
  end
end

return M
