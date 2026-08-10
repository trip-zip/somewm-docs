---
sidebar_position: 4
title: Theme
description: Customize SomeWM colors, fonts, and appearance
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Theme

<YouWillLearn>

- How `beautiful` variables flow to every widget
- How to write and load a theme file
- How to organize colors into a reusable palette
- How to set a wallpaper and recolor icons

</YouWillLearn>

:::tip Building a full config?
This page retrofits one feature into an existing config. If you would rather build a complete desktop from the ground up, the [Awesome From Scratch](from-scratch/index.md) series covers this topic as part of a thirteen-chapter course.
:::

## How Theming Works

All visual styling in SomeWM flows through the `beautiful` module. When you call `beautiful.init()` with a theme file, it loads variables like `beautiful.bg_normal`, `beautiful.font`, etc. that widgets and other components read to style themselves.

```lua
-- In your rc.lua
local beautiful = require("beautiful")
beautiful.init("/path/to/your/theme.lua")

-- Anywhere AFTER init(), including inside required modules:
print(beautiful.bg_normal)  -- "#282828"
print(beautiful.font)       -- "sans 10"
```

Order matters: before `beautiful.init()` runs, every theme variable is `nil` and reading one produces no error. This includes code that runs inside modules your `rc.lua` requires, so require widget modules after the `beautiful.init()` call.

## Creating Your Theme Directory

```bash
mkdir -p ~/.config/somewm/theme
```

## Theme File

Create `~/.config/somewm/theme/theme.lua`:

```lua
-- ~/.config/somewm/theme/theme.lua
local gears = require("gears")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local theme = {}

-- Fonts
theme.font = "sans 10"

-- Colors
theme.bg_normal   = "#222222"
theme.bg_focus    = "#535d6c"
theme.bg_urgent   = "#ff0000"
theme.bg_minimize = "#444444"

theme.fg_normal   = "#aaaaaa"
theme.fg_focus    = "#ffffff"
theme.fg_urgent   = "#ffffff"
theme.fg_minimize = "#ffffff"

-- Borders
theme.useless_gap   = dpi(4)
theme.border_width  = dpi(1)
theme.border_color_normal = "#000000"
theme.border_color_active = "#535d6c"

-- Wallpaper
theme.wallpaper = "/path/to/your/wallpaper.jpg"

return theme
```

## Loading Your Theme

Update your `rc.lua` to use your new theme:

```lua
local beautiful = require("beautiful")

-- Use your custom theme
local config_dir = os.getenv("HOME") .. "/.config/somewm"
beautiful.init(config_dir .. "/theme/theme.lua")
```

Press **Mod4 + Ctrl + r** to reload. Your theme is live: windows now sit apart with a small gap between them (`useless_gap` at work), and the focused window's border is slate blue instead of the default.

## Watch a Change Land

The edit-reload-observe loop is the whole workflow, so run it once deliberately. In your `theme.lua`, change the gap:

```lua
theme.useless_gap = dpi(16)
```

Reload with **Mod4 + Ctrl + r**. The windows jump apart; the gap is now unmissable. Change it back to taste. Every theme variable works this way: edit, reload, see it.

## Understanding DPI Scaling

The `apply_dpi()` function scales values based on your screen's DPI. This ensures your theme looks consistent across different displays:

```lua
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

-- These scale with DPI:
theme.useless_gap  = dpi(8)   -- Gap between windows
theme.border_width = dpi(2)   -- Window border thickness
theme.menu_height  = dpi(24)  -- Menu item height
```

On a 4K display, `dpi(8)` might become 16 pixels, while on a 1080p display it stays at 8.

:::tip
Always use `dpi()` for sizes that should scale: gaps, borders, padding, icon sizes. Don't use it for things like opacity or color values.
:::

## Building a Color Scheme System

Instead of hardcoding colors everywhere, organize them in a table:

```lua
local theme = {}

-- Define your color palette
local colors = {
    bg      = "#282828",
    fg      = "#ebdbb2",
    red     = "#cc241d",
    green   = "#98971a",
    yellow  = "#d79921",
    blue    = "#458588",
    purple  = "#b16286",
    aqua    = "#689d6a",
    orange  = "#d65d0e",
    grey    = "#928374",
}

-- Use colors throughout your theme
theme.bg_normal = colors.bg
theme.fg_normal = colors.fg
theme.bg_urgent = colors.red
theme.border_color_active = colors.green
```

Once your theme reads from a palette table, swappable color schemes come almost free: keep several palettes keyed by name (`colors.gruvbox`, `colors.nord`) and select one at the top of the file. Switching schemes becomes a one-line edit and a reload.

## Theme Variable Reference

For a complete list of all theme variables, see the [Theme Variables Reference](/docs/reference/beautiful/theme-variables).

The most commonly customized categories include:
- **Core colors** - `bg_normal`, `fg_normal`, `bg_focus`, etc.
- **Window borders** - `border_width`, `border_color_active`, `useless_gap`
- **Fonts** - `font`, `hotkeys_font`, `notification_font`
- **Wibar** - `wibar_bg`, `wibar_fg`, `wibar_height`

## Setting a Wallpaper

Point the `wallpaper` variable at an image:

```lua
theme.wallpaper = "/home/user/wallpapers/mountain.jpg"
```

Reload, and the default `request::wallpaper` handler in your rc.lua draws it filling each screen. (Fit, tile, and solid-color modes exist too; see [gears.wallpaper](https://awesomewm.org/apidoc/theme_related_libraries/gears.wallpaper.html). For a different wallpaper on each monitor, see the [Multi-Monitor guide](/docs/guides/multi-monitor).)

## Recoloring Icons

Many themes use white or black icons and recolor them to match the theme. Use `gears.color.recolor_image`:

```lua
local gears = require("gears")
local recolor = gears.color.recolor_image

-- Original icon is white, recolor to match theme
theme.layout_tile = recolor("/path/to/tile.png", colors.fg)
theme.layout_floating = recolor("/path/to/floating.png", colors.fg)
```

This is especially useful for layout icons in the wibar.

## Customizing Specific Widgets

Every widget reads its own family of theme variables, named by prefix. The taglist, for example:

```lua
theme.taglist_bg_focus = colors.grey
theme.taglist_fg_focus = colors.yellow
```

The same pattern covers the tasklist (`tasklist_*`), notifications (`notification_*`), the hotkeys popup (`hotkeys_*`), and more. The [Theme Variables Reference](/docs/reference/beautiful/theme-variables) lists every variable with its source.

## Complete Example Theme

Here's a complete theme file bringing everything together:

```lua
-- ~/.config/somewm/theme/theme.lua
local gears = require("gears")
local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local recolor = gears.color.recolor_image

local theme = {}

-- Get path to default theme for fallback icons
local themes_path = gears.filesystem.get_themes_dir()

--------------------------------------------------
-- Color Scheme
--------------------------------------------------
local colors = {
    bg      = "#282828",
    fg      = "#ebdbb2",
    grey    = "#928374",
    grey2   = "#3c3836",
    red     = "#fb4934",
    green   = "#b8bb26",
    yellow  = "#fabd2f",
    blue    = "#83a598",
    purple  = "#d3869b",
    orange  = "#fe8019",
}

--------------------------------------------------
-- Core
--------------------------------------------------
theme.font = "JetBrainsMono Nerd Font 10"

theme.bg_normal   = colors.bg
theme.bg_focus    = colors.grey2
theme.bg_urgent   = colors.red
theme.bg_minimize = colors.grey

theme.fg_normal   = colors.fg
theme.fg_focus    = "#ffffff"
theme.fg_urgent   = "#ffffff"
theme.fg_minimize = colors.fg

--------------------------------------------------
-- Borders & Gaps
--------------------------------------------------
theme.useless_gap          = dpi(8)
theme.border_width         = dpi(2)
theme.border_color_normal  = colors.bg
theme.border_color_active  = colors.green
theme.border_color_marked  = colors.red

--------------------------------------------------
-- Wibar
--------------------------------------------------
theme.wibar_bg     = colors.bg
theme.wibar_fg     = colors.fg
theme.wibar_height = dpi(32)

--------------------------------------------------
-- Taglist
--------------------------------------------------
theme.taglist_bg_focus    = colors.grey
theme.taglist_bg_urgent   = colors.red
theme.taglist_fg_focus    = colors.yellow
theme.taglist_fg_occupied = colors.orange
theme.taglist_fg_empty    = colors.fg

--------------------------------------------------
-- Notifications
--------------------------------------------------
theme.notification_bg           = colors.bg
theme.notification_fg           = colors.fg
theme.notification_border_color = colors.orange
theme.notification_border_width = dpi(2)

--------------------------------------------------
-- Hotkeys Popup
--------------------------------------------------
theme.hotkeys_bg               = colors.bg
theme.hotkeys_border_color     = colors.yellow
theme.hotkeys_border_width     = dpi(2)
theme.hotkeys_modifiers_fg     = colors.orange
theme.hotkeys_label_bg         = colors.green

--------------------------------------------------
-- Layout Icons (recolored)
--------------------------------------------------
theme.layout_tile       = recolor(themes_path .. "default/layouts/tilew.png", colors.fg)
theme.layout_tileleft   = recolor(themes_path .. "default/layouts/tileleftw.png", colors.fg)
theme.layout_floating   = recolor(themes_path .. "default/layouts/floatingw.png", colors.fg)
theme.layout_max        = recolor(themes_path .. "default/layouts/maxw.png", colors.fg)
theme.layout_fair       = recolor(themes_path .. "default/layouts/fairvw.png", colors.fg)

--------------------------------------------------
-- Menu
--------------------------------------------------
theme.menu_height = dpi(20)
theme.menu_width  = dpi(140)

-- Generate awesome icon
theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)

--------------------------------------------------
-- Wallpaper
--------------------------------------------------
theme.wallpaper = os.getenv("HOME") .. "/wallpapers/gruvbox.jpg"

return theme
```

## Troubleshooting

### Theme not loading

Check the path in your `beautiful.init()` call:

```lua
-- Make sure the path is correct
beautiful.init(os.getenv("HOME") .. "/.config/somewm/theme/theme.lua")
```

### Colors not applying

Make sure your theme file returns the theme table:

```lua
local theme = {}
-- ... your theme settings ...
return theme  -- Don't forget this!
```

Also check *when* your code reads the theme. A module required before `beautiful.init()` sees `nil` for every theme variable, silently. Values copied at require time (like `bg = beautiful.bg_normal` at the top of a widget module) stay `nil` even after `init()` runs later. Move widget requires below `beautiful.init()` in your `rc.lua`.

### Icons not showing

If using custom icon paths, verify the files exist:

```bash
ls ~/.config/somewm/theme/icons/
```

For layout icons, you can use the default theme's icons as a starting point:

```lua
local themes_path = gears.filesystem.get_themes_dir()
theme.layout_tile = themes_path .. "default/layouts/tilew.png"
```

## Next Steps

- **[Theme Variables Reference](/docs/reference/beautiful/theme-variables)** - Complete list of all theme variables
- **[Widgets](/docs/tutorials/widgets)** - Create custom widgets
- **[beautiful (AwesomeWM docs)](https://awesomewm.org/apidoc/libraries/beautiful.html)** - Upstream API reference
