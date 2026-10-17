---
sidebar_position: 2.6
title: "Carousel: Column Widths"
description: "Each column's width is a fraction of the viewport. The default for new columns, a preset cycle, incremental adjustment, an exact width, and maximize."
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Carousel: Column Widths <SomewmOnly />

A column's width is a fraction of the viewport: 1.0 fills it, 0.5 is half, above 1.0 is wider than the screen and scrolls within itself. All functions act on the focused column.

| Call | Does |
| --- | --- |
| `default_column_width = 0.5`, or `theme.carousel_default_column_width` (wins) | the width of new columns; 1.0 by default |
| `width_presets = { 0.5, 0.75, 1.0 }` | the cycle list; `{ 1/3, 1/2, 2/3, 1.0 }` by default |
| `cycle_column_width()` | the next preset, wrapping; a width not in the list starts from the first |
| `adjust_column_width(delta)` | adds `delta`, clamped to 0.1 to 2.0 |
| `set_column_width(fraction)` | an exact width |
| `maximize_column()` | `set_column_width(1.0)` |

```lua
local carousel = awful.layout.suit.carousel

awful.key({ modkey }, "bracketright", function() carousel.cycle_column_width() end,
    { description = "cycle column width", group = "carousel" })
awful.key({ modkey, "Control" }, "l", function() carousel.adjust_column_width(0.05) end,
    { description = "widen column", group = "carousel" })
awful.key({ modkey, "Control" }, "h", function() carousel.adjust_column_width(-0.05) end,
    { description = "narrow column", group = "carousel" })
awful.key({ modkey }, "m", function() carousel.maximize_column() end,
    { description = "maximize column", group = "carousel" })
```

[Carousel reference](../reference/awful/carousel.md), [Stacking](carousel-stacking.md), [Scrollable Tiling](../concepts/scrollable-tiling.md).
