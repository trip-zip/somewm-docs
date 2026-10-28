---
title: kiln.widgets.slider
description: A draggable value from 0 to 1.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "./_lua/widget-slider.mdx";

# kiln.widgets.slider

A draggable value from 0 to 1.

![Five sliders showing fixed and grow widths, values, colour and height](/img/reference/kiln/widget-slider.png)

Each slider stores the value returned by its `changed` callback.

<WidgetSource>

Save the [Lua file](/img/reference/kiln/widget-slider.lua) as `/tmp/kiln-figure.lua`, then run:

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
widgets.slider(cfg)
```

## Example

```lua
widgets.slider {
  id = "volume", value = volume, w = 180,
  changed = function(v) volume = v end,
}
```

## Options

| Field | Type | Default | Behaviour |
|---|---|---|---|
| `id` | string | `required` | Track ID. The fill uses `id .. ":fill"`. |
| `value` | number | `0` | Displayed fraction, clamped to 0..1. Non-numeric values draw empty. |
| `changed` | function | `nil` | Called with a new value on press and motion. Store it for the next declaration. |
| `w` | sizing | `120` | Track width. |
| `h` | number | `16` | Track and fill height. |
| `color` | colour | `theme.accent` | Fill colour. |
| `track` | colour | `theme.bg2` | Track colour. |
| `radius` | number | `3` | Corner radius of both boxes. |

## Behaviour

Declare `local volume = 0.5` once at config load. Pressing sets the value from the solved track box and starts a pointer grab. Releasing the initiating button ends the drag. The widget redraws its screen after updates. A missing ID raises; a track with no solved width cannot start a drag.

[Widget conventions](./common.md) cover declaration, state and IDs.
The [runnable form example](./common.md#runnable-example) includes this widget.
