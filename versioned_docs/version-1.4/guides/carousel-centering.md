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

There is no `beautiful.carousel_center_mode` setting in 1.4.

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

A value of `40` reduces the effective viewport by 80 logical pixels. Gaps can occupy part of the exposed area, so it does not guarantee 40 visible pixels of neighbouring content.

## Programmatic Scrolling

`scroll_by(tag, n)` moves by a fraction of the effective viewport, without changing focus:

```lua
local t = awful.screen.focused().selected_tag
if t then
    awful.layout.suit.carousel.scroll_by(t, 0.5)
end
```

Positive values move right, or down for the vertical layout. Negative values move in the opposite direction. Movement is clamped to the column strip and animated when `scroll_duration` is greater than zero.

## See Also

- [Carousel API](../reference/awful/carousel.md)
- [Gesture Scrolling](carousel-gestures.md)
- [Scrollable Tiling](../concepts/scrollable-tiling.md)
