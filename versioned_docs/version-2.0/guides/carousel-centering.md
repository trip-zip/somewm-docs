---
sidebar_position: 2.7
title: "Carousel: Centering"
description: Choose and configure carousel viewport centering modes
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Carousel: Centering <SomewmOnly />

Set how the carousel viewport follows the focused column. These settings apply to both carousel orientations.

## The Four Modes

| Mode | Behaviour |
| --- | --- |
| `"on-overflow"` (default) | Centre the focused column when any part is offscreen. |
| `"always"` | Centre the focused column on every arrangement. |
| `"never"` | Scroll only when the focused column is entirely offscreen. |
| `"edge"` | Scroll enough to bring the column into view at the nearest edge. |

A column wider than the viewport cannot be fully visible in any mode.

## Set at Startup

Set the layout property before creating tags:

```lua
awful.layout.suit.carousel.center_mode = "always"
```

Alternatively, set `theme.carousel_center_mode = "always"` in your theme. The theme value takes priority over the layout property, including changes through `set_center_mode()`. Clear that theme value if you want the runtime setter to control centering.

## Switch at Runtime

`set_center_mode()` updates the shared setting and rearranges the focused screen if it uses carousel:

```lua
awful.layout.suit.carousel.set_center_mode("edge")
```

## Configure Peek Width

Reserve space at both ends of the viewport to expose neighbouring columns:

```lua
awful.layout.suit.carousel.peek_width = 40
```

Alternatively, set `theme.carousel_peek_width = 40` in your theme. The theme value takes priority. The default is `0`.

Positive peek values also include the layout gap on each side. With a gap of `8`, a peek width of `40` removes 96 logical pixels from the effective viewport. This reserves space, but does not guarantee that neighbouring content occupies all of it.

For different spacing at the strip's outer edges, use `carousel.dynamic_peek_width` or the overriding `beautiful.carousel_dynamic_peek_width` with `"edge"` or `"never"` centering. The default `-1` keeps ordinary peek spacing. See the [carousel reference](../reference/awful/carousel.md).

## Programmatic Scrolling

`scroll_by(tag, n)` moves by a fraction of the effective viewport, without changing focus:

```lua
local carousel = awful.layout.suit.carousel
local t = awful.screen.focused().selected_tag
if t and (t.layout == carousel or t.layout == carousel.vertical) then
    carousel.scroll_duration = 0.1
    carousel.scroll_by(t, 0.5)
end
```

Positive values move right, or down for the vertical layout. Negative values move in the opposite direction. Movement is clamped to the column strip. In 2.0.1, use a positive `scroll_duration` here. With the default `0`, `scroll_by` changes the stored offset without immediately moving the windows. A later arrangement may also recalculate the offset around the focused column.

## See Also

- [Carousel API](../reference/awful/carousel.md)
- [Gesture Scrolling](carousel-gestures.md)
- [Scrollable Tiling](../concepts/scrollable-tiling.md)
