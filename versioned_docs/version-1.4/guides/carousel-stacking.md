---
sidebar_position: 2.9
title: "Carousel: Stacking"
description: Stack, split, and rearrange windows across carousel columns
---

import SomewmOnly from '@site/src/components/SomewmOnly';
import YouWillLearn from '@site/src/components/YouWillLearn';

# Carousel: Stacking <SomewmOnly />

<YouWillLearn>

- How to pull a window from an adjacent column (consume)
- How to push the focused window into an adjacent column
- How to split a stacked window into its own column (expel)
- How to reorder columns on the strip

</YouWillLearn>

By default, each window gets its own column. You can group windows vertically within a single column using consume, push, and expel operations.

## Consume: Pull a Window In

`consume_window(dir)` pulls the first client from an adjacent column into the focused column. The consumed window stacks below existing windows in the column. If the source column becomes empty, it is removed.

```lua
-- Consume from the right
awful.key({ modkey, "Shift" }, "l", function()
    awful.layout.suit.carousel.consume_window(1)
end, { description = "consume window from right", group = "carousel" })

-- Consume from the left
awful.key({ modkey, "Shift" }, "h", function()
    awful.layout.suit.carousel.consume_window(-1)
end, { description = "consume window from left", group = "carousel" })
```

Direction `-1` means left (or up in the vertical variant), `1` means right (or down).

## Push: Consume or Expel

`push_window(dir)` is a context-sensitive operation. Its behavior depends on whether the focused client is alone in its column:

- **Solo window** (only client in the column): The focused client merges into the adjacent column's stack in the given direction. This is equivalent to being consumed by the neighbor. If there is no neighbor in that direction, the push is a no-op.
- **Stacked window** (multiple clients in the column): The focused client is expelled into a new column inserted in the given direction. The new column inherits the source column's width.

```lua
-- Push right: merge into right neighbor (solo) or expel rightward (stacked)
awful.key({ modkey, "Control" }, "l", function()
    awful.layout.suit.carousel.push_window(1)
end, { description = "push window right", group = "carousel" })

-- Push left: merge into left neighbor (solo) or expel leftward (stacked)
awful.key({ modkey, "Control" }, "h", function()
    awful.layout.suit.carousel.push_window(-1)
end, { description = "push window left", group = "carousel" })
```

## Expel: Split into a New Column

`expel_window()` moves the focused client out of a stacked column into a new column inserted after the current one. The new column inherits the source column's width. This is a no-op if the column contains only one client.

```lua
awful.key({ modkey, "Shift" }, "e", function()
    awful.layout.suit.carousel.expel_window()
end, { description = "expel window to new column", group = "carousel" })
```

## Reorder Columns

`move_column(dir)` swaps the focused column with its neighbor:

```lua
awful.key({ modkey, "Mod1" }, "l", function()
    awful.layout.suit.carousel.move_column(1)
end, { description = "move column right", group = "carousel" })

awful.key({ modkey, "Mod1" }, "h", function()
    awful.layout.suit.carousel.move_column(-1)
end, { description = "move column left", group = "carousel" })
```

This changes the column's position on the strip. Focus stays on the moved column, and the viewport follows it.

## See Also

- **[Carousel API Reference](/docs/reference/awful/carousel)** - Full property and function documentation
- **[Column Widths Guide](/docs/guides/carousel-column-widths)** - Resize columns
- **[Scrollable Tiling](/docs/concepts/scrollable-tiling)** - How the column data model works
