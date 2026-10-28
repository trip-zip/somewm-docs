---
title: kiln.widgets.layoutlist
description: Open a menu of layouts.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "./_lua/widget-layoutlist.mdx";

# kiln.widgets.layoutlist

Open a menu of layouts.

![A menu listing tile, fair, dwindle, spiral, corner, magnifier, carousel, max and floating](/img/reference/kiln/widget-layoutlist.png)

The menu lists the registered layouts in order.

<WidgetSource>

The menu claims keyboard input until it closes.

Save the [Lua file](/img/reference/kiln/widget-layoutlist.lua) as `/tmp/kiln-figure.lua`, then run:

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
widgets.layoutlist(s, cfg?)
```

## Example

```lua
kiln.key {
  mods = { "mod" }, key = "l",
  press = function() widgets.layoutlist(screen.focused) end,
}
```

## Options

| Field | Type | Default | Behaviour |
|---|---|---|---|
| `under` | element ID | `nil` | Anchor below this element. |
| `x` | number | `0` | Output-local x position when `under` is absent. |
| `y` | number | `0` | Output-local y position when `under` is absent. |

## Behaviour

Call from an input handler, outside a declaration. It builds rows from `kiln.layout.list` and opens a [menu](../menu.md). Choosing a row assigns the layout to the screen's selected tag. It overwrites `cfg.items` and `cfg.screen`; other menu fields pass through. It returns no controller. Custom layouts need a name for a usable menu label.

[Widget conventions](./common.md) cover declaration, state and IDs.
