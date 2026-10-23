---
sidebar_position: 2.6
title: "Carousel: Column Widths"
description: Resize, cycle, and customize carousel column widths
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Carousel: Column Widths <SomewmOnly />

Set column sizes as fractions of the effective viewport, after peek space is removed. For the vertical carousel, the same settings control row height.

## Change the Default Width

New columns default to `1.0`. Set a different fraction before creating tags:

```lua
awful.layout.suit.carousel.default_column_width = 0.5
```

Alternatively, set `theme.carousel_default_column_width = 0.5` in your theme. The theme value takes priority. Changing the default does not resize existing columns.

## Cycle Through Presets

Add this binding to `rc.lua`:

```lua
awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, "bracketright", function()
        awful.layout.suit.carousel.cycle_column_width()
    end, { description = "cycle column width", group = "carousel" }),
})
```

The default presets are `{ 1/3, 1/2, 2/3, 1.0 }`. Each press advances the focused column to the next value, wrapping at the end. A width outside the list cycles to the first preset.

## Customize the Preset List

```lua
awful.layout.suit.carousel.width_presets = { 0.5, 0.75, 1.0 }
```

Use positive fractions. Values above `1.0` create columns wider than the viewport.

## Adjust Width Incrementally

Call these from your own callbacks:

```lua
local carousel = awful.layout.suit.carousel
carousel.adjust_column_width(0.05)
carousel.adjust_column_width(-0.05)
```

Each call adds to the focused column's fraction and clamps the result to `0.1`–`2.0`.

## Set an Exact Width

```lua
awful.layout.suit.carousel.set_column_width(1/3)
```

This also clamps to `0.1`–`2.0`.

## Maximize a Column

```lua
awful.layout.suit.carousel.maximize_column()
```

This sets the fraction to `1.0`. These operations require a focused client on the focused screen's carousel layout.

## See Also

- [Carousel API](../reference/awful/carousel.md)
- [Stacking](carousel-stacking.md)
- [Centering and Peek Width](carousel-centering.md)
