---
title: kiln.ui.box, row, column and spacer
description: Containers with sizing, padding, alignment, borders and input handlers.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "./_lua/ui-box.mdx";

# kiln.ui.box, row, column and spacer

Containers arrange children along one axis.

![Container examples showing rows, columns, a spacer, centring, padding and a border](/img/reference/kiln/ui-box.png)

The outlined sample boxes show the space available to each container.

<WidgetSource>

Save the [Lua file](/img/reference/kiln/ui-box.lua) as `/tmp/kiln-figure.lua`, then run:

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
ui.box(cfg?, children?)
ui.row(cfg?, children?)
ui.column(cfg?, children?)
ui.spacer()
```

## Example

```lua
ui.row({ gap = 8, align = { y = "center" } }, function()
  ui.box({ w = 14, h = 14, color = "#5078be", radius = 2 })
  ui.text("Connected")
  ui.spacer()
  ui.text("Wi-Fi")
end)
```

## Options

All three containers accept the [element options](./common.md#element-options).
`children` is an optional function called inside the open container. Without
it, the box is a leaf.

| Constructor | Default direction |
|---|---|
| `box` | Left to right. |
| `row` | Left to right. |
| `column` | Top to bottom. |

An explicit `cfg.dir` overrides the direction, including on `row` and `column`.
Omitted width and height use `"fit"`.

`spacer()` takes no arguments. It declares `ui.box({ w = "grow" })`, which fills
available horizontal space. For vertical space, use `ui.box({ h = "grow" })`.
