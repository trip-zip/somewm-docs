---
title: wibox.container.margin
description: Space around the child, empty or colored.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "../_lua/container-margin.mdx";

# wibox.container.margin

Adds space on each side of its child. The space is transparent unless `color` is set, which makes the margin a solid frame.

![Five margins around a filled textbox: none, 10 on every side, 40 on the left, 20 left and 60 right, and an amber 8 pixel frame](/img/reference/wibox/container-margin.png)

Each row sets one property. The outline is the box the container was given.

<WidgetSource>

Save this as `/tmp/container-margin.lua`, then run:

```sh
somewm-client eval 'dofile("/tmp/container-margin.lua")'
```

It opens the figure on your focused screen and closes after two minutes. Every row is a background-filled textbox in a margin with one property set.

<FigureLua />

[Download the Lua file](/img/reference/wibox/container-margin.lua). To close it early:

```sh
somewm-client eval 'if somewm_reference_figure then somewm_reference_figure.stop() end'
```

</WidgetSource>

Constructor: `wibox.container.margin(widget, left, right, top, bottom, color, draw_empty)`. [Upstream page](https://awesomewm.org/apidoc/widget_containers/wibox.container.margin.html).

```lua
local padded = wibox.widget {
    clock,
    left   = 8,
    right  = 8,
    widget = wibox.container.margin,
}
```

## Properties

| Property | Type | Default | What it does | In SomeWM |
| --- | --- | --- | --- | --- |
| `widget` | widget or nil | `nil` | The child. | |
| `margins` | number or table | `0` | All four sides, or `{ left = , right = , top = , bottom = }`. | A negative value warns once and is 0. |
| `left`, `right`, `top`, `bottom` | number | `0` | One side. | |
| `color` | color or nil | `nil` | Fill of the margin area. | A value that is not solid or a gradient warns once and is transparent. |
| `draw_empty` | boolean | `true` | Draw the margins when the child has no size. | `false` warns once; the margins are drawn anyway. |

Setting a property emits `property::<name>`.

## Methods

| Method | What it does |
| --- | --- |
| `:reset()` | Removes the child, sets every margin to 0 and clears `color`. |

The [common properties, methods and signals](../common.md) apply.
