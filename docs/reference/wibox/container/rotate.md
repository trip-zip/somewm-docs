---
title: wibox.container.rotate
description: The child turned by a quarter, half or three quarters.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "../_lua/container-rotate.mdx";

# wibox.container.rotate

Rotates its child. The box turns with it, so a rotated wide widget becomes tall. This is how a progressbar or a textbox goes in a vertical bar.

![The word Rotate four times: upright, turned for east, upside down for south, and turned for west](/img/reference/wibox/container-rotate.png)

Each row sets one property. The outline is the box the container was given.

<WidgetSource>

Save this as `/tmp/container-rotate.lua`, then run:

```sh
somewm-client eval 'dofile("/tmp/container-rotate.lua")'
```

It opens the figure on your focused screen and closes after two minutes. Every row is a textbox in a rotate container with one direction set.

<FigureLua />

[Download the Lua file](/img/reference/wibox/container-rotate.lua). To close it early:

```sh
somewm-client eval 'if somewm_reference_figure then somewm_reference_figure.stop() end'
```

</WidgetSource>

Constructor: `wibox.container.rotate(widget, direction)`. [Upstream page](https://awesomewm.org/apidoc/widget_containers/wibox.container.rotate.html).

```lua
local vertical = wibox.widget {
    progressbar,
    direction = "east",
    widget    = wibox.container.rotate,
}
```

## Properties

| Property | Type | Default | What it does | In SomeWM |
| --- | --- | --- | --- | --- |
| `widget` | widget or nil | `nil` | The child. | |
| `direction` | `"north"`, `"east"`, `"south"`, `"west"` | `"north"` | The turn. `"east"` is a quarter turn counterclockwise, so text reads bottom to top. `"south"` is a half turn. `"west"` is a quarter turn clockwise, so text reads top to bottom. | A textbox inside draws as one line; one with several lines is left out with a warning. A rotate or a scroll container inside is left out with a warning. Press coordinates reach the child relative to its rotated box. |

Setting a property emits `property::<name>`.

## Methods

| Method | What it does |
| --- | --- |
| `:reset()` | Removes the child and sets the direction back to north. |

The [common properties, methods and signals](../common.md) apply.
