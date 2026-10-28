---
title: kiln.widgets.progress
description: A horizontal fill from 0 to 1.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "./_lua/widget-progress.mdx";

# kiln.widgets.progress

A horizontal fill from 0 to 1.

![Six progress bars with different values, colours, radii and heights](/img/reference/kiln/widget-progress.png)

Each row changes the labelled option. The outline shows the available space.

<WidgetSource>

Save the [Lua file](/img/reference/kiln/widget-progress.lua) as `/tmp/kiln-figure.lua`, then run:

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
widgets.progress(cfg)
```

## Example

```lua
widgets.progress { value = 0.6, w = 180, h = 8 }
```

## Options

| Field | Type | Default | Behaviour |
|---|---|---|---|
| `id` | element ID | `nil` | Optional track ID. |
| `fill_id` | element ID | `nil` | Optional fill ID; independent of `id`. |
| `value` | number | `0` | Fill fraction, clamped to 0..1. Non-numeric values draw empty. |
| `w` | sizing | `"grow"` | Track width. |
| `h` | number | `4` | Track and fill height. |
| `color` | colour | `theme.accent` | Fill colour. |
| `track` | colour | `theme.muted` | Track colour. |
| `radius` | number | `2` | Corner radius of both boxes. |

## Behaviour

The fill is a child sized as a percentage of the track. There are no callbacks.

[Widget conventions](./common.md) cover declaration, state and IDs.
The [runnable form example](./common.md#runnable-example) includes this widget.
