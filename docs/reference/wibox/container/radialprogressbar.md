---
title: wibox.container.radialprogressbar
description: A ring filled to a value, around the child.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "../_lua/container-radialprogressbar.mdx";

# wibox.container.radialprogressbar

Draws a ring around its box and fills it clockwise from the top in proportion to `value`, with the child in the middle. Give it `forced_width` and `forced_height`.

![Five rings around the number 42: default, 80 of 100, amber, thick, and with a light track](/img/reference/wibox/container-radialprogressbar.png)

Each row sets one property. The outline is the box the container was given.

<WidgetSource>

Save this as `/tmp/container-radialprogressbar.lua`, then run:

```sh
somewm-client eval 'dofile("/tmp/container-radialprogressbar.lua")'
```

It opens the figure on your focused screen and closes after two minutes. Every row is a 56 by 56 radial progress bar around a textbox with one property set.

<FigureLua />

[Download the Lua file](/img/reference/wibox/container-radialprogressbar.lua). To close it early:

```sh
somewm-client eval 'if somewm_reference_figure then somewm_reference_figure.stop() end'
```

</WidgetSource>

Constructor: `wibox.container.radialprogressbar(widget)`. [Upstream page](https://awesomewm.org/apidoc/widget_containers/wibox.container.radialprogressbar.html).

```lua
local ring = wibox.widget {
    percent_label,
    value         = 0.42,
    color         = "#83a598",
    border_color  = "#504945",
    forced_width  = 40,
    forced_height = 40,
    widget        = wibox.container.radialprogressbar,
}
```

## Properties

| Property | Type | Default | What it does | In SomeWM |
| --- | --- | --- | --- | --- |
| `widget` | widget or nil | `nil` | The child, drawn in the middle. | |
| `value` | number | `0` | The filled amount between `min_value` and `max_value`. | |
| `min_value` | number | `0` | The empty value. | |
| `max_value` | number | `1` | The full value. | |
| `color` | color | `beautiful.radialprogressbar_color` | Fill of the filled part. | Must be solid or it warns once and is transparent. |
| `border_color` | color | `beautiful.radialprogressbar_border_color` | The unfilled track. | Same rule. |
| `border_width` | number | `beautiful.radialprogressbar_border_width`, else `2` | Ring thickness. | |

Setting a property emits `property::<name>`.

Gone in SomeWM 2.1: `paddings` and `beautiful.radialprogressbar_paddings`.

## Methods

| Method | What it does |
| --- | --- |
| `:reset()` | Removes the child. |

The [common properties, methods and signals](../common.md) apply.
