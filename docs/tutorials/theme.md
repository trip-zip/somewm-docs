---
sidebar_position: 4
title: Theme
description: Write a theme file, load it with beautiful.init, see a change land on reload, and build it from a palette table.
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Theme

<YouWillLearn>

- How `beautiful` variables reach every widget
- Writing and loading a theme file
- A palette table and recoloured icons

</YouWillLearn>

`beautiful.init(path)` loads a Lua file that returns a table, and every widget reads its colours, fonts and sizes from `beautiful.*` afterwards. Before `init` runs, every variable is nil and reading one raises no error, so `require` widget modules after the `beautiful.init()` line in `rc.lua`.

## A theme file

Create `~/.config/somewm/theme/theme.lua`:

```lua
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local theme = {}

theme.font = "sans 10"

theme.bg_normal   = "#222222"
theme.bg_focus    = "#535d6c"
theme.bg_urgent   = "#ff0000"
theme.bg_minimize = "#444444"
theme.fg_normal   = "#aaaaaa"
theme.fg_focus    = "#ffffff"
theme.fg_urgent   = "#ffffff"
theme.fg_minimize = "#ffffff"

theme.useless_gap         = dpi(4)
theme.border_width        = dpi(1)
theme.border_color_normal = "#000000"
theme.border_color_active = "#535d6c"

theme.wallpaper = "/path/to/your/wallpaper.jpg"

return theme
```

In `rc.lua`:

```lua
local beautiful = require("beautiful")
beautiful.init(os.getenv("HOME") .. "/.config/somewm/theme/theme.lua")
```

Mod4 + Ctrl + r. Windows now sit apart by the gap and the focused border is slate blue. Change `useless_gap` to `dpi(16)`, reload, and the windows jump apart. Every variable works this way.

`dpi(n)` scales `n` by the screen's DPI, so `dpi(8)` is 8 pixels on a 1080p panel and about 16 on a 4K one. Use it for gaps, borders, padding and icon sizes; not for colours or opacity.

## A palette

Name the colours once and read them everywhere:

```lua
local colors = {
    bg = "#282828", fg = "#ebdbb2", grey = "#928374",
    red = "#cc241d", green = "#98971a", yellow = "#d79921",
    blue = "#458588", purple = "#b16286", orange = "#d65d0e",
}
theme.bg_normal = colors.bg
theme.fg_normal = colors.fg
theme.bg_urgent = colors.red
theme.border_color_active = colors.green
```

Several palettes keyed by name, with one selected at the top of the file, make a colour scheme a one-line change.

## Wallpaper, icons, widget families

- `theme.wallpaper = "/home/user/wallpapers/mountain.jpg"`; the default `request::wallpaper` handler draws it filling each screen with [awful.wallpaper](https://awesomewm.org/apidoc/popups_and_bars/awful.wallpaper.html). Per-monitor wallpapers are in [Multi-Monitor](/docs/guides/multi-monitor).
- `gears.color.recolor_image(path, colors.fg)` tints a white or black icon, which is how layout icons match a theme.
- Each widget reads its own prefix: `taglist_bg_focus`, `tasklist_*`, `notification_*`, `hotkeys_*`. [Theme Variables](/docs/reference/beautiful/theme-variables) lists every one with its source.

## A complete theme

```lua
local gears = require("gears")
local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local recolor = gears.color.recolor_image
local themes_path = gears.filesystem.get_themes_dir()

local theme = {}

local colors = {
    bg = "#282828", fg = "#ebdbb2", grey = "#928374", grey2 = "#3c3836",
    red = "#fb4934", green = "#b8bb26", yellow = "#fabd2f", blue = "#83a598",
    purple = "#d3869b", orange = "#fe8019",
}

theme.font = "JetBrainsMono Nerd Font 10"

theme.bg_normal   = colors.bg
theme.bg_focus    = colors.grey2
theme.bg_urgent   = colors.red
theme.bg_minimize = colors.grey
theme.fg_normal   = colors.fg
theme.fg_focus    = "#ffffff"
theme.fg_urgent   = "#ffffff"
theme.fg_minimize = colors.fg

theme.useless_gap         = dpi(8)
theme.border_width        = dpi(2)
theme.border_color_normal = colors.bg
theme.border_color_active = colors.green
theme.border_color_marked = colors.red

theme.wibar_bg     = colors.bg
theme.wibar_fg     = colors.fg
theme.wibar_height = dpi(32)

theme.taglist_bg_focus    = colors.grey
theme.taglist_bg_urgent   = colors.red
theme.taglist_fg_focus    = colors.yellow
theme.taglist_fg_occupied = colors.orange
theme.taglist_fg_empty    = colors.fg

theme.notification_bg           = colors.bg
theme.notification_fg           = colors.fg
theme.notification_border_color = colors.orange
theme.notification_border_width = dpi(2)

theme.hotkeys_bg           = colors.bg
theme.hotkeys_border_color = colors.yellow
theme.hotkeys_border_width = dpi(2)
theme.hotkeys_modifiers_fg = colors.orange
theme.hotkeys_label_bg     = colors.green

theme.layout_tile     = recolor(themes_path .. "default/layouts/tilew.png", colors.fg)
theme.layout_tileleft = recolor(themes_path .. "default/layouts/tileleftw.png", colors.fg)
theme.layout_floating = recolor(themes_path .. "default/layouts/floatingw.png", colors.fg)
theme.layout_max      = recolor(themes_path .. "default/layouts/maxw.png", colors.fg)
theme.layout_fair     = recolor(themes_path .. "default/layouts/fairvw.png", colors.fg)

theme.menu_height  = dpi(20)
theme.menu_width   = dpi(140)
theme.awesome_icon = theme_assets.awesome_icon(theme.menu_height, theme.bg_focus, theme.fg_focus)

theme.wallpaper = os.getenv("HOME") .. "/wallpapers/gruvbox.jpg"

return theme
```

## When it does not apply

- The theme file must end with `return theme`.
- A value copied at require time, such as `bg = beautiful.bg_normal` at the top of a widget module required before `beautiful.init()`, stays nil. Move the require below `init`.
- Layout icons: the default theme's live under `gears.filesystem.get_themes_dir() .. "default/layouts/"`.

[Widgets](/docs/tutorials/widgets) is next; [beautiful](https://awesomewm.org/apidoc/libraries/beautiful.html) is the upstream reference.
