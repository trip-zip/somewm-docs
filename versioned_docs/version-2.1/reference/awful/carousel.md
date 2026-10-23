---
sidebar_position: 1.6
title: awful.layout.suit.carousel
description: Scrollable tiling layout API reference
---

import SomewmOnly from '@site/src/components/SomewmOnly'

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
| `carousel.peek_width` | number | `0` | Space reserved on each side of the viewport, in logical pixels |
| `carousel.dynamic_peek_width` | number | `-1` | Edge-column margin in logical pixels. Negative disables the adjustment |

```lua
local carousel = awful.layout.suit.carousel

-- Make new columns half-width by default
carousel.default_column_width = 0.5

-- Use wider presets
carousel.width_presets = { 0.5, 0.75, 1.0 }

-- Show 40px of adjacent columns
carousel.peek_width = 40
```

## Theme Variables

<span id="direction-and-state" />

These can be set in your `beautiful` theme to override carousel defaults.

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `beautiful.carousel_default_column_width` | number | `1.0` | Default width fraction for new columns |
| `beautiful.carousel_peek_width` | number | `0` | Space reserved on each side, in logical pixels |
| `beautiful.carousel_center_mode` | string | `"on-overflow"` | Centring mode |
| `beautiful.carousel_dynamic_peek_width` | number | `-1` | Edge-column margin |
| `beautiful.layout_carousel` | surface | nil | Layoutbox icon for the carousel layout |

Theme values override the corresponding layout properties. A client’s `carousel_column_width` overrides the default width when that client creates a new column.

With `dynamic_peek_width >= 0`, the first and last columns use that margin when focused. This is useful with `"never"` and `"edge"` modes. The theme variable is `carousel_dynamic_peek_width`, including the `_width` suffix.

```lua
local beautiful = require("beautiful")
beautiful.carousel_default_column_width = 0.5
beautiful.carousel_peek_width = 40
```

## Column Width Functions

These functions act on the focused column of the selected carousel tag. In the vertical variant, width fractions control column height and clients stack horizontally. Fractions apply to the space inside the carousel viewport’s peek padding. The workarea has an outer gap, and a positive peek adds `peek_width + gap` on each side. Column padding and client borders further reduce the application’s content size.

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

- **One client in the column:** Move it into the adjacent column. With no neighbour in that direction, do nothing.
- **Several clients in the column:** Move the focused client into a new column in that direction, preserving the source column’s width.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dir` | number | Direction: `-1` for left/up, `1` for right/down |

```lua
awful.layout.suit.carousel.push_window(1)
awful.layout.suit.carousel.push_window(-1)
```

### `carousel.push_window_bydirection(direction)`

Accepts `"left"`, `"right"`, `"up"`, or `"down"`. Along the scrolling axis it merges or expels like `push_window()`. Across that axis it moves the focused client within its stack. At a stack boundary it does nothing.

```lua
awful.layout.suit.carousel.push_window_bydirection("down")
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
local carousel = awful.layout.suit.carousel
local t = awful.screen.focused().selected_tag
if t then carousel.scroll_by(t, 0.5) end
```

Scrolling uses the shared layout animation duration. Set `beautiful.animation_layout_duration` to animate, or `0` to snap. `carousel.scroll_duration` is removed in 2.1. See [Animation](../../guides/animation.md).

### `carousel.get()`

Return information for the focused screen’s selected tag, or nil if there is no selected tag. Inspect it after a carousel layout pass.

| Field | Value |
| --- | --- |
| `width` | Total strip extent in logical pixels |
| `viewport` | `{width, height, margin}` in logical pixels |
| `position` | Current scroll offset in logical pixels |
| `columns` | Live column records, each with `clients` and `width_fraction`. Treat as read-only |
| `focus` | `{column_index, row_index}`, with nil entries if no client is focused |

```lua
local info = awful.layout.suit.carousel.get()
if info then print(info.width, info.position) end
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
require("beautiful").carousel_center_mode = "always"
```

Or clear the theme override and switch at runtime:

```lua
require("beautiful").carousel_center_mode = nil
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

- **[Scrollable Tiling](/docs/concepts/scrollable-tiling)** - How the strip, viewport, and animation model works
- **[Carousel Tutorial](/docs/tutorials/carousel)** - Step-by-step first session with the carousel layout
- **[Column Widths Guide](/docs/guides/carousel-column-widths)** - Resize and customize column widths
- **[Stacking Guide](/docs/guides/carousel-stacking)** - Consume, expel, and push windows between columns
- **[Gesture Scrolling Guide](/docs/guides/carousel-gestures)** - Set up touchpad gesture panning
- **[Centering Modes Guide](/docs/guides/carousel-centering)** - Choose and configure viewport centering
- **[Layout Protocol Reference](/docs/reference/awful/layout)** - The `arrange(p)` contract and built-in layouts
