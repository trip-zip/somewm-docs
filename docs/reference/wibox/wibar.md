---
sidebar_position: 2
title: Wibar Properties
description: Wibar configuration options reference
---

# Wibar Properties

`awful.wibar` attaches a wibox to a screen edge. By default it reserves workarea space, so tiled clients do not cover it. Constructor arguments override `beautiful.wibar_*` theme values.

## Basic Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `position` | string | `"top"` | Bar position: `"top"`, `"bottom"`, `"left"`, `"right"` |
| `screen` | screen/number | `1` | Screen to attach the wibar to |
| `height` | number | Theme or font-based | Thickness for top/bottom bars |
| `width` | number | Theme or font-based | Thickness for left/right bars |
| `stretch` | boolean | `true` unless length is specified | Fill the screen edge |
| `align` | string | `"centered"` | Alignment when not stretched: `"left"`, `"right"`, `"top"`, `"bottom"`, or `"centered"` |
| `restrict_workarea` | boolean | `true` | Reserve space when visible and not `ontop` |
| `visible` | boolean | `true` | Whether the wibar is visible |
| `ontop` | boolean | `beautiful.wibar_ontop` or `false` | Draw above ordinary clients without reserving workarea |
| `animation` | table/boolean | `nil` | Visibility transitions. See [Animation](../../guides/animation.md#wiboxes-and-popups) |

## Appearance

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `bg` | color | `beautiful.wibar_bg` | Background color |
| `fg` | color | `beautiful.wibar_fg` | Foreground/text color |
| `bgimage` | surface/string | `beautiful.wibar_bgimage` | Background image, drawn over `bg`. See [Background Image](#background-image) |
| `opacity` | number | `beautiful.wibar_opacity` or `1` | Applies to each fill separately. Overlapping fills accumulate opacity |
| `shape` | function | `beautiful.wibar_shape` | Shape function (e.g., `gears.shape.rounded_rect`) |

## Borders

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `border_width` | number | `beautiful.wibar_border_width` or `0` | Border width in pixels |
| `border_color` | color | `beautiful.wibar_border_color` | Border color |

## Margins

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `margins` | table/number | `beautiful.wibar_margins` or `0` | Margins around the wibar |

Margins can be a number (all sides) or a table:

```lua
local margins = {
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

If no thickness is supplied by the arguments or theme, it is `ceil(1.5 * beautiful.get_font_height(font))`. A horizontal bar’s width or a vertical bar’s height sets its length and disables stretching by default. At construction, length can be a percentage string when `screen` is explicitly supplied.

## Examples

### Basic Wibar

```lua
local awful = require("awful")
local wibox = require("wibox")

local bar = awful.wibar {
    screen = screen.primary,
    position = "top",
    height = 32,
    widget = wibox.widget.textclock(),
}
```

### Floating Wibar

`margins = 8` leaves space around the bar. A shape changes its outline. See the [wibar tutorial](../../tutorials/wibar.md) for composition examples.

### Transparent Wibar

Use a colour with alpha, such as `bg = "#222222cc"`, or set `opacity` to affect all its fills. Overlapping fills blend separately in 2.1. Appending alpha to an arbitrary theme value is unsafe because colours can already include alpha or be Cairo patterns.

### Vertical Sidebar

<span id="visibility" />

Use `position = "left"` or `"right"` and specify `width` for thickness.

## Controlling Visibility

```lua
bar.visible = not bar.visible
```

Changing `visible` schedules layout. Clay then updates the reserved workarea and queues `property::workarea`. A read immediately after the assignment can still return the old workarea.

## Background Image

`bgimage` paints an image on top of the background color. It accepts these values:

| Value | Behavior |
|-------|----------|
| File path (string) | Loaded with `gears.surface` and cached. A bad path is not an error: it logs a message and draws nothing |
| Cairo surface | Used as-is |
| Function | Unsupported. Warns and clears the image |

A path or surface is painted once at native size, from the top-left corner. It is neither tiled nor stretched. The remaining area shows `bg`.

`beautiful.wibar_bgimage` is read at construction when no explicit `bgimage` is supplied. Later changes require assigning `bar.bgimage`. The property is write-only in 2.1.

See [wibar background images](../../guides/wibar-background-image.md) for tiled and stretched images.

## Theme Variables

These `beautiful` variables provide defaults for wibars:

| Variable | Description |
|----------|-------------|
| `wibar_bg` | Default background |
| `wibar_fg` | Default foreground |
| `wibar_bgimage` | Default background image (surface or path) |
| `wibar_height`, `wibar_width` | Default dimensions |
| `wibar_shape`, `wibar_opacity` | Shape and opacity |
| `wibar_ontop`, `wibar_type`, `wibar_cursor` | Stacking, window type and pointer cursor |
| `wibar_font` | Font used to calculate default thickness |
| `wibar_margins`, `wibar_align`, `wibar_stretch` | Placement |
| `wibar_shadow` | Shadow override |
| `wibar_border_color` | Default border color |
| `wibar_border_width` | Default border width |

## See Also

- [Wibar Tutorial](/docs/next/tutorials/wibar) - Learn how to build wibars
- [awful.wibar (AwesomeWM docs)](https://awesomewm.org/apidoc/classes/awful.wibar.html) - Complete API reference
