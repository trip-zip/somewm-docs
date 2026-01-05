---
sidebar_position: 4
title: Theme
description: Customize SomeWM colors, fonts, and appearance
---

# Theme

SomeWM's appearance is fully customizable through the **beautiful** module. In this tutorial, we'll create a custom theme from scratch.

## How Theming Works

All visual styling in SomeWM flows through the `beautiful` module. When you call `beautiful.init()` with a theme file, it loads variables like `beautiful.bg_normal`, `beautiful.font`, etc. that widgets and other components read to style themselves.

```lua
-- In your rc.lua
local beautiful = require("beautiful")
beautiful.init("/path/to/your/theme.lua")

-- Later, anywhere in your config:
print(beautiful.bg_normal)  -- "#282828"
print(beautiful.font)       -- "sans 10"
```

## Creating Your Theme Directory

First, create a directory for your theme:

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

Press **Mod4 + Ctrl + r** to reload and see your changes!

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

This makes it easy to tweak your entire color scheme by changing values in one place.

## Supporting Multiple Color Schemes

Take it further by defining multiple palettes:

```lua
local colors = {
    gruvbox = {
        bg      = "#282828",
        fg      = "#ebdbb2",
        red     = "#cc241d",
        green   = "#98971a",
        yellow  = "#d79921",
        blue    = "#458588",
        purple  = "#b16286",
        orange  = "#d65d0e",
    },
    nord = {
        bg      = "#2E3440",
        fg      = "#D8DEE9",
        red     = "#BF616A",
        green   = "#A3BE8C",
        yellow  = "#EBCB8B",
        blue    = "#8FBCBB",
        purple  = "#B48EAD",
        orange  = "#D08770",
    },
}

-- Switch schemes by changing this one line!
local color_scheme = "gruvbox"
local c = colors[color_scheme]

theme.bg_normal = c.bg
theme.fg_normal = c.fg
-- ... etc
```

{/* TODO: Screenshot needed
   - Side-by-side comparison of gruvbox vs nord theme
   - Show the same desktop with different color schemes
*/}

## Essential Theme Variables

Here are the most commonly customized variables:

### Core Colors

| Variable | Description |
|----------|-------------|
| `bg_normal` | Default background color |
| `bg_focus` | Background when focused |
| `bg_urgent` | Background for urgent items |
| `fg_normal` | Default text color |
| `fg_focus` | Text color when focused |
| `fg_urgent` | Text color for urgent items |

### Window Borders

| Variable | Description |
|----------|-------------|
| `border_width` | Window border thickness |
| `border_color_normal` | Unfocused window border |
| `border_color_active` | Focused window border |
| `useless_gap` | Gap between tiled windows |

### Fonts

| Variable | Description |
|----------|-------------|
| `font` | Default font (Pango format) |
| `hotkeys_font` | Font for hotkeys popup |
| `notification_font` | Font for notifications |

### Wibar

| Variable | Description |
|----------|-------------|
| `wibar_bg` | Wibar background |
| `wibar_fg` | Wibar text color |
| `wibar_height` | Wibar height |

## Setting a Wallpaper

### Simple Wallpaper

The simplest way to set a wallpaper:

```lua
theme.wallpaper = "/home/user/wallpapers/mountain.jpg"
```

This is used by the default `request::wallpaper` handler in your rc.lua.

### Per-Screen Wallpapers

For different wallpapers on each screen, modify your rc.lua:

```lua
local wallpapers = {
    "/home/user/wallpapers/primary.jpg",
    "/home/user/wallpapers/secondary.jpg",
}

screen.connect_signal("request::wallpaper", function(s)
    gears.wallpaper.maximized(wallpapers[s.index] or wallpapers[1], s, true)
end)
```

### Wallpaper Functions

The `gears.wallpaper` module offers several options:

```lua
-- Fill screen, cropping if needed
gears.wallpaper.maximized("/path/to/wallpaper.jpg", s, true)

-- Fit to screen, may show background color
gears.wallpaper.fit("/path/to/wallpaper.jpg", s, "#000000")

-- Tile a pattern
gears.wallpaper.tiled("/path/to/pattern.png", s)

-- Solid color
gears.wallpaper.set("#282828")
```

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

### Taglist

```lua
theme.taglist_bg_focus    = colors.grey
theme.taglist_bg_occupied = nil  -- use default
theme.taglist_bg_empty    = colors.bg
theme.taglist_bg_urgent   = colors.red

theme.taglist_fg_focus    = colors.yellow
theme.taglist_fg_occupied = colors.orange
theme.taglist_fg_empty    = colors.fg
```

### Tasklist

```lua
theme.tasklist_bg_focus = colors.grey
theme.tasklist_fg_focus = colors.fg
theme.tasklist_disable_icon = true  -- text-only tasklist
```

### Notifications

```lua
theme.notification_bg = colors.bg
theme.notification_fg = colors.fg
theme.notification_border_color = colors.orange
theme.notification_border_width = dpi(2)
theme.notification_icon_size = dpi(64)
```

### Hotkeys Popup

```lua
theme.hotkeys_bg = colors.bg
theme.hotkeys_fg = colors.fg
theme.hotkeys_border_color = colors.yellow
theme.hotkeys_border_width = dpi(2)
theme.hotkeys_modifiers_fg = colors.orange
theme.hotkeys_label_bg = colors.green
theme.hotkeys_label_fg = colors.fg
```

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

- **[Widgets](/tutorials/widgets)** - Create custom widgets
- **[AwesomeWM Theme Docs](https://awesomewm.org/doc/api/libraries/beautiful.html)** - Full theme variable reference
