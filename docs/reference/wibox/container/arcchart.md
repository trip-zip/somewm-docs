---
title: wibox.container.arcchart
description: One or more values drawn as arcs around the child.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "../_lua/container-arcchart.mdx";

# wibox.container.arcchart

Draws `value`, or each entry of `values`, as an arc around the edge of its box, with the child in the middle. It needs a definite size: give it `forced_width` and `forced_height`, or put it in a container that sizes it, or it is left out with a warning.

![Eight arc charts around the number 42: default, thick, three values, rounded ends, starting at the right, with a background ring, with a border, and with padding](/img/reference/wibox/container-arcchart.png)

Each row sets one property. The outline is the box the container was given.

<WidgetSource>

Save this as `/tmp/container-arcchart.lua`, then run:

```sh
somewm-client eval 'dofile("/tmp/container-arcchart.lua")'
```

It opens the figure on your focused screen and closes after two minutes. Every row is a 56 by 56 arcchart around a textbox with one property set.

<FigureLua />

[Download the Lua file](/img/reference/wibox/container-arcchart.lua). To close it early:

```sh
somewm-client eval 'if somewm_reference_figure then somewm_reference_figure.stop() end'
```

</WidgetSource>

Constructor: `wibox.container.arcchart(widget)`. [Upstream page](https://awesomewm.org/apidoc/widget_containers/wibox.container.arcchart.html).

```lua
local battery = wibox.widget {
    {
        text   = "80",
        halign = "center",
        widget = wibox.widget.textbox,
    },
    value         = 80,
    max_value     = 100,
    colors        = { "#b8bb26" },
    thickness     = 4,
    forced_width  = 32,
    forced_height = 32,
    widget        = wibox.container.arcchart,
}
```

## Properties

| Property | Type | Default | What it does | In SomeWM |
| --- | --- | --- | --- | --- |
| `widget` | widget or nil | `nil` | The child, drawn in the middle. | |
| `value` | number | `0` | One value, drawn as one arc. | |
| `values` | table | `{}` | Several values, drawn one after another clockwise from `start_angle`. Overrides `value`. | |
| `min_value` | number | `0` | The value where an arc starts. | |
| `max_value` | number | `1` | The value that closes the circle. | |
| `colors` | table | `beautiful.arcchart_color` | One color per arc, reused in turn. | A color that is not solid or a gradient warns once and is transparent. A gradient is drawn in the box. |
| `thickness` | number or nil | `beautiful.arcchart_thickness`, else `5` | Arc width in pixels. | |
| `start_angle` | number | `beautiful.arcchart_start_angle`, else `math.pi` | Where the first arc starts, in radians clockwise from the right. `math.pi` is the left. | |
| `rounded_edge` | boolean | `false` | Round the ends of each arc. | |
| `bg` | color or nil | `beautiful.arcchart_bg` | A full ring drawn behind the arcs. | Same color rule. |
| `border_width` | number | `0` | Outline around the ring. | |
| `border_color` | color | `beautiful.arcchart_border_color` | Outline color. | Must be solid or it warns once and is transparent. |
| `paddings` | number or table | `beautiful.arcchart_paddings`, else `0` | Space between the box edge and the ring. | A negative value warns once and is 0. |

Setting a property emits `property::<name>`.

## Methods

| Method | What it does |
| --- | --- |
| `:reset()` | Removes the child. |

The [common properties, methods and signals](../common.md) apply.
