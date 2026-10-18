---
sidebar_position: 5.5
title: Carousel Layout
description: Enable the scrollable carousel layout, open windows into columns, navigate, resize, stack, add gesture scrolling and pick a centering mode.
---

import SomewmOnly from '@site/src/components/SomewmOnly';
import YouWillLearn from '@site/src/components/YouWillLearn';

# Carousel Layout <SomewmOnly />

<YouWillLearn>

- Enabling the carousel and opening windows into columns
- Navigating, resizing and stacking columns
- Gesture scrolling and centering modes

</YouWillLearn>

The carousel puts each window in its own column on a strip wider than the screen, and the viewport scrolls to follow focus ([Scrollable Tiling](../concepts/scrollable-tiling.md)).

## 1. Enable it

```lua
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        awful.layout.suit.carousel,
        awful.layout.suit.tile,
        awful.layout.suit.floating,
        awful.layout.suit.max,
    })
end)
```

It is now first in the cycle; Mod4 + Space switches a tag to it.

## 2. Open windows

One terminal fills the screen. A second makes a second column after the focused one, and the viewport scrolls to it. A third pushes the first off screen to the left; it is still on the strip.

## 3. Navigate

Mod4 + j and Mod4 + k move focus; when it lands in an off-screen column the viewport scrolls there. To jump to the ends:

```lua
awful.key({ modkey }, "Home", function()
    awful.layout.suit.carousel.focus_first_column()
end, { description = "focus first column", group = "carousel" })
awful.key({ modkey }, "End", function()
    awful.layout.suit.carousel.focus_last_column()
end, { description = "focus last column", group = "carousel" })
```

## 4. Resize columns

Each column has its own width, 1.0 of the viewport by default.

```lua
awful.key({ modkey }, "bracketright", function()
    awful.layout.suit.carousel.cycle_column_width()      -- 1/3, 1/2, 2/3, 1
end, { description = "cycle column width", group = "carousel" })
awful.key({ modkey, "Control" }, "l", function()
    awful.layout.suit.carousel.adjust_column_width(0.05)
end, { description = "widen column", group = "carousel" })
awful.key({ modkey, "Control" }, "h", function()
    awful.layout.suit.carousel.adjust_column_width(-0.05)
end, { description = "narrow column", group = "carousel" })
```

A column narrower than the viewport shows its neighbours' edges.

## 5. Stack windows in a column

```lua
awful.key({ modkey, "Shift" }, "l", function()
    awful.layout.suit.carousel.consume_window(1)
end, { description = "consume window from right", group = "carousel" })
awful.key({ modkey, "Shift" }, "h", function()
    awful.layout.suit.carousel.consume_window(-1)
end, { description = "consume window from left", group = "carousel" })
awful.key({ modkey, "Shift" }, "e", function()
    awful.layout.suit.carousel.expel_window()
end, { description = "expel window to new column", group = "carousel" })
```

With three terminals, Mod4 + Shift + l on the first pulls the second into its column, stacked vertically; the third keeps its own. Expel on the stacked one gives it a column again.

## 6. Gesture scrolling

```lua
awful.layout.suit.carousel.make_gesture_binding()
```

A three-finger swipe pans the viewport; lifting snaps to the nearest column.

## 7. Centering mode

`on-overflow`, the default, scrolls only when the focused column would be off screen. `always` keeps it centred:

```lua
awful.layout.suit.carousel.center_mode = "always"
awful.layout.suit.carousel.set_center_mode("edge")   -- at runtime
```

## Next

- [Column widths](../guides/carousel-column-widths.md): presets, exact widths, maximize
- [Stacking](../guides/carousel-stacking.md): consume, push, expel, reorder
- [Gestures](../guides/carousel-gestures.md) and the vertical variant
- [Centering modes](../guides/carousel-centering.md): all four, peek width, scrolling from code
- [Carousel reference](../reference/awful/carousel.md)
