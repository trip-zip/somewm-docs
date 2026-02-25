---
sidebar_position: 1
title: wibox
description: Widgets, containers, and the wibar
---

# wibox

The `wibox` library provides the widget system for AwesomeWM/SomeWM. It includes primitive widgets, containers, layouts, and the `wibar` (status bar).

**Upstream documentation:** [awesomewm.org/apidoc/popups_and_bars/wibox.html](https://awesomewm.org/apidoc/popups_and_bars/wibox.html)

## Widget Types

Widgets come in three categories: primitives that display content, containers that modify a single widget, and layouts that arrange multiple widgets.

### Primitives

| Widget | Purpose |
|--------|---------|
| `wibox.widget.textbox` | Display text with optional markup |
| `wibox.widget.imagebox` | Display images and icons |
| `wibox.widget.progressbar` | Horizontal or vertical progress bars |
| `wibox.widget.slider` | Draggable slider controls |
| `wibox.widget.checkbox` | Checkboxes and toggle indicators |
| `wibox.widget.graph` | Line/bar graphs for time series data |
| `wibox.widget.systray` | System tray (SNI on Wayland) |
| `wibox.widget.separator` | Visual separator between widgets |
| `wibox.widget.calendar` | Calendar display |

### Containers

Containers wrap a single child widget to modify its appearance or size.

| Container | Effect |
|-----------|--------|
| `wibox.container.background` | Add background colour, foreground colour, shape, border |
| `wibox.container.margin` | Add padding around a widget |
| `wibox.container.constraint` | Set minimum/maximum size |
| `wibox.container.place` | Align widget within available space (centre, left, etc.) |
| `wibox.container.rotate` | Rotate content (90, 180, 270 degrees) |
| `wibox.container.mirror` | Flip content horizontally or vertically |
| `wibox.container.scroll` | Scroll content that overflows |
| `wibox.container.radialprogressbar` | Circular progress indicator around a widget |
| `wibox.container.arcchart` | Arc-shaped chart around a widget |

### Layouts

Layouts arrange multiple child widgets.

| Layout | Arrangement |
|--------|-------------|
| `wibox.layout.fixed.horizontal` | Side by side, each widget at its natural size |
| `wibox.layout.fixed.vertical` | Stacked vertically, each widget at its natural size |
| `wibox.layout.flex.horizontal` | Side by side, all widgets equal width |
| `wibox.layout.flex.vertical` | Stacked vertically, all widgets equal height |
| `wibox.layout.align.horizontal` | Three sections: left, centre, right |
| `wibox.layout.align.vertical` | Three sections: top, centre, bottom |
| `wibox.layout.stack` | All children occupy the same space (overlapping) |
| `wibox.layout.grid` | Grid with rows and columns |
| `wibox.layout.ratio.horizontal` | Side by side, proportional widths |
| `wibox.layout.ratio.vertical` | Stacked vertically, proportional heights |
| `wibox.layout.manual` | Absolute positioning |

## Widget Composition

Widgets compose by nesting. The `widget` field identifies the type, and children are table entries:

```lua
wibox.widget {
    {
        {
            text = "Hello",
            widget = wibox.widget.textbox,
        },
        margins = 8,
        widget = wibox.container.margin,
    },
    bg = "#333333",
    shape = gears.shape.rounded_rect,
    widget = wibox.container.background,
}
```

Use `id` fields to access nested widgets later:

```lua
local w = wibox.widget {
    {
        id = "my_text",
        text = "",
        widget = wibox.widget.textbox,
    },
    widget = wibox.container.margin,
}

w:get_children_by_id("my_text")[1].text = "Updated"
```

## References

| Reference | Description |
|-----------|-------------|
| [Wibar Properties](./wibar) | Wibar positioning and configuration |

## Behavioral Notes

SomeWM uses the SNI (StatusNotifierItem) protocol for the system tray instead of X11's XEmbed. See [Wayland vs X11](/concepts/wayland-vs-x11) for details.
