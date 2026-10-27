---
title: wibox.widget.separator
description: A line, or any shape, between other widgets.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "../_lua/widget-separator.mdx";

# wibox.widget.separator

Draws a thin line across its box, horizontal when the box is wider than tall and vertical otherwise. With a `shape` it draws that shape filling the box instead. Give it a size with `forced_width` or `forced_height`, or let a layout size it.

![Seven separators: a line in a wide box, a vertical line, a thick line, a half-length line, an amber line, a circle, and a thick line whose border is not drawn](/img/reference/wibox/widget-separator.png)

Each row sets one property. The outline is the box the widget was given.

<WidgetSource>

Save this as `/tmp/widget-separator.lua`, then run:

```sh
somewm-client eval 'dofile("/tmp/widget-separator.lua")'
```

It opens the figure on your focused screen and closes after two minutes. Every row is a separator with one property set.

<FigureLua />

[Download the Lua file](/img/reference/wibox/widget-separator.lua). To close it early:

```sh
somewm-client eval 'if somewm_reference_figure then somewm_reference_figure.stop() end'
```

</WidgetSource>

Constructor: `wibox.widget.separator(args)`. [Upstream page](https://awesomewm.org/apidoc/widgets/wibox.widget.separator.html).

```lua
local sep = wibox.widget {
    orientation  = "vertical",
    forced_width = 1,
    color        = "#504945",
    widget       = wibox.widget.separator,
}
```

## Properties

| Property | Type | Default | What it does | In SomeWM |
| --- | --- | --- | --- | --- |
| `orientation` | `"auto"`, `"horizontal"`, `"vertical"` | `"auto"` | Which way the line runs. `"auto"` follows the box. | |
| `thickness` | number | `beautiful.separator_thickness`, else `1` | Line width in pixels. | |
| `span_ratio` | number | `1` | How much of the box length the line covers, 0 to 1, centered. | Values above 1 are 1. |
| `color` | color | `beautiful.separator_color`, else `beautiful.fg_normal` | Line or shape color. | A value that is not solid or a gradient warns once and is transparent. |
| `shape` | function | `beautiful.separator_shape` | A `gears.shape` drawn across the box instead of a line. | |
| `border_width` | number | `beautiful.separator_border_width`, else `0` | Outline of the shape. | Only with a `shape`. A plain line has no border. |
| `border_color` | color | `beautiful.separator_border_color` | Outline color. | Must be solid or it warns once and is transparent. |

Setting a property emits `property::<name>`.

The [common properties, methods and signals](../common.md) apply.
