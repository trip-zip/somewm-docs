---
sidebar_position: 1.6
title: awful.layout.suit.carousel
description: Scrollable tiling layout API reference
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# awful.layout.suit.carousel <SomewmOnly />

Carousel arranges clients in columns and scrolls the viewport to keep the focused column visible.

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

Set these on `awful.layout.suit.carousel`. Both orientations share them across all tags.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `carousel.default_column_width` | number | `1.0` | Width fraction for new columns (1.0 = full viewport width) |
| `carousel.width_presets` | table | `{1/3, 1/2, 2/3, 1.0}` | Preset fractions cycled by `cycle_column_width()` |
| `carousel.center_mode` | string | `"on-overflow"` | Viewport centering behavior (see [Centering Modes](#centering-modes)) |
| `carousel.scroll_duration` | number | `0.2` | Scroll animation duration in seconds (0 = instant snap) |
| `carousel.peek_width` | number | `0` | Space reserved on each side of the viewport, in logical pixels |

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
| `beautiful.carousel_peek_width` | number | `0` | Space reserved on each side, in logical pixels |
| `beautiful.layout_carousel` | surface | nil | Layoutbox icon for the carousel layout |

`beautiful.carousel_default_column_width` and `beautiful.carousel_peek_width` override the corresponding layout properties. There is no `beautiful.carousel_center_mode` setting in 1.4.

```lua
local beautiful = require("beautiful")
beautiful.carousel_default_column_width = 0.5
beautiful.carousel_peek_width = 40
```

## Column Width Functions

These functions act on the focused column of the selected carousel tag. In the vertical variant, width fractions control column height and clients stack horizontally. A fraction of 1 uses `max(1, viewport_size - 2 * peek_width)`, before client border and gap adjustments.

### `carousel.cycle_column_width()`

Cycle the focused column's width through the `width_presets` list. If the current width does not match any preset, the cycle starts from the first preset.

```lua
awful.layout.suit.carousel.cycle_column_width()
```

### `carousel.adjust_column_width(delta)`

Adjust the focused column's width by a delta fraction. The result is clamped to the range [0.1, 2.0].

| Parameter | Type | Description |
|-----------|------|-------------|
| `delta` | number | Fraction to add (e.g. `0.1` to widen, `-0.1` to narrow) |

```lua
awful.layout.suit.carousel.adjust_column_width(0.05)
awful.layout.suit.carousel.adjust_column_width(-0.05)
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
awful.layout.suit.carousel.maximize_column()
```

## Vertical Stacking Functions

These functions move clients between columns, creating or dissolving vertical stacks within a single column.

### `carousel.consume_window(dir)`

Pull the first client from an adjacent column into the focused column, stacking it vertically. If the source column becomes empty, it is removed.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dir` | number | Direction: `-1` for left/up, `1` for right/down |

```lua
awful.layout.suit.carousel.consume_window(1)
awful.layout.suit.carousel.consume_window(-1)
```

### `carousel.expel_window()`

Move the focused client out of its column into a new column inserted after the current one. The new column inherits the source column's width. No-op if the column contains only one client.

```lua
awful.layout.suit.carousel.expel_window()
```

### `carousel.push_window(dir)`

Move the focused client in the given direction. The behavior depends on whether the focused client is alone in its column:

- **Solo window** (only client in its column): Consumes into the adjacent column in the given direction, merging with that column's stack. If there is no neighbor in that direction, the push is a no-op.
- **Stacked window** (multiple clients in the column): Expels the focused client into a new column inserted in the given direction. The new column inherits the source column's width.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dir` | number | Direction: `-1` for left/up, `1` for right/down |

```lua
awful.layout.suit.carousel.push_window(1)
awful.layout.suit.carousel.push_window(-1)
```

## Column Movement

### `carousel.move_column(dir)`

Swap the focused column with its neighbor in strip order.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dir` | number | Direction: `-1` for left/up, `1` for right/down |

```lua
awful.layout.suit.carousel.move_column(1)
awful.layout.suit.carousel.move_column(-1)
```

## Edge Focus

### `carousel.focus_first_column()`

Focus the first client in the first column on the strip.

### `carousel.focus_last_column()`

Focus the first client in the last column on the strip.

```lua
awful.layout.suit.carousel.focus_first_column()
awful.layout.suit.carousel.focus_last_column()
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

- **Focus auto-scroll.** When focus changes to a client in a different column, the viewport scrolls to bring that column into view. Focus changes within the same column (between stacked clients) do not trigger scrolling.
- **New window insertion.** New clients are inserted as columns immediately after the focused column. If no column is focused, they are appended to the end of the strip.
- **Empty column cleanup.** When a client is closed or moved, any column that becomes empty is automatically removed from the strip.
- **Client list updates.** Each layout pass removes clients that left the tag and adds newly tiled clients.
- **Strip centering.** If the total strip width is narrower than the viewport, the strip is centered in the available space.

## See Also

- **[Scrollable Tiling](/docs/1.4/concepts/scrollable-tiling)** - How the strip, viewport, and animation model works
- **[Carousel Tutorial](/docs/1.4/tutorials/carousel)** - Step-by-step first session with the carousel layout
- **[Column Widths Guide](/docs/1.4/guides/carousel-column-widths)** - Resize and customize column widths
- **[Stacking Guide](/docs/1.4/guides/carousel-stacking)** - Consume, expel, and push windows between columns
- **[Gesture Scrolling Guide](/docs/1.4/guides/carousel-gestures)** - Set up touchpad gesture panning
- **[Centering Modes Guide](/docs/1.4/guides/carousel-centering)** - Choose and configure viewport centering
- **[Layout Protocol Reference](/docs/1.4/reference/awful/layout)** - The `arrange(p)` contract and built-in layouts
