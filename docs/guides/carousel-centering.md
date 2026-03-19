---
sidebar_position: 2.7
title: "Carousel: Centering"
description: Choose and configure carousel viewport centering modes
---

import SomewmOnly from '@site/src/components/SomewmOnly';
import YouWillLearn from '@site/src/components/YouWillLearn';

# Carousel: Centering <SomewmOnly />

<YouWillLearn>

- The four centering modes and when to use each one
- How to set a mode at startup or switch at runtime
- How to configure peek width for visual context
- How to scroll the viewport programmatically

</YouWillLearn>

## The Four Modes

The centering mode controls how the viewport follows the focused column.

| Mode | Behavior | Best for |
|------|----------|----------|
| `"on-overflow"` | Center the focused column only when it would be partially or fully offscreen. | General use. Minimal scrolling, focused column always fully visible. |
| `"always"` | Always center the focused column, even if already visible. | Keeping your focus point in the middle of the screen at all times. |
| `"never"` | Only scroll when the focused column is completely offscreen. | Reducing viewport movement. The viewport stays still as long as any part of the column is showing. |
| `"edge"` | Scroll the minimum distance to bring the focused column fully into view, aligned to the nearest edge. | Vim-like `scrolloff=0` behavior. Minimal motion, no centering. |

## Set at Startup

Set `center_mode` directly in your `rc.lua`, before any tags are created:

```lua
awful.layout.suit.carousel.center_mode = "always"
```

Alternatively, set it via your theme. The theme value takes priority over the property set on the layout table:

```lua
-- In theme.lua
theme.carousel_center_mode = "always"
```

## Switch at Runtime

Use `set_center_mode()` to change modes on the fly. This immediately re-arranges the current screen:

```lua
awful.layout.suit.carousel.set_center_mode("edge")
```

You can bind all four modes to keys:

```lua
local carousel = awful.layout.suit.carousel

awful.key({ modkey, "Control" }, "1", function()
    carousel.set_center_mode("on-overflow")
end, { description = "center mode: on-overflow", group = "carousel" })

awful.key({ modkey, "Control" }, "2", function()
    carousel.set_center_mode("always")
end, { description = "center mode: always", group = "carousel" })

awful.key({ modkey, "Control" }, "3", function()
    carousel.set_center_mode("never")
end, { description = "center mode: never", group = "carousel" })

awful.key({ modkey, "Control" }, "4", function()
    carousel.set_center_mode("edge")
end, { description = "center mode: edge", group = "carousel" })
```

## Configure Peek Width

Peek width reserves pixels on each side of the viewport to show the edges of adjacent columns. This gives you visual context about what lies beyond the viewport.

```lua
-- In rc.lua
awful.layout.suit.carousel.peek_width = 40

-- Or in theme.lua (takes priority)
theme.carousel_peek_width = 40
```

With `peek_width = 40`, you see 40 pixels of content from adjacent columns on each side. When `useless_gap` is configured, the gap is automatically added to the peek inset, so the configured value always represents visible content pixels rather than total inset.

Set `peek_width` to 0 (the default) to use the full viewport.

## Programmatic Scrolling

`scroll_by(tag, n)` scrolls the viewport by `n` viewport-widths. This is useful for scripting or for scrolling without changing focus:

```lua
local t = awful.screen.focused().selected_tag

-- Scroll one full viewport to the right
awful.layout.suit.carousel.scroll_by(t, 1)

-- Scroll half a viewport to the left
awful.layout.suit.carousel.scroll_by(t, -0.5)
```

The offset is clamped to strip boundaries. The scroll animates if `scroll_duration` is greater than 0.

## See Also

- **[Carousel API Reference](/reference/awful/carousel)** - Full property and function documentation
- **[Gesture Scrolling Guide](/guides/carousel-gestures)** - Touchpad gesture panning
- **[Scrollable Tiling](/concepts/scrollable-tiling)** - How the viewport and animation model works
