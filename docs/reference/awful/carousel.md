---
sidebar_position: 1.6
title: awful.layout.suit.carousel
description: Scrollable tiling layout API reference
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# awful.layout.suit.carousel <SomewmOnly />

A scrollable tiling layout where clients are arranged as columns on an infinite horizontal strip. The viewport auto-scrolls to keep the focused column visible, with smooth animation between positions.

Two orientations are available:

| Layout | Name | Orientation |
|--------|------|-------------|
| `awful.layout.suit.carousel` | `"carousel"` | Horizontal (columns scroll left/right) |
| `awful.layout.suit.carousel.vertical` | `"carousel.vertical"` | Vertical (columns scroll up/down) |

```lua
local awful = require("awful")

-- Register carousel in your layout list
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        awful.layout.suit.carousel,
        awful.layout.suit.carousel.vertical,
        -- ...other layouts
    })
end)
```

## Configuration Properties

These properties are set directly on the layout table. They apply globally to all tags using the carousel layout.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `carousel.default_column_width` | number | `1.0` | Width fraction for new columns (1.0 = full viewport width) |
| `carousel.width_presets` | table | `{1/3, 1/2, 2/3, 1.0}` | Preset fractions cycled by `cycle_column_width()` |
| `carousel.center_mode` | string | `"on-overflow"` | Viewport centering behavior (see [Centering Modes](#centering-modes)) |
| `carousel.scroll_duration` | number | `0.2` | Scroll animation duration in seconds (0 = instant snap) |
| `carousel.peek_width` | number | `0` | Pixels of visible content on each side to show adjacent column edges (`useless_gap` is added automatically) |

```lua
local carousel = awful.layout.suit.carousel

-- Make new columns half-width by default
carousel.default_column_width = 0.5

-- Use wider presets
carousel.width_presets = { 0.5, 0.75, 1.0 }

-- Instant scrolling
carousel.scroll_duration = 0

-- Show 40px of adjacent columns
carousel.peek_width = 40
```

## Theme Variables

These can be set in your `beautiful` theme to override carousel defaults.

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `beautiful.carousel_default_column_width` | number | `1.0` | Default width fraction for new columns |
| `beautiful.carousel_peek_width` | number | `0` | Pixels of visible content on each side for adjacent column edges (`useless_gap` is added automatically) |
| `beautiful.carousel_center_mode` | string | `"on-overflow"` | Viewport centering behavior |
| `beautiful.layout_carousel` | surface | nil | Layoutbox icon for the carousel layout |

Theme variables take priority over the properties set directly on the layout table.

```lua
-- In your theme.lua
theme.carousel_default_column_width = 0.5
theme.carousel_peek_width = 40
theme.carousel_center_mode = "always"
theme.layout_carousel = theme_dir .. "/layouts/carousel.png"
```

## Column Width Functions

All column width functions operate on the currently focused column.

### `carousel.cycle_column_width()`

Cycle the focused column's width through the `width_presets` list. If the current width does not match any preset, the cycle starts from the first preset.

```lua
awful.key({ modkey }, "bracketright", function()
    awful.layout.suit.carousel.cycle_column_width()
end, { description = "cycle column width", group = "carousel" })
```

### `carousel.adjust_column_width(delta)`

Adjust the focused column's width by a delta fraction. The result is clamped to the range [0.1, 2.0].

| Parameter | Type | Description |
|-----------|------|-------------|
| `delta` | number | Fraction to add (e.g. `0.1` to widen, `-0.1` to narrow) |

```lua
awful.key({ modkey, "Control" }, "l", function()
    awful.layout.suit.carousel.adjust_column_width(0.05)
end, { description = "widen column", group = "carousel" })

awful.key({ modkey, "Control" }, "h", function()
    awful.layout.suit.carousel.adjust_column_width(-0.05)
end, { description = "narrow column", group = "carousel" })
```

### `carousel.set_column_width(fraction)`

Set the focused column's width to an exact fraction. Clamped to [0.1, 2.0].

| Parameter | Type | Description |
|-----------|------|-------------|
| `fraction` | number | The width fraction to set |

```lua
-- Set focused column to exactly half the viewport
awful.layout.suit.carousel.set_column_width(0.5)
```

### `carousel.maximize_column()`

Set the focused column's width to 1.0 (full viewport width).

```lua
awful.key({ modkey }, "m", function()
    awful.layout.suit.carousel.maximize_column()
end, { description = "maximize column", group = "carousel" })
```

## Vertical Stacking Functions

These functions move clients between columns, creating or dissolving vertical stacks within a single column.

### `carousel.consume_window(dir)`

Pull the first client from an adjacent column into the focused column, stacking it vertically. If the source column becomes empty, it is removed.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dir` | number | Direction: `-1` for left/up, `1` for right/down |

```lua
awful.key({ modkey, "Shift" }, "l", function()
    awful.layout.suit.carousel.consume_window(1)
end, { description = "consume window from right", group = "carousel" })

awful.key({ modkey, "Shift" }, "h", function()
    awful.layout.suit.carousel.consume_window(-1)
end, { description = "consume window from left", group = "carousel" })
```

### `carousel.expel_window()`

Move the focused client out of its column into a new column inserted after the current one. The new column inherits the source column's width. No-op if the column contains only one client.

```lua
awful.key({ modkey, "Shift" }, "e", function()
    awful.layout.suit.carousel.expel_window()
end, { description = "expel window to new column", group = "carousel" })
```

### `carousel.push_window(dir)`

Move the focused client in the given direction. The behavior depends on whether the focused client is alone in its column:

- **Solo window** (only client in its column): Consumes into the adjacent column in the given direction, merging with that column's stack. If there is no neighbor in that direction, the push is a no-op.
- **Stacked window** (multiple clients in the column): Expels the focused client into a new column inserted in the given direction. The new column inherits the source column's width.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dir` | number | Direction: `-1` for left/up, `1` for right/down |

```lua
awful.key({ modkey, "Control" }, "l", function()
    awful.layout.suit.carousel.push_window(1)
end, { description = "push window right", group = "carousel" })

awful.key({ modkey, "Control" }, "h", function()
    awful.layout.suit.carousel.push_window(-1)
end, { description = "push window left", group = "carousel" })
```

## Column Movement

### `carousel.move_column(dir)`

Swap the focused column with its neighbor in strip order.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dir` | number | Direction: `-1` for left/up, `1` for right/down |

```lua
awful.key({ modkey, "Mod1" }, "l", function()
    awful.layout.suit.carousel.move_column(1)
end, { description = "move column right", group = "carousel" })

awful.key({ modkey, "Mod1" }, "h", function()
    awful.layout.suit.carousel.move_column(-1)
end, { description = "move column left", group = "carousel" })
```

## Edge Focus

### `carousel.focus_first_column()`

Focus the first client in the first column on the strip.

### `carousel.focus_last_column()`

Focus the first client in the last column on the strip.

```lua
awful.key({ modkey }, "Home", function()
    awful.layout.suit.carousel.focus_first_column()
end, { description = "focus first column", group = "carousel" })

awful.key({ modkey }, "End", function()
    awful.layout.suit.carousel.focus_last_column()
end, { description = "focus last column", group = "carousel" })
```

## Viewport Control

### `carousel.set_center_mode(mode)`

Set the viewport centering mode at runtime and immediately re-arrange. If `beautiful.carousel_center_mode` is set, the theme value takes precedence over the value passed here.

| Parameter | Type | Description |
|-----------|------|-------------|
| `mode` | string | One of `"never"`, `"always"`, `"on-overflow"`, `"edge"` |

```lua
awful.layout.suit.carousel.set_center_mode("always")
```

### `carousel.scroll_by(tag, n)`

Scroll the viewport by `n` viewport-widths. Positive scrolls right/down, negative scrolls left/up. The offset is clamped to strip boundaries.

| Parameter | Type | Description |
|-----------|------|-------------|
| `tag` | tag | The tag to scroll |
| `n` | number | Number of viewport-widths to scroll (fractional values allowed) |

```lua
-- Scroll half a viewport to the right
local t = awful.screen.focused().selected_tag
awful.layout.suit.carousel.scroll_by(t, 0.5)
```

## Centering Modes

The centering mode controls how the viewport follows the focused column.

| Mode | Behavior |
|------|----------|
| `"on-overflow"` | Center the focused column only when it would be partially or fully offscreen. Default. |
| `"always"` | Always center the focused column, even if it is already visible. |
| `"never"` | Only scroll when the focused column is completely offscreen. The viewport stays still if any part of the column is visible. |
| `"edge"` | Scroll the minimum distance needed to bring the focused column fully into view, aligned to the nearest edge. |

Set the mode at startup in `rc.lua`:

```lua
awful.layout.suit.carousel.center_mode = "always"
```

Or switch at runtime:

```lua
awful.layout.suit.carousel.set_center_mode("edge")
```

## Gesture Binding

### `carousel.make_gesture_binding()`

Create a 3-finger swipe gesture binding for horizontal viewport panning. During the swipe, the viewport tracks finger movement 1:1. On release, the viewport snaps to the nearest column and focuses it.

Returns a gesture binding object. Call `:remove()` on it to unbind.

```lua
local carousel = awful.layout.suit.carousel
carousel.make_gesture_binding()
```

### `carousel.vertical.make_gesture_binding()`

Same as above, but uses the vertical (dy) swipe axis. For use with the vertical carousel variant.

```lua
local carousel = awful.layout.suit.carousel
carousel.vertical.make_gesture_binding()
```

## Automatic Behaviors

The carousel layout handles several things automatically:

- **Focus auto-scroll.** When focus changes to a client in a different column, the viewport scrolls to bring that column into view. Focus changes within the same column (between stacked clients) do not trigger scrolling.
- **New window insertion.** New clients are inserted as columns immediately after the focused column. If no column is focused, they are appended to the end of the strip.
- **Empty column cleanup.** When a client is closed or moved, any column that becomes empty is automatically removed from the strip.
- **Reconciliation.** On every arrange call, the column state is reconciled against the live client list. Clients removed by other means (rules, signals) are cleaned up and new clients are adopted.
- **Strip centering.** If the total strip width is narrower than the viewport, the strip is centered in the available space.

## See Also

- **[Scrollable Tiling](/concepts/scrollable-tiling)** - How the strip, viewport, and animation model works
- **[Carousel Tutorial](/tutorials/carousel)** - Step-by-step first session with the carousel layout
- **[Column Widths Guide](/guides/carousel-column-widths)** - Resize and customize column widths
- **[Stacking Guide](/guides/carousel-stacking)** - Consume, expel, and push windows between columns
- **[Gesture Scrolling Guide](/guides/carousel-gestures)** - Set up touchpad gesture panning
- **[Centering Modes Guide](/guides/carousel-centering)** - Choose and configure viewport centering
- **[Layout Protocol Reference](/reference/awful/layout)** - The `arrange(p)` contract and built-in layouts
