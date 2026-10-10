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
| `bgimage` | surface/string | `beautiful.wibar_bgimage` | Background image, drawn over `bg`, once at its own size. A function is not drawn. See [Background Image](#background-image) |
| `opacity` | number | `1` | Opacity (0.0 to 1.0). Each fill in the bar blends at this opacity on its own, so overlapping fills look denser than the bar's `bg` alone |
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

## Visibility

`visible` is a plain read/write boolean; writing it shows or hides the wibar and updates the screen's workarea.

## Background Image

`bgimage` paints an image on top of the background color. It accepts two kinds of value:

| Value | Behavior |
|-------|----------|
| File path (string) | Loaded with `gears.surface` and cached. A bad path is not an error: it logs a message and draws nothing |
| Cairo surface | Used as-is |

A function is not drawn: setting one warns `wibox.drawable: bgimage functions are not drawn` and clears the image. Nothing paints into a bar any more; the image is an element of the bar's tree, and the renderer draws it ([How SomeWM draws](../../concepts/how-somewm-draws.md)).

The image is painted **once, at its own pixel size, anchored at the top-left corner**. It is not tiled and not stretched; the rest of the bar shows the plain `bg` color. A small texture PNG therefore appears only in the corner. To cover the bar, give it an image the bar's size: tile or scale the texture once with an image tool and set the result.

Notes:

- `beautiful.wibar_bgimage` is read once, when the wibar is constructed, and only if you did not pass `bgimage` yourself. Setting the theme variable after the bar exists does nothing; assign `s.mywibox.bgimage = ...` instead.
- `bgimage` is write-only: reading `s.mywibox.bgimage` does not return the value you set.

For a step-by-step walkthrough, including how to prepare a bar-sized image, see [Put a PNG texture on your wibar](/docs/guides/wibar-background-image).

## Theme Variables

These `beautiful` variables provide defaults for wibars:

| Variable | Description |
|----------|-------------|
| `wibar_bg` | Default background |
| `wibar_fg` | Default foreground |
| `wibar_bgimage` | Default background image (surface or path) |
| `wibar_height` | Default height |
| `wibar_border_color` | Default border color |
| `wibar_border_width` | Default border width |

## See Also

- [Wibar Tutorial](/docs/tutorials/wibar) - Learn how to build wibars
- [awful.wibar (AwesomeWM docs)](https://awesomewm.org/apidoc/classes/awful.wibar.html) - Complete API reference
