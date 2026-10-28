---
title: kiln.widgets.toggle
description: A switch controlled by a boolean.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "./_lua/widget-toggle.mdx";

# kiln.widgets.toggle

A switch controlled by a boolean.

![Six toggle switches showing off and on states, size, colour, padding and corner radius](/img/reference/kiln/widget-toggle.png)

The switches are interactive in the Lua example. Each stores its own boolean.

<WidgetSource>

Save the [Lua file](/img/reference/kiln/widget-toggle.lua) as `/tmp/kiln-figure.lua`, then run:

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
widgets.toggle(cfg)
```

## Example

```lua
widgets.toggle {
  id = "mute", on = muted,
  press = function() muted = not muted; kiln.dirty() end,
}
```

## Options

| Field | Type | Default | Behaviour |
|---|---|---|---|
| `id` | string | `nil` | Optional track ID. The knob uses `id .. ":knob"`. |
| `on` | boolean | `false` | Selects the fill colour and knob alignment. |
| `press` | function | `nil` | Called with the pointer event. Update `on` in your own state. |
| `w` | number | `32` | Track width. |
| `h` | number | `16` | Track height. |
| `pad` | number | `2` | Inset around the knob. Knob size is `h - 2 * pad`. |
| `color` | colour | `theme.accent` | Fill when on. |
| `track` | colour | `theme.muted` | Fill when off. |
| `knob` | colour | `theme.fg` | Knob colour. |
| `radius` | number | `floor(h / 2)` | Track radius. The knob radius is half its size, rounded down. |

## Behaviour

Declare `local muted = false` once at config load. The widget does not change it or schedule redraws itself. Keep `h > 2 * pad`.

[Widget conventions](./common.md) cover declaration, state and IDs.
The [runnable form example](./common.md#runnable-example) includes this widget.
