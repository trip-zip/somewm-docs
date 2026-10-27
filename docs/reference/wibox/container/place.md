---
title: wibox.container.place
description: The child aligned inside the space the container gets.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "../_lua/container-place.mdx";

# wibox.container.place

Puts a child that is smaller than the container at one of nine positions, or stretches it to fill one or both axes.

![A small block in a wide box five times: centered, top left, bottom right, stretched across, and stretched down](/img/reference/wibox/container-place.png)

Each row sets one property. The outline is the box the container was given.

<WidgetSource>

Save this as `/tmp/container-place.lua`, then run:

```sh
somewm-client eval 'dofile("/tmp/container-place.lua")'
```

It opens the figure on your focused screen and closes after two minutes. Every row is an 80 by 24 block in a place container with one property set.

<FigureLua />

[Download the Lua file](/img/reference/wibox/container-place.lua). To close it early:

```sh
somewm-client eval 'if somewm_reference_figure then somewm_reference_figure.stop() end'
```

</WidgetSource>

Constructor: `wibox.container.place(widget, halign, valign)`. [Upstream page](https://awesomewm.org/apidoc/widget_containers/wibox.container.place.html).

```lua
local centered = wibox.widget {
    clock,
    halign = "center",
    valign = "center",
    widget = wibox.container.place,
}
```

## Properties

| Property | Type | Default | What it does | In SomeWM |
| --- | --- | --- | --- | --- |
| `widget` | widget or nil | `nil` | The child. | |
| `halign` | `"left"`, `"center"`, `"right"` | `"center"` | Horizontal position of the child. | |
| `valign` | `"top"`, `"center"`, `"bottom"` | `"center"` | Vertical position. | |
| `fill_horizontal` | boolean | `false` | Take all the width offered, even when the child is narrower. | |
| `fill_vertical` | boolean | `false` | Take all the height offered. | |
| `content_fill_horizontal` | boolean | `false` | Stretch the child to the full width. | |
| `content_fill_vertical` | boolean | `false` | Stretch the child to the full height. | |

Setting a property emits `property::<name>`.

## Methods

| Method | What it does |
| --- | --- |
| `:reset()` | Removes the child. |

The [common properties, methods and signals](../common.md) apply.
