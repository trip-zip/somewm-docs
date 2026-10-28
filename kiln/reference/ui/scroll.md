---
title: kiln.ui.scroll
description: A vertical viewport with per-output scroll state.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "./_lua/ui-scroll.mdx";

# kiln.ui.scroll

Clips a column and moves it in response to wheel input.

![Two scroll viewports showing three and six entries from the same twelve-entry list](/img/reference/kiln/ui-scroll.png)

Both columns contain twelve entries. Wheel over either viewport in the Lua example to scroll.

<WidgetSource>

Save the [Lua file](/img/reference/kiln/ui-scroll.lua) as `/tmp/kiln-figure.lua`, then run:

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
ui.scroll(cfg, children)
```

## Example

```lua
ui.scroll({ id = "history", w = 240, h = 160, step = 24 }, function()
  for i = 1, 20 do
    ui.text("Entry " .. i)
  end
end)
```

## Options

| Field | Type | Default | Behaviour |
|---|---|---|---|
| `id` | element ID | required | Stable viewport ID. |
| `w` | sizing | `"fit"` | Viewport width. |
| `h` | sizing | `"fit"` | Viewport height. Constrain it to produce overflow. |
| `color` | colour | `nil` | Viewport background. |
| `pad` | padding | `0` | Viewport padding. |
| `step` | number | `40` | Logical pixels per unit of `ev.dy`. |

## Behaviour

`children` declares inside a column with `w = "grow"` and `h = "fit"`.
The constructor accepts only the fields above. It installs its own `on_scroll`
and clips vertically; horizontal scrolling is not supported.

Offsets are stored per output and viewport ID. The solved content height limits
the offset. A string ID reserves `id .. ":content"` for the column. A
`{ name, index }` ID reserves `{ name .. ":content", index }`.
