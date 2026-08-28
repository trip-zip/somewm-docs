---
sidebar_position: 5.5
title: Carousel Layout
description: Your first session with the scrollable tiling carousel
---

import SomewmOnly from '@site/src/components/SomewmOnly';
import YouWillLearn from '@site/src/components/YouWillLearn';

# Carousel Layout <SomewmOnly />

<YouWillLearn>

- How to enable the carousel layout
- How columns work instead of master/stack splitting
- How to navigate between columns with auto-scrolling
- How to resize columns
- How to stack windows vertically
- How to set up gesture scrolling
- How to choose a centering mode

</YouWillLearn>

The carousel is a scrollable tiling layout. Instead of dividing your screen into fixed regions, it places each window in its own column on an infinite horizontal strip. You see one or two columns at a time, and the viewport scrolls to follow your focus.

## 1. Enable the Carousel Layout

Add the carousel to your layout list in `rc.lua`:

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

The carousel is now the first layout in the cycle. Switch to it on any tag with your layout-cycle keybinding (default: **Mod4+Space**).

## 2. Open Windows

Open a terminal. It fills the entire screen, just like any layout with one window.

Open a second terminal. Instead of splitting the screen into master and stack, the carousel creates a second column. The new column appears after the focused column, and the viewport scrolls to show it.

Open a third terminal. A third column appears. Now the first terminal is offscreen to the left. You can't see it, but it's still there on the strip.

## 3. Navigate Between Columns

Use your standard focus keys (**Mod4+j** / **Mod4+k** in the default `rc.lua`) to move focus between clients. When focus lands on a client in a column that's offscreen, the viewport scrolls to bring it into view.

Try jumping to the edges:

```lua
-- Add to rc.lua
awful.key({ modkey }, "Home", function()
    awful.layout.suit.carousel.focus_first_column()
end, { description = "focus first column", group = "carousel" })

awful.key({ modkey }, "End", function()
    awful.layout.suit.carousel.focus_last_column()
end, { description = "focus last column", group = "carousel" })
```

## 4. Resize Columns

Each column has its own width. The default is 1.0 (full viewport width). Add a keybinding to cycle through presets:

```lua
awful.key({ modkey }, "bracketright", function()
    awful.layout.suit.carousel.cycle_column_width()
end, { description = "cycle column width", group = "carousel" })
```

Press it a few times. The focused column cycles through 1/3, 1/2, 2/3, and full width. When a column is narrower than the viewport, you can see parts of adjacent columns.

For finer control, add incremental resize keys:

```lua
awful.key({ modkey, "Control" }, "l", function()
    awful.layout.suit.carousel.adjust_column_width(0.05)
end, { description = "widen column", group = "carousel" })

awful.key({ modkey, "Control" }, "h", function()
    awful.layout.suit.carousel.adjust_column_width(-0.05)
end, { description = "narrow column", group = "carousel" })
```

## 5. Stack Windows Vertically

Sometimes you want two windows side by side in the same column. Use consume to pull a window from an adjacent column:

```lua
awful.key({ modkey, "Shift" }, "l", function()
    awful.layout.suit.carousel.consume_window(1)
end, { description = "consume window from right", group = "carousel" })

awful.key({ modkey, "Shift" }, "h", function()
    awful.layout.suit.carousel.consume_window(-1)
end, { description = "consume window from left", group = "carousel" })
```

Open three terminals, then press **Mod4+Shift+l** on the first one. The second terminal is pulled into the first column, and they stack vertically. The third terminal is still in its own column.

To split them back apart, use expel:

```lua
awful.key({ modkey, "Shift" }, "e", function()
    awful.layout.suit.carousel.expel_window()
end, { description = "expel window to new column", group = "carousel" })
```

Focus the stacked window you want to separate and press the expel key. It gets its own column again.

## 6. Set Up Gesture Scrolling

If you have a touchpad, one line enables 3-finger swipe to pan the viewport:

```lua
awful.layout.suit.carousel.make_gesture_binding()
```

Swipe three fingers left or right to scroll through your columns. When you lift your fingers, the viewport snaps to the nearest column.

## 7. Choose a Centering Mode

The default mode (`"on-overflow"`) only scrolls when the focused column would be offscreen. Try `"always"` to keep your focused column centered at all times:

```lua
awful.layout.suit.carousel.center_mode = "always"
```

Or switch modes at runtime:

```lua
awful.layout.suit.carousel.set_center_mode("edge")
```

See the [centering modes guide](/docs/guides/carousel-centering) for a full comparison.

## What's Next?

- **[Column Widths Guide](/docs/guides/carousel-column-widths)** - Customize presets, set exact widths, maximize
- **[Stacking Guide](/docs/guides/carousel-stacking)** - Consume, push, expel, and reorder columns
- **[Gesture Scrolling Guide](/docs/guides/carousel-gestures)** - Gesture details and vertical variant setup
- **[Centering Modes Guide](/docs/guides/carousel-centering)** - All four modes, peek width, programmatic scrolling
- **[Scrollable Tiling](/docs/concepts/scrollable-tiling)** - The mental model behind the carousel
- **[Carousel API Reference](/docs/reference/awful/carousel)** - Complete function and property reference
