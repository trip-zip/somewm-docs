---
title: wibox.widget.slider
description: A draggable handle on a bar, 0 to 100 by default.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "../_lua/widget-slider.mdx";

# wibox.widget.slider

A bar with a handle the pointer can drag. `value` moves between `minimum` and `maximum` and emits `property::value` as it goes. Give it a size with `forced_width` and `forced_height`.

![Eight sliders: default, 0 to 10, a thin bar, an active color, a rounded bar, a round amber handle, a wide bordered handle, and a bar with margins](/img/reference/wibox/widget-slider.png)

Each row sets one property. The outline is the box the widget was given.

<WidgetSource>

Save this as `/tmp/widget-slider.lua`, then run:

```sh
somewm-client eval 'dofile("/tmp/widget-slider.lua")'
```

It opens the figure on your focused screen and closes after two minutes. Every row is a 300 by 24 slider at 40 with one property set.

<FigureLua />

[Download the Lua file](/img/reference/wibox/widget-slider.lua). To close it early:

```sh
somewm-client eval 'if somewm_reference_figure then somewm_reference_figure.stop() end'
```

</WidgetSource>

Constructor: `wibox.widget.slider(args)`. [Upstream page](https://awesomewm.org/apidoc/widgets/wibox.widget.slider.html).

```lua
local brightness = wibox.widget {
    minimum          = 0,
    maximum          = 100,
    value            = 70,
    forced_width     = 120,
    forced_height    = 20,
    bar_shape        = gears.shape.rounded_bar,
    bar_height       = 4,
    bar_color        = "#504945",
    bar_active_color = "#83a598",
    handle_shape     = gears.shape.circle,
    handle_color     = "#ebdbb2",
    widget           = wibox.widget.slider,
}
brightness:connect_signal("property::value", function(_, v) set_brightness(v) end)
```

## Properties

| Property | Type | Default | What it does | In SomeWM |
| --- | --- | --- | --- | --- |
| `value` | number | `0` | The handle position between `minimum` and `maximum`. | |
| `minimum` | number | `0` | The value at the left. | |
| `maximum` | number | `100` | The value at the right. | |
| `bar_shape` | function | `beautiful.slider_bar_shape`, else rectangle | Shape of the bar. | |
| `bar_height` | number | `beautiful.slider_bar_height`, else the widget height | Bar thickness. | |
| `bar_color` | color | `beautiful.slider_bar_color` | Bar fill. A gradient is drawn in the bar's box. | A value that is not solid or a gradient warns once and is transparent. |
| `bar_active_color` | color | `beautiful.slider_bar_active_color` | Fill of the bar left of the handle. | Same rule. |
| `bar_margins` | number or table | `beautiful.slider_bar_margins`, else `{}` | Space between the widget edge and the bar. | |
| `handle_shape` | function | `beautiful.slider_handle_shape`, else rectangle | Shape of the handle. | |
| `handle_color` | color | `beautiful.slider_handle_color` | Handle fill. | Unset, the handle takes the bar color and warns once. |
| `handle_width` | number | `beautiful.slider_handle_width`, else the widget height | Handle width. | Unset with a `bar_height`, it is half the bar height and warns once. |
| `handle_border_width` | number | `beautiful.slider_handle_border_width`, else `0` | Handle outline. | |
| `handle_border_color` | color | `beautiful.slider_handle_border_color` | Outline color. | Must be solid or it warns once and is transparent. |
| `handle_cursor` | string | `"fleur"` | Pointer cursor while dragging. | |

Setting a property emits `property::<name>`. Dragging emits `property::value` for every change.

Gone in SomeWM 2.1: `bar_border_color`, `bar_border_width` and `handle_margins`, with their `slider_*` theme variables.

The [common properties, methods and signals](../common.md) apply.
