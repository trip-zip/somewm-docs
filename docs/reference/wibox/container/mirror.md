---
title: wibox.container.mirror
description: The child flipped horizontally, vertically or both.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "../_lua/container-mirror.mdx";

# wibox.container.mirror

Reflects its child across one or both axes.

![The word Mirror four times: as is, flipped left to right, flipped top to bottom, and both](/img/reference/wibox/container-mirror.png)

Each row sets one property. The outline is the box the container was given.

<WidgetSource>

Save this as `/tmp/container-mirror.lua`, then run:

```sh
somewm-client eval 'dofile("/tmp/container-mirror.lua")'
```

It opens the figure on your focused screen and closes after two minutes. Every row is a textbox in a mirror with one reflection set.

<FigureLua />

[Download the Lua file](/img/reference/wibox/container-mirror.lua). To close it early:

```sh
somewm-client eval 'if somewm_reference_figure then somewm_reference_figure.stop() end'
```

</WidgetSource>

Constructor: `wibox.container.mirror(widget, reflection)`. [Upstream page](https://awesomewm.org/apidoc/widget_containers/wibox.container.mirror.html).

```lua
local flipped = wibox.widget {
    icon,
    reflection = { horizontal = true },
    widget     = wibox.container.mirror,
}
```

## Properties

| Property | Type | Default | What it does | In SomeWM |
| --- | --- | --- | --- | --- |
| `widget` | widget or nil | `nil` | The child. | |
| `reflection` | table | `{}` | `{ horizontal = boolean, vertical = boolean }`. | A textbox inside draws as one line; one with several lines is left out with a warning. A scroll container inside is left out with a warning. |

Setting a property emits `property::<name>`.

## Methods

| Method | What it does |
| --- | --- |
| `:reset()` | Removes the child and clears the reflection. |

The [common properties, methods and signals](../common.md) apply.
