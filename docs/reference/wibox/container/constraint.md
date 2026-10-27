---
title: wibox.container.constraint
description: A minimum, maximum or exact size for the child.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "../_lua/container-constraint.mdx";

# wibox.container.constraint

Limits the child's size on one or both axes. The limit is a maximum by default; `strategy` makes it a minimum or an exact size.

![Five constraints: none, a width limit of 200 on a long text, a minimum width of 200 on a short text, an exact width of 200, and an exact height of 70](/img/reference/wibox/container-constraint.png)

Each row sets one property. The outline is the box the container was given.

<WidgetSource>

Save this as `/tmp/container-constraint.lua`, then run:

```sh
somewm-client eval 'dofile("/tmp/container-constraint.lua")'
```

It opens the figure on your focused screen and closes after two minutes. Every row is a background-filled textbox in a constraint with one property set.

<FigureLua />

[Download the Lua file](/img/reference/wibox/container-constraint.lua). To close it early:

```sh
somewm-client eval 'if somewm_reference_figure then somewm_reference_figure.stop() end'
```

</WidgetSource>

Constructor: `wibox.container.constraint(widget, strategy, width, height)`. [Upstream page](https://awesomewm.org/apidoc/widget_containers/wibox.container.constraint.html).

```lua
local title = wibox.widget {
    tasklist_widget,
    width    = 300,
    strategy = "max",
    widget   = wibox.container.constraint,
}
```

## Properties

| Property | Type | Default | What it does | In SomeWM |
| --- | --- | --- | --- | --- |
| `widget` | widget or nil | `nil` | The child. | |
| `strategy` | `"max"`, `"min"`, `"exact"` | `"max"` | Whether `width` and `height` cap the child, are a floor for it, or set it. | An unknown value warns once and applies no limit. |
| `width` | number or nil | `nil` | The width limit in pixels. `nil` leaves the width free. | |
| `height` | number or nil | `nil` | The height limit. | |

Setting a property emits `property::<name>`.

## Methods

| Method | What it does |
| --- | --- |
| `:reset()` | Removes the child and clears the limits. |

The [common properties, methods and signals](../common.md) apply.
