---
sidebar_position: 4
title: Theme
description: Customize SomeWM colors, fonts, and appearance
---

# Theme

Create a theme that changes the default desktop's colours, font, borders, and gaps. Start with the default 2.1 `rc.lua`.

## Create the theme

<span id="a-theme-file" />
<span id="a-palette" />
<span id="a-complete-theme" />

Create a directory beside `rc.lua`. Use `themes`, because the default 2.1 config uses the singular name `theme` for a file storing the selected theme name:

```bash
mkdir -p ~/.config/somewm/themes
```

If your config is elsewhere, use that directory instead. Save this as `themes/custom.lua`:

```lua
local gears = require("gears")
local dpi = require("beautiful.xresources").apply_dpi
local theme = dofile(gears.filesystem.get_themes_dir() .. "default/theme.lua")

local colors = {
    bg = "#282828",
    fg = "#ebdbb2",
    selected = "#504945",
    accent = "#fabd2f",
    urgent = "#cc241d",
}

theme.font = "sans 10"
theme.bg_normal = colors.bg
theme.fg_normal = colors.fg
theme.bg_focus = colors.selected
theme.fg_focus = colors.accent
theme.bg_urgent = colors.urgent
theme.fg_urgent = colors.fg
theme.border_color_normal = colors.bg
theme.border_color_active = colors.accent
theme.border_width = dpi(2)
theme.useless_gap = dpi(8)

return theme
```

Loading the shipped theme first preserves its wallpaper and icons. The assignments replace selected values, and `return theme` supplies the table to `beautiful.init`.

## Load it

<span id="when-it-does-not-apply" />

In `rc.lua`, replace the existing `beautiful.init(...)` call with:

```lua
beautiful.init(gears.filesystem.get_configuration_dir() .. "themes/custom.lua")
```

The menu's built-in theme switcher writes a theme name for the original loader. With this fixed custom path, its selections no longer change the loaded theme.

Keep this before widget modules and lockscreen initialisation. Widgets that copy theme values during construction need those values available at that point.

Reload with **Mod4+Ctrl+r**. Check the dark background, yellow active border, and larger gaps with two tiled windows. If the theme fails to load, check the notification, the file path, and the final `return theme`.

## Style the bar and tags

Add these assignments before `return theme` in the theme file:

```lua
theme.wibar_bg = colors.bg
theme.wibar_fg = colors.fg
theme.wibar_height = dpi(28)
theme.taglist_bg_focus = colors.selected
theme.taglist_fg_focus = colors.accent
theme.tasklist_bg_focus = colors.selected
theme.tasklist_fg_focus = colors.fg
```

Reload and switch tags to see the selected tag's colours. Explicit properties in a widget declaration override its theme defaults.

`dpi(28)` scales the number using the configured DPI when the theme loads. It does not follow later DPI changes or infer a scale from the monitor's resolution. SomeWM's output scaling is separate. See [fractional scaling](../guides/fractional-scaling.md).

## Change the wallpaper

<span id="wallpaper-icons-widget-families" />

Choose an existing image and set its absolute path before `return theme`, for example:

```lua
theme.wallpaper = os.getenv("HOME") .. "/Pictures/wallpaper.jpg"
```

The default `request::wallpaper` handler reads this property when `wallpaper_colors` is unset. This tutorial inherits the shipped `default` theme, which has no `wallpaper_colors`. If you instead inherit a gradient theme, also set `theme.wallpaper_colors = nil`. Save and reload to see the image. Substitute a path that exists on your machine.

For more settings, use the [theme variables reference](../reference/beautiful/theme-variables.md). Continue with [Widgets](widgets.md) to use the theme in your own clock.
