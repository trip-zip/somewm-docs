---
sidebar_position: 1
title: wibox
description: Widgets, containers, and the wibar
---

# wibox

`wibox` provides widgets, containers and layouts for bars, popups and other desktop UI.

**Upstream documentation:** [awesomewm.org/apidoc/popups_and_bars/wibox.html](https://awesomewm.org/apidoc/popups_and_bars/wibox.html)

## Widget Types

Widgets come in three categories: primitives that display content, containers that modify a single widget, and layouts that arrange multiple widgets. None of them draws or sizes itself: each declares what it holds and how it is sized, Clay calculates the output tree when layout is dirty, and SomeWM renders the result. [Widgets in SomeWM 2.1](../../concepts/widgets-in-the-tree.md) explains what each class declares, and [Reading the tree](../../concepts/reading-the-tree.md#sizing) maps the layouts and containers below onto the sizing words.

### Primitives

| Widget | Purpose |
|--------|---------|
| `wibox.widget.textbox` | Display text with optional markup |
| `wibox.widget.imagebox` | Display images and icons |
| `wibox.widget.progressbar` | Horizontal progress bars. Use a rotate container for vertical display |
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
| `wibox.container.background` | Add background colour, foreground colour, shape, border. A childless background in a stack paints over the layers below. |
| `wibox.container.margin` | Add padding around a widget |
| `wibox.container.constraint` | Set minimum/maximum size |
| `wibox.container.place` | Align widget within available space (centre, left, etc.). A floating place keeps its whole allocation. |
| `wibox.container.rotate` | Rotate content (90, 180, 270 degrees). Text inside draws as one line. A scroll container inside, or a rotate inside a rotate, is left out with a warning |
| `wibox.container.mirror` | Flip content horizontally or vertically, with the same limits as rotate |
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
| `wibox.layout.grid` | Grid with rows and columns. A non-homogeneous grid no longer sizes a column to the widest cell across rows. A widget added over another is refused. A row span occupies its first row and warns |
| `wibox.layout.ratio.horizontal` | Side by side, proportional widths |
| `wibox.layout.ratio.vertical` | Stacked vertically, proportional heights |
| `wibox.layout.manual` | Absolute positioning |

Custom widgets can compose these components, register a Clay description, or display a Cairo image surface. See [Create or port a custom widget](../../guides/custom-widgets.md) for examples.

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

## Behavioural notes {#behavioral-notes}

SomeWM uses the SNI (StatusNotifierItem) protocol for the system tray instead of X11's XEmbed. See [Wayland vs X11](../../concepts/wayland-vs-x11.md) for details.

`wibox.container.border` is gone. Loading it is an error. Use `wibox.container.background` with `border_width`, `border_color` and `shape`. A widget class with its own `fit`, `draw` or `layout` method is left out of the tree with a warning. See [Upgrading from 2.0 to 2.1](../../getting-started/upgrading-from-2.0.md).
