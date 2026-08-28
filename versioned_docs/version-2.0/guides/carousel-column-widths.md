---
sidebar_position: 2.6
title: "Carousel: Column Widths"
description: Resize, cycle, and customize carousel column widths
---

import SomewmOnly from '@site/src/components/SomewmOnly';
import YouWillLearn from '@site/src/components/YouWillLearn';

# Carousel: Column Widths <SomewmOnly />

<YouWillLearn>

- How to change the default width for new columns
- How to cycle through width presets with a keybinding
- How to customize the preset list
- How to adjust width incrementally
- How to set an exact width or maximize a column

</YouWillLearn>

## Change the Default Width

New columns use a width fraction of 1.0 (full viewport) by default. To change this, set the property directly or use a theme variable:

```lua
-- Option 1: Set on the layout table (rc.lua)
awful.layout.suit.carousel.default_column_width = 0.5

-- Option 2: Set in your theme (theme.lua)
theme.carousel_default_column_width = 0.5
```

The theme variable takes priority if both are set.

## Cycle Through Presets

`cycle_column_width()` cycles the focused column's width through the preset list. If the current width is not in the list, the cycle starts from the first preset.

```lua
awful.key({ modkey }, "bracketright", function()
    awful.layout.suit.carousel.cycle_column_width()
end, { description = "cycle column width", group = "carousel" })
```

The default presets are `{1/3, 1/2, 2/3, 1.0}`. Each press advances to the next value, wrapping around after the last.

## Customize the Preset List

Replace the `width_presets` table with your own values:

```lua
awful.layout.suit.carousel.width_presets = { 0.5, 0.75, 1.0 }
```

Values are fractions of the effective viewport width. Use values greater than 1.0 for columns wider than the viewport (you would scroll within a single column).

## Adjust Width Incrementally

`adjust_column_width(delta)` adds a delta to the focused column's width, clamped to [0.1, 2.0]:

```lua
awful.key({ modkey, "Control" }, "l", function()
    awful.layout.suit.carousel.adjust_column_width(0.05)
end, { description = "widen column", group = "carousel" })

awful.key({ modkey, "Control" }, "h", function()
    awful.layout.suit.carousel.adjust_column_width(-0.05)
end, { description = "narrow column", group = "carousel" })
```

## Set an Exact Width

`set_column_width(fraction)` sets the focused column to a specific fraction:

```lua
-- Set focused column to exactly one-third
awful.layout.suit.carousel.set_column_width(1/3)
```

## Maximize a Column

`maximize_column()` sets the focused column's width to 1.0:

```lua
awful.key({ modkey }, "m", function()
    awful.layout.suit.carousel.maximize_column()
end, { description = "maximize column", group = "carousel" })
```

This is equivalent to `set_column_width(1.0)`.

## See Also

- **[Carousel API Reference](/docs/reference/awful/carousel)** - Full property and function documentation
- **[Stacking Guide](/docs/guides/carousel-stacking)** - Combine windows vertically within a column
- **[Scrollable Tiling](/docs/concepts/scrollable-tiling)** - How the strip and viewport model works
