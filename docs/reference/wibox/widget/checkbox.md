---
title: wibox.widget.checkbox
description: A box that is checked or not, at the size you give it.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "../_lua/widget-checkbox.mdx";

# wibox.widget.checkbox

A square that fills when `checked` is true. It has no size of its own: give it `forced_width` and `forced_height`, or put it in a container that sizes it, or it is left out with a warning.

![Checkbox unchecked, checked, in two colors, round, with a thick border, with padding and with a background](/img/reference/wibox/widget-checkbox.png)

Each row sets one property. The outline is the box the widget was given.

<WidgetSource>

Save this as `/tmp/widget-checkbox.lua`, then run:

```sh
somewm-client eval 'dofile("/tmp/widget-checkbox.lua")'
```

It opens the figure on your focused screen and closes after two minutes. Every row is a 28 by 28 checkbox with one property set.

<FigureLua />

[Download the Lua file](/img/reference/wibox/widget-checkbox.lua). To close it early:

```sh
somewm-client eval 'if somewm_reference_figure then somewm_reference_figure.stop() end'
```

</WidgetSource>

Constructor: `wibox.widget.checkbox(checked, args)`. [Upstream page](https://awesomewm.org/apidoc/widgets/wibox.widget.checkbox.html).

```lua
local box = wibox.widget {
    checked       = true,
    color         = beautiful.fg_normal,
    forced_width  = 20,
    forced_height = 20,
    widget        = wibox.widget.checkbox,
}
box:connect_signal("button::press", function(self) self.checked = not self.checked end)
```

## Properties

| Property | Type | Default | What it does | In SomeWM |
| --- | --- | --- | --- | --- |
| `checked` | boolean | `false` | Whether the inner mark is drawn. | |
| `color` | color | `beautiful.checkbox_color`, else `beautiful.fg_normal` | The outline, and the mark unless `check_color` is set. | A value that is not solid warns once; the outline is black and the mark transparent. |
| `check_color` | color | `color` | The mark. | |
| `bg` | color | none | Fill of the outer box. | A non-solid, non-gradient value warns once and is transparent. |
| `shape` | function | `gears.shape.rectangle` | Shape of the outer box and of the mark. | |
| `border_width` | number | `beautiful.checkbox_border_width`, else `1` | Outline thickness. | |
| `border_color` | color | `color` | Outline color. | Must be solid or the outline warns once and is transparent. |
| `paddings` | number or table | `0` | Space between the outline and the mark. | A negative value warns once and is 0. |

Setting a property emits `property::<name>`.

Gone in SomeWM 2.1: `check_border_color`, `check_border_width` and `check_shape`, with their `checkbox_*` theme variables. `shape` draws the mark.

The [common properties, methods and signals](../common.md) apply.
