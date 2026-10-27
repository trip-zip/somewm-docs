---
sidebar_position: 2.9
title: "Carousel: stack windows in a column"
description: Stack, split, and rearrange windows across carousel columns
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Carousel: stack windows in a column <SomewmOnly />

Group windows into columns or move them between columns using the operations below. They act on the focused client and require carousel on the focused screen.

## Consume: Pull a Window In

`consume_window(dir)` takes the first window from a neighbouring column and appends it below the focused column's existing windows. It removes the neighbour if that column becomes empty.

Direction `-1` means left and `1` means right. For the vertical variant, they mean up and down, and windows within a row sit side by side.

## Push: Consume or Expel

`push_window(dir)` moves the focused window:

- If it is alone, it joins the neighbouring column in that direction. With no neighbour, nothing happens.
- If it shares a column, it moves into a new column in that direction. The new column inherits its width.

## Expel: Split into a New Column

`expel_window()` moves the focused window into a new column after the current one, retaining its width. A window already alone stays where it is.

## Reorder Columns

`move_column(dir)` swaps the focused column with its neighbour. Focus stays on the moved column, and the viewport follows it.

## Register Keybindings

This example uses arrow keys to avoid the default master-width bindings on `h` and `l`:

```lua
local carousel = awful.layout.suit.carousel
awful.keyboard.append_global_keybindings({
    awful.key({ modkey, "Control" }, "Right", function()
        carousel.consume_window(1)
    end, { description = "consume from right", group = "carousel" }),
    awful.key({ modkey, "Control" }, "Left", function()
        carousel.consume_window(-1)
    end, { description = "consume from left", group = "carousel" }),
    awful.key({ modkey, "Control", "Shift" }, "Right", function()
        carousel.push_window(1)
    end, { description = "push right", group = "carousel" }),
    awful.key({ modkey, "Control", "Shift" }, "Left", function()
        carousel.push_window(-1)
    end, { description = "push left", group = "carousel" }),
    awful.key({ modkey, "Shift" }, "e", carousel.expel_window,
        { description = "expel window", group = "carousel" }),
    awful.key({ modkey, "Mod1" }, "Right", function()
        carousel.move_column(1)
    end, { description = "move column right", group = "carousel" }),
    awful.key({ modkey, "Mod1" }, "Left", function()
        carousel.move_column(-1)
    end, { description = "move column left", group = "carousel" }),
})
```

## See Also

- [Carousel API](../reference/awful/carousel.md)
- [Column Widths](carousel-column-widths.md)
- [Scrollable Tiling](../concepts/scrollable-tiling.md)
