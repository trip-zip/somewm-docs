---
sidebar_position: 2.7
title: "Carousel: Centering"
description: "The four centering modes, set at startup or switched at runtime, peek width, and scrolling the viewport from code."
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Carousel: Centering <SomewmOnly />

The centering mode decides how the viewport follows the focused column.

| Mode | Scrolls | For |
| --- | --- | --- |
| `on-overflow` (default) | only when the focused column would be partly or fully off screen; then centres it | least motion with the column always fully visible |
| `always` | every focus change centres the column | focus always in the middle |
| `never` | only when the column is entirely off screen | the stillest viewport |
| `edge` | the least distance that brings the column fully into view | vim's `scrolloff=0` |

```lua
awful.layout.suit.carousel.center_mode = "always"      -- rc.lua, before tags exist
theme.carousel_center_mode = "always"                  -- theme.lua; wins over the property
awful.layout.suit.carousel.set_center_mode("edge")     -- at runtime; re-arranges at once
```

Bound to keys:

```lua
local carousel = awful.layout.suit.carousel
for i, mode in ipairs({ "on-overflow", "always", "never", "edge" }) do
    awful.key({ modkey, "Control" }, tostring(i), function() carousel.set_center_mode(mode) end,
        { description = "center mode: " .. mode, group = "carousel" })
end
```

## Peek width

`peek_width` reserves that many pixels on each side of the viewport for the edges of the neighbouring columns. `useless_gap` is added on top, so the value is visible content, not total inset. 0, the default, uses the whole viewport.

```lua
awful.layout.suit.carousel.peek_width = 40
theme.carousel_peek_width = 40        -- wins
```

## Scrolling from code

`scroll_by(tag, n)` moves the viewport by `n` viewport widths without changing focus, clamped to the strip, animated over `theme.animation_layout_duration`:

```lua
local t = awful.screen.focused().selected_tag
awful.layout.suit.carousel.scroll_by(t, 1)
awful.layout.suit.carousel.scroll_by(t, -0.5)
```

[Carousel reference](/docs/reference/awful/carousel), [Gestures](/docs/guides/carousel-gestures), [Scrollable Tiling](/docs/concepts/scrollable-tiling).
