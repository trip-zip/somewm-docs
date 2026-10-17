---
sidebar_position: 2.9
title: "Carousel: Stacking"
description: "consume_window pulls a neighbour's window into the focused column, expel_window splits one out, push_window does whichever fits, and move_column reorders the strip."
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Carousel: Stacking <SomewmOnly />

Each window starts in its own column. Four functions on `awful.layout.suit.carousel` group and reorder them. Direction `1` is right, `-1` left; in the vertical variant, down and up.

| Function | Does |
| --- | --- |
| `consume_window(dir)` | pulls the first client of the neighbouring column into the focused column, below its clients; an emptied column is removed |
| `expel_window()` | moves the focused client out of a stacked column into a new column after it, with the same width; a no-op when the client is alone |
| `push_window(dir)` | a client alone in its column merges into the neighbour in that direction (no neighbour, no-op); a stacked client is expelled into a new column on that side |
| `move_column(dir)` | swaps the focused column with its neighbour; focus and the viewport follow it |

```lua
local carousel = awful.layout.suit.carousel

awful.key({ modkey, "Shift" }, "l", function() carousel.consume_window(1) end,
    { description = "consume window from right", group = "carousel" })
awful.key({ modkey, "Shift" }, "h", function() carousel.consume_window(-1) end,
    { description = "consume window from left", group = "carousel" })
awful.key({ modkey, "Shift" }, "e", function() carousel.expel_window() end,
    { description = "expel window to new column", group = "carousel" })
awful.key({ modkey, "Control" }, "l", function() carousel.push_window(1) end,
    { description = "push window right", group = "carousel" })
awful.key({ modkey, "Control" }, "h", function() carousel.push_window(-1) end,
    { description = "push window left", group = "carousel" })
awful.key({ modkey, "Mod1" }, "l", function() carousel.move_column(1) end,
    { description = "move column right", group = "carousel" })
awful.key({ modkey, "Mod1" }, "h", function() carousel.move_column(-1) end,
    { description = "move column left", group = "carousel" })
```

[Carousel reference](../reference/awful/carousel.md), [Column widths](carousel-column-widths.md), [Scrollable Tiling](../concepts/scrollable-tiling.md).
