---
title: kiln.widgets.separator
description: A horizontal or vertical line.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "./_lua/widget-separator.mdx";

# kiln.widgets.separator

A horizontal or vertical line.

![Horizontal separators with different thicknesses and lengths, followed by a vertical separator](/img/reference/kiln/widget-separator.png)

The last row places a vertical separator between two text elements.

<WidgetSource>

Save the [Lua file](/img/reference/kiln/widget-separator.lua) as `/tmp/kiln-figure.lua`, then run:

```sh
kiln-client eval 'dofile("/tmp/kiln-figure.lua")'
```

It opens on the focused screen and closes after two minutes. To close it early:

```sh
kiln-client eval 'if kiln_reference_figure then kiln_reference_figure.stop() end'
```

<FigureLua />

</WidgetSource>

```lua
widgets.separator(cfg?)
```

## Example

```lua
widgets.separator { length = 180, thickness = 2 }
```

## Options

| Field | Type | Default | Behaviour |
|---|---|---|---|
| `id` | element ID | `nil` | Optional line ID. |
| `vertical` | boolean | `false` | Use `thickness` for width and `length` for height. |
| `thickness` | number | `1` | Thin axis, in logical pixels. |
| `length` | sizing | `"grow"` | Long axis. |
| `color` | colour | `theme.muted` | Line colour. |

## Behaviour

It declares one box. Set `vertical = true` for a vertical separator.

[Widget conventions](./common.md) cover declaration, state and IDs.
The [runnable form example](./common.md#runnable-example) includes this widget.
