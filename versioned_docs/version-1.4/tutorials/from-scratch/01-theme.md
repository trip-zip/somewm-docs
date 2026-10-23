---
title: "Theme: Palettes, Shapes, Recolored Assets"
description: "Create a theme with named palettes, shared fonts, shapes, and recoloured icons."
sidebar_label: "01 · Theme"
---

import SomewmOnly from '@site/src/components/SomewmOnly';
import ChapterNav from '@site/src/components/FromScratch/ChapterNav';
import NextChapter from '@site/src/components/FromScratch/NextChapter';

# Theme: Palettes, Shapes, Recolored Assets

<ChapterNav chapter="01" />

<span id="where-we-are" />

This chapter replaces the default theme with `theme/theme.lua`. Start from [chapter 00](./00-default.md): `git checkout 00-default`.

## Load the theme {#what-beautiful-actually-is}

`beautiful.init(path)` loads a Lua table of theme values. Widgets read them through `beautiful`, such as `beautiful.bg_normal`.

Stock widgets recognise built-in keys such as `bg_normal`, `border_width`, and `font`. Unset keys use the component's defaults.

Custom keys affect only code that reads them. This series defines `primary_color`, `shape`, and `font_size` for its own widgets.

Load your theme in `rc.lua`:

```lua
-- rc.lua
beautiful.init(config_dir .. "theme/theme.lua")
```

Define `config_dir` at the top of `rc.lua`, before loading the theme:

```lua
-- rc.lua
local config_dir = require("gears.filesystem").get_configuration_dir()
package.path = config_dir .. "?.lua;" .. config_dir .. "?/init.lua;" .. package.path
```

`get_configuration_dir()` returns the directory of the loaded `rc.lua`, including a trailing slash. This works from an installed config or a checkout. The `package.path` line lets `require()` find modules beside `rc.lua`.

## Where This File Comes From

Copy the default theme and its assets. Run these commands from the checkout root.

On SomeWM:

```bash
mkdir -p theme
cp /usr/share/somewm/themes/default/theme.lua theme/theme.lua
cp /usr/share/somewm/themes/default/submenu.png theme/
cp -r /usr/share/somewm/themes/default/layouts theme/layouts
```

On AwesomeWM:

```bash
mkdir -p theme
cp /usr/share/awesome/themes/default/theme.lua theme/theme.lua
cp /usr/share/awesome/themes/default/submenu.png theme/
cp -r /usr/share/awesome/themes/default/layouts theme/layouts
```

Both are packaged-install paths. A source build lands under `/usr/local` instead (`/usr/local/share/somewm/themes/`, `/usr/local/share/awesome/themes/`). If neither exists, ask the running window manager, which is the same call `beautiful` uses internally:

```bash
somewm-client eval 'return require("gears.filesystem").get_themes_dir()'  # SomeWM
awesome-client 'return require("gears.filesystem").get_themes_dir()'      # AwesomeWM
```

The theme uses the white layout icons (`*w.png`). Extra files copied from the default theme are harmless.

Also copy `square.svg` and `rounded_square.svg` from the chapter's [`theme/titlebar/`](https://github.com/trip-zip/awesome-from-scratch/tree/01-theme/theme/titlebar) into your config's `theme/titlebar/`. These are new assets, not included in the default theme.

Edit that copy using the sections below:

| The default theme | What we turn it into |
| --- | --- |
| Hex codes inline (`theme.bg_normal = "#222222"`) | Named palettes plus semantic roles |
| `themes_path = get_themes_dir()`, assets read from the install | `theme_path = config_dir .. "theme"`, assets vendored beside `rc.lua` |
| Image paths used as-is | Every image passed through `recolor()` |
| `theme.font = "sans 8"` | One `font_family` and a `theme.font_size()` builder |
| `theme.wallpaper` pointing at a shipped PNG | A per-screen wallpaper list in `rc.lua` |
| `theme.icon_theme = nil` | `"Papirus"` |
| Taglist square markers from `theme_assets` | Dropped. The chapter 04 taglist renders icons instead |
| An urgent-notification `ruled.notification` rule | Dropped. Chapter 06 rebuilds notifications from scratch |

Point `beautiful.init` at your copy and reload before changing anything, so you know the copy itself is sound.

At the top of your copied theme, keep these imports and replace its path and table setup with:

```lua
-- theme/theme.lua
local gears = require("gears")
local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local recolor = require("gears").color.recolor_image
local config_dir = gears.filesystem.get_configuration_dir()
local theme_path = config_dir .. "theme"
local theme = {}
theme.icon_dir = config_dir .. "icons"
```

## Palettes: Named Colors, One Switch

Define the palettes in a `colors` table:

```lua
-- theme/theme.lua
local colors = {
  gruvbox = {
    bg = "#282828", -- bg(0) in palette
    fg = "#ebdbb2", -- fg(15) in palette
    grey1 = "#928374", -- gray in palette
    grey2 = "#3c3836", -- bg1 in palette
    red = "#cc241d", -- red(0) in palette
    soft_red = "#fb4934", -- red(9) in palette
    green = "#98971a", -- green(2) in palette
    soft_green = "#b8bb26", -- green(10) in palette
```

The complete `gruvbox` and `nord` palettes use the same keys. Select one:

```lua
-- theme/theme.lua
local color_scheme = "gruvbox"
local color = colors[color_scheme]
```

Change `"gruvbox"` to `"nord"` and reload to switch palettes.

:::note
The Nord palette repeats a few hexes (`red` and `soft_red` are both `#BF616A`, for example). Nord simply has fewer accent colors than gruvbox, so the "soft" variants collapse onto their base color. The keys still exist so lookups never fail.
:::

## Name colours by their use {#semantic-roles-the-layer-that-makes-switching-work}

Assign colours to roles that widgets can use:

```lua
-- theme/theme.lua
theme.primary_color = color.orange
theme.primary_color_hover = color.soft_orange
theme.active = color.green
theme.active_hover = color.soft_green
theme.accent = color.yellow
theme.accent_hover = color.soft_yellow
theme.highlight = color.blue
theme.highlight_hover = color.soft_blue
theme.urgent = color.red
theme.urgent_hover = color.soft_red
theme.fg_dim = color.grey1 -- secondary text: dates, hints, muted status lines
```

Widgets use these roles: `beautiful.active` for enabled toggles, `beautiful.primary_color` for selected launcher rows, and `beautiful.urgent` for battery warnings. The `_hover` variants apply on mouse-over. `fg_dim` is for secondary text.

Set built-in theme variables from the palette:

```lua
-- theme/theme.lua
theme.bg_normal = color.bg
theme.bg_focus = color.grey2
theme.bg_urgent = color.soft_red
theme.bg_minimize = color.grey1
theme.bg_systray = color.bg
```

`bg_normal` and `fg_normal` supply default colours for bars, popups, and tooltips.

## One Font Family, One Builder

Define the font family once and use a helper to build font strings:

```lua
-- theme/theme.lua
theme.font_family = "JetBrainsMono Nerd Font"
function theme.font_size(size, style)
  return theme.font_family .. " " .. (style and (style .. " ") or "") .. size
end
theme.font = theme.font_size(10)
```

`beautiful.font_size(24, "Bold")` returns `"JetBrainsMono Nerd Font Bold 24"`. Change `theme.font_family` to update fonts throughout the config.

## DPI-Aware Sizing

`xresources.apply_dpi`, aliased to `dpi`, scales sizes using the configured DPI when called. Without a screen argument, these theme values use the global DPI. Output scaling is separate.

```lua
-- theme/theme.lua
theme.useless_gap = dpi(8)
theme.border_width = dpi(1)
theme.border_color_normal = color.bg
theme.border_color_active = color.soft_orange
theme.border_color_marked = color.red
```

`useless_gap` sets the gap between tiled windows. This theme also sets `wibar_height` to five times that gap and wibar margins to twice it. Use `dpi()` for theme sizes.

## The Shape System

A widget's `shape` function draws an outline on a Cairo context: `function(cr, width, height)`. Use one helper to select between `gears.shape` functions:

```lua
-- theme/theme.lua
theme.shape_style = "rectangle"
theme.corner_radius = 12 -- Only used when shape_style = "rounded"

function theme.shape(cr, w, h)
  if theme.shape_style == "rounded" then
    gears.shape.rounded_rect(cr, w, h, theme.corner_radius)
  else
    gears.shape.rectangle(cr, w, h)
  end
end
```

Set `shape = beautiful.shape` on widgets that should follow `shape_style`. The `theme.shape_small` helper uses half the radius, capped at 6, for buttons and toggles.

## Recoloring Assets at Load Time

<span id="the-commented-reference-block" />

`gears.color.recolor_image(path, color)`, aliased to `recolor`, returns an in-memory copy of an image tinted to the given colour.

Select a titlebar icon by shape and tint it for each state:

```lua
-- theme/theme.lua
local titlebar_icon = theme.shape_style == "rounded" and theme_path .. "/titlebar/rounded_square.svg"
  or theme_path .. "/titlebar/square.svg"

theme.titlebar_close_button_normal = recolor(titlebar_icon, color.grey1)
theme.titlebar_close_button_focus = recolor(titlebar_icon, color.soft_red)
```

The two SVGs are in `theme/titlebar/`. Tint the white layout PNGs the same way:

```lua
-- theme/theme.lua
theme.layout_fairh = recolor(theme_path .. "/layouts/fairhw.png", color.fg)
theme.layout_fairv = recolor(theme_path .. "/layouts/fairvw.png", color.fg)
theme.layout_floating = recolor(theme_path .. "/layouts/floatingw.png", color.fg)
```

## The Rest of the File

The remaining settings apply the same colours, shapes, and sizes to notifications, taglists, menus, and other widgets. `systray_icon_style` is a SomeWM extension for per-app tray styling. AwesomeWM ignores it.

The commented theme settings are examples. Assign a value when uncommenting one, since assigning `nil` removes any earlier value.

End the file with:

```lua
-- theme/theme.lua
return theme
```

## Wallpapers in rc.lua

Replace the stock wallpaper handler in `rc.lua` with a per-screen image list and setter:

```lua
-- rc.lua
local wallpapers = {
  config_dir .. "wallpapers/penguin.jpg",
  config_dir .. "wallpapers/spaceman.jpg",
}

local function set_wallpaper(s)
  local wp = wallpapers[s.index] or wallpapers[1]
  if wp and gears.filesystem.file_readable(wp) then
    awful.wallpaper({
      screen = s,
      bg = "#282828",
      widget = {
        image = wp,
        upscale = true,
        downscale = true,
        halign = "center",
        valign = "center",
        widget = wibox.widget.imagebox,
      },
    })
  else
    awful.wallpaper({ screen = s, bg = "#282828" })
  end
end

screen.connect_signal("request::wallpaper", function(s)
  set_wallpaper(s)
end)
```

Screens use the wallpaper at their index. Extra screens reuse the first. The imagebox preserves the image aspect ratio, so uncovered space uses the background colour. Missing files produce a solid background. `request::wallpaper` runs at startup and on geometry changes.

### Screen Scaling <SomewmOnly />

For SomeWM, optionally set output scales:

```lua
-- rc.lua
local screen_scales = {
  -- [1] = 1.5,
}

awful.screen.connect_for_each_screen(function(s)
  local scale = screen_scales[s.index]
  if scale then
    s.scale = scale
  end
end)
```

`screen.scale` is SomeWM-only. Leave the table empty on AwesomeWM and configure X11 display scaling separately. See [fractional scaling](../../guides/fractional-scaling.md) for SomeWM output scales and DPI.

## The Rest of the rc.lua Diff

Set the default applications in `rc.lua`:

```lua
-- rc.lua
terminal = "ghostty"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = "ghostty -e " .. editor
filemanager = "thunar"
```

Use applications you have installed. Move `awful.layout.suit.tile` before `awful.layout.suit.floating` in `request::default_layouts` to start new tags tiled. To disable focus following the mouse, comment out this handler:

```lua
-- client.connect_signal("mouse::enter", function(c)
--   c:activate({ context = "mouse_enter", raise = false })
-- end)
```

Remove the X11-config startup notice and `require("lockscreen").init()` for AwesomeWM. The `lockscreen` module is SomeWM-only, so requiring it fails on AwesomeWM. [Chapter 12](./12-lockscreen.md) covers locking on both compositors.

The checkpoint includes `.stylua.toml` for formatting with `stylua .`.

## Try It

1. Add a third palette. Copy the `nord` table, rename it (`catppuccin`, `dracula`, whatever you like), replace the hex values, and point `color_scheme` at it. Keep every key name.
2. Set `theme.shape_style = "rounded"` and reload. Check the titlebar buttons. Then change `theme.font_family` to an installed font and reload.

![The same stock layout after the theme chapter: gruvbox colors, themed bar and borders](/img/from-scratch/01-theme-themed.png)

## Checkpoint

The finished code for this chapter is on [the `01-theme` branch](https://github.com/trip-zip/awesome-from-scratch/tree/01-theme).

Use the [nested-session commands](index.md#running-your-work-safely) to run this checkpoint. Stop the previous instance before switching branches.

Compare your work: `git diff origin/00-default origin/01-theme`

<NextChapter chapter="01" />
