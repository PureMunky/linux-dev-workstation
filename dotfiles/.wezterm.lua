-- WezTerm Configuration
-- https://wezfurlong.org/wezterm/config/files.html

local wezterm = require 'wezterm'
local config = {}

-- Use config builder if available (WezTerm 20220807+)
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Appearance
config.color_scheme = 'Monokai Pro (Gogh)'
config.font = wezterm.font 'JetBrains Mono'
config.font_size = 11.0
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = true
config.window_padding = {
  left = 2,
  right = 2,
  top = 0,
  bottom = 0,
}

-- Performance
config.enable_wayland = true
config.front_end = "WebGpu"
config.max_fps = 120

-- Tab bar
config.tab_bar_at_bottom = false
config.show_new_tab_button_in_tab_bar = true

-- Window
config.window_background_opacity = 0.95
config.window_decorations = "RESIZE"

-- Cursor
config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 800

-- Scrollback
config.scrollback_lines = 10000

-- Key bindings
config.keys = {
  -- Split panes
  {
    key = 'd',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'D',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  -- Navigate panes
  {
    key = 'LeftArrow',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ActivatePaneDirection 'Left',
  },
  {
    key = 'RightArrow',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ActivatePaneDirection 'Right',
  },
  {
    key = 'UpArrow',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ActivatePaneDirection 'Up',
  },
  {
    key = 'DownArrow',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ActivatePaneDirection 'Down',
  },
  -- Close pane
  {
    key = 'w',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.CloseCurrentPane { confirm = true },
  },
}

return config
