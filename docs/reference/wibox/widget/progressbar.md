---
title: wibox.widget.progressbar
description: A horizontal bar filled to a value.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "../_lua/widget-progressbar.mdx";

# wibox.widget.progressbar

Fills a bar from the left in proportion to `value` over `max_value`. Rotate it with `wibox.container.rotate` for a vertical bar. It has no height of its own: give it `forced_height` or let the bar fill it.

![Eight progress bars: default, a max value of 10, recolored, rounded, with a rounded inner bar, with a border, with margins and paddings, and with ticks](/img/reference/wibox/widget-progressbar.png)

Each row sets one property. The outline is the box the widget was given.

<WidgetSource>

Save this as `/tmp/widget-progressbar.lua`, then run:

```sh
somewm-client eval 'dofile("/tmp/widget-progressbar.lua")'
```

It opens the figure on your focused screen and closes after two minutes. Every row is a 300 by 16 progressbar at 60 percent with one property set.

<FigureLua />

[Download the Lua file](/img/reference/wibox/widget-progressbar.lua). To close it early:

```sh
somewm-client eval 'if somewm_reference_figure then somewm_reference_figure.stop() end'
```

</WidgetSource>

Constructor: `wibox.widget.progressbar(args)`. [Upstream page](https://awesomewm.org/apidoc/widgets/wibox.widget.progressbar.html).

```lua
local volume = wibox.widget {
    max_value        = 100,
    value            = 60,
    forced_width     = 100,
    forced_height    = 8,
    shape            = gears.shape.rounded_bar,
    color            = "#83a598",
    background_color = "#32302f",
    widget           = wibox.widget.progressbar,
}
```

## Properties

| Property | Type | Default | What it does | In SomeWM |
| --- | --- | --- | --- | --- |
| `value` | number | `0` | The filled amount, 0 to `max_value`. | |
| `max_value` | number | `1` | The value that fills the bar. | |
| `color` | color | `beautiful.progressbar_fg` | Fill of the bar. | A value that is not solid or a gradient warns once and is transparent. |
| `background_color` | color | `beautiful.progressbar_bg` | Fill behind the bar. | Same rule. |
| `shape` | function | `beautiful.progressbar_shape`, else rectangle | Shape of the whole widget. | |
| `bar_shape` | function | `beautiful.progressbar_bar_shape`, else rectangle | Shape of the filled part. | |
| `clip` | boolean | `true` | Keep the bar inside `shape`. | |
| `border_width` | number | `beautiful.progressbar_border_width`, else `0` | Outline of the whole widget. | |
| `border_color` | color | `beautiful.progressbar_border_color` | Outline color. | Must be solid or it warns once and is transparent. |
| `bar_border_width` | number | `beautiful.progressbar_bar_border_width`, else `0` | Outline of the filled part. | |
| `bar_border_color` | color | `beautiful.progressbar_bar_border_color` | Its color. | Must be solid or it warns once and is transparent. |
| `margins` | number or table | `beautiful.progressbar_margins`, else `0` | Space outside the outline. | |
| `paddings` | number or table | `beautiful.progressbar_paddings`, else `0` | Space between the outline and the bar. | |
| `ticks` | boolean | `false` | Draw tick marks across the bar. | Not drawn. Warns once. |
| `ticks_size` | number | `4` | Tick spacing. | Not applied. |

Setting a property emits `property::<name>`.

Gone in SomeWM 2.1: `ticks_gap`.

The [common properties, methods and signals](../common.md) apply.
