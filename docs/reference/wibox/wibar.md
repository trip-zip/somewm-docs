---
sidebar_position: 2
title: Wibar Properties
description: Wibar configuration options reference
---

# Wibar Properties

Reference for `awful.wibar` configuration options.

## Basic Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `position` | string | `"top"` | Bar position: `"top"`, `"bottom"`, `"left"`, `"right"` |
| `screen` | screen | - | Screen to attach the wibar to |
| `height` | number | - | Bar height (for top/bottom bars) |
| `width` | number | - | Bar width (for left/right bars) |
| `visible` | boolean | `true` | Whether the wibar is visible |

## Appearance

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `bg` | color | `beautiful.wibar_bg` | Background color |
| `fg` | color | `beautiful.wibar_fg` | Foreground/text color |
| `opacity` | number | `1` | Opacity (0.0 to 1.0) |
| `shape` | function | - | Shape function (e.g., `gears.shape.rounded_rect`) |

## Borders

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `border_width` | number | `0` | Border width in pixels |
| `border_color` | color | - | Border color |

## Margins

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `margins` | table/number | `0` | Margins around the wibar |

Margins can be a number (all sides) or a table:

```lua
margins = {
    top = 8,
    bottom = 0,
    left = 8,
    right = 8,
}
```

## Content

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `widget` | widget | - | The widget tree to display |

## Examples

### Basic Wibar

```lua
awful.wibar {
    position = "top",
    screen = s,
    widget = {
        layout = wibox.layout.align.horizontal,
        { -- Left
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
        },
        s.mytasklist, -- Center
        { -- Right
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.textclock(),
        },
    },
}
```

### Floating Wibar

```lua
awful.wibar {
    position = "top",
    screen = s,
    height = 32,
    margins = {
        top = 8,
        left = 8,
        right = 8,
    },
    shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 8)
    end,
}
```

### Transparent Wibar

```lua
awful.wibar {
    position = "top",
    screen = s,
    bg = beautiful.wibar_bg .. "cc", -- Add alpha
    border_width = 1,
    border_color = beautiful.border_color_normal,
}
```

### Vertical Sidebar

```lua
awful.wibar {
    position = "left",
    screen = s,
    width = 48,
    widget = {
        layout = wibox.layout.align.vertical,
        { -- Top
            layout = wibox.layout.fixed.vertical,
            s.mytaglist,
        },
        nil, -- Middle (empty)
        { -- Bottom
            layout = wibox.layout.fixed.vertical,
            s.mylayoutbox,
        },
    },
}
```

## Controlling Visibility

```lua
-- Toggle wibar
s.mywibox.visible = not s.mywibox.visible

-- Keybinding to toggle
awful.key({ modkey }, "b", function()
    local s = awful.screen.focused()
    s.mywibox.visible = not s.mywibox.visible
end)
```

## Theme Variables

These `beautiful` variables provide defaults for wibars:

| Variable | Description |
|----------|-------------|
| `wibar_bg` | Default background |
| `wibar_fg` | Default foreground |
| `wibar_height` | Default height |
| `wibar_border_color` | Default border color |
| `wibar_border_width` | Default border width |

## See Also

- [Wibar Tutorial](/tutorials/wibar) - Learn how to build wibars
- [awful.wibar (AwesomeWM docs)](https://awesomewm.org/apidoc/classes/awful.wibar.html) - Complete API reference
