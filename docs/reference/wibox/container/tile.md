---
title: wibox.container.tile
description: One copy of the child; tiling is not applied.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "../_lua/container-tile.mdx";

# wibox.container.tile

In AwesomeWM this container repeats its child across its box. SomeWM draws one copy, centered, and warns once that tiling is not applied. The class stays loadable so configurations that use it keep working.

![A single block centered in a wide box](/img/reference/wibox/container-tile.png)

Each row sets one property. The outline is the box the container was given.

<WidgetSource>

Save this as `/tmp/container-tile.lua`, then run:

```sh
somewm-client eval 'dofile("/tmp/container-tile.lua")'
```

It opens the figure on your focused screen and closes after two minutes. The row is a block in a tile container.

<FigureLua />

[Download the Lua file](/img/reference/wibox/container-tile.lua). To close it early:

```sh
somewm-client eval 'if somewm_reference_figure then somewm_reference_figure.stop() end'
```

</WidgetSource>

Constructor: `wibox.container.tile(args)`. [Upstream page](https://awesomewm.org/apidoc/widget_containers/wibox.container.tile.html).

## Properties

| Property | Type | Default | What it does | In SomeWM |
| --- | --- | --- | --- | --- |
| `widget` | widget or nil | `nil` | The child. | Drawn once. |
| `tiled` | boolean | `true` | Repeat the child. | `true` warns once; one copy is drawn. |
| `horizontal_spacing` | number | `0` | Gap between copies. | No effect. |
| `vertical_spacing` | number | `0` | Gap between rows of copies. | No effect. |

Gone in SomeWM 2.1: `horizontal_crop` and `vertical_crop`.

For a repeated texture behind a bar, prepare the image at the bar's size; see [Put a PNG texture on your wibar](../../../guides/wibar-background-image.md).

The [common properties, methods and signals](../common.md) apply.
