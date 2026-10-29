---
title: wibox.widget.piechart
description: Named values as slices of a circle, with optional labels.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "../_lua/widget-piechart.mdx";

# wibox.widget.piechart

Draws a circle split in proportion to a list of values, one color per slice, with a label on a leader line for each.

![Four pie charts: labeled, without labels, with a border, and with one color](/img/reference/wibox/widget-piechart.png)

Each row sets one property. The outline is the box the widget was given.

<WidgetSource>

Save this as `/tmp/widget-piechart.lua`, then run:

```sh
somewm-client eval 'dofile("/tmp/widget-piechart.lua")'
```

It opens the figure on your focused screen and closes after two minutes. Every row is the same three values with one property set.

<FigureLua />

[Download the Lua file](/img/reference/wibox/widget-piechart.lua). To close it early:

```sh
somewm-client eval 'if somewm_reference_figure then somewm_reference_figure.stop() end'
```

</WidgetSource>

Constructor: `wibox.widget.piechart(args)`. [Upstream page](https://awesomewm.org/apidoc/widgets/wibox.widget.piechart.html).

```lua
local disk = wibox.widget {
    data_list     = { { "used", 70 }, { "free", 30 } },
    colors        = { "#d79921", "#83a598" },
    forced_width  = 120,
    forced_height = 80,
    widget        = wibox.widget.piechart,
}
```

## Properties

| Property | Type | Default | What it does | In SomeWM |
| --- | --- | --- | --- | --- |
| `data_list` | table | `{}` | `{ { label, value }, ... }` in drawing order. | |
| `data` | table | `{}` | `{ label = value }`. The same as `data_list` without an order. | |
| `colors` | table or nil | `beautiful.piechart_color` | One color per slice, reused in turn when there are more slices. | A color that is not solid or a gradient warns once and is transparent. |
| `border_width` | number | `1` | Outline of every slice. | |
| `border_color` | color | `beautiful.piechart_border_color` | Outline color. | Must be solid or it warns once and is transparent. |
| `display_labels` | boolean | `true` | Draw a label with a leader line for each slice. | The leader lines draw as filled polygons, as the figure shows. Labels take the `fg` of the nearest background; a `fg` that is not solid warns once and the labels are not drawn. |

Setting a property emits `property::<name>`.

The [common properties, methods and signals](../common.md) apply.

*Friendly reminder.  Pie charts are the worst and you shouldn't use them.
