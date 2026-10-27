---
title: wibox.widget.graph
description: Values added over time, drawn as bars from the right.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "../_lua/widget-graph.mdx";

# wibox.widget.graph

Keeps a list of values and draws one bar per value, newest at the right edge. Values come in through `add_value`; the graph scrolls as they arrive. Several data groups can be stacked.

![Seven graphs of the same values: default, recolored, wider steps, rounded steps, a larger max value, two stacked groups, and with a border](/img/reference/wibox/widget-graph.png)

Each row sets one property. The outline is the box the widget was given.

<WidgetSource>

Save this as `/tmp/widget-graph.lua`, then run:

```sh
somewm-client eval 'dofile("/tmp/widget-graph.lua")'
```

It opens the figure on your focused screen and closes after two minutes. Every row is a graph of the same 60 values with one property set.

<FigureLua />

[Download the Lua file](/img/reference/wibox/widget-graph.lua). To close it early:

```sh
somewm-client eval 'if somewm_reference_figure then somewm_reference_figure.stop() end'
```

</WidgetSource>

Constructor: `wibox.widget.graph(args)`. [Upstream page](https://awesomewm.org/apidoc/widgets/wibox.widget.graph.html).

```lua
local cpu = wibox.widget {
    forced_width     = 100,
    color            = "#83a598",
    background_color = "#32302f",
    widget           = wibox.widget.graph,
}
cpu:add_value(0.42)
```

## Properties

| Property | Type | Default | What it does | In SomeWM |
| --- | --- | --- | --- | --- |
| `color` | color | `beautiful.graph_fg` | Bar color. A gradient is drawn in the widget box. | A non-solid, non-gradient value warns once and is transparent. |
| `background_color` | color | `beautiful.graph_bg` | Fill behind the bars. | Same rule. |
| `group_colors` | table | `{ color }` | One color per data group. | |
| `border_width` | number | `0` | Outline thickness. | |
| `border_color` | color | `beautiful.graph_border_color` | Outline color. | Must be solid or it warns once and is transparent. |
| `max_value` | number | `1` | The value that reaches the top. | |
| `min_value` | number | `0` | The value at the bottom. | |
| `scale` | boolean | `false` | Grow `max_value` to the largest value seen. | |
| `clamp_bars` | boolean | `false` | Keep bars for out-of-range values inside the box. | |
| `baseline_value` | number | `0` | The value bars start from. | |
| `step_width` | number | `1` | Width of one bar in pixels. | |
| `step_spacing` | number | `0` | Gap between bars. | A negative value warns once and is 0. |
| `step_shape` | function | `gears.shape.rectangle` | Shape of one bar. | |
| `stack` | boolean | `false` | Draw the data groups on top of one another. | |
| `nan_indication` | boolean | `true` | Mark NaN values. | |
| `nan_color` | color | `"#ffff00"` | Color of the NaN mark. | Same rule as `color`. |
| `capacity` | integer or nil | `nil` | How many values to keep. `nil` keeps as many as fit the width. | |

Setting a property emits `property::<name>`.

## Methods

| Method | What it does |
| --- | --- |
| `:add_value(value, group)` | Appends a value to a data group (default 1). NaN is allowed. |
| `:clear()` | Drops every value. |
| `:pick_data_group_color(index)` | Returns the color used for a group. Override it to color groups by rule. |
| `:should_draw_data_group(index)` | Returns whether a group is drawn. Override it to hide groups. |
| `:compute_drawn_values_num(width)` | Returns how many values fit in `width` pixels. |

The [common properties, methods and signals](../common.md) apply.
