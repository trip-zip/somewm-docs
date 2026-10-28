---
title: kiln.ui.surface
description: Place a client buffer in the UI tree.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "./_lua/ui-surface.mdx";

# kiln.ui.surface

Places a client's surface tree at the solved box.

![A client surface displaying Lua source without a titlebar or border](/img/reference/kiln/ui-surface.png)

Only the client’s buffer is placed inside the sample box.

<WidgetSource>

This example temporarily replaces the client layout. Closing the figure restores it.

Requires one open client.

Save the [Lua file](/img/reference/kiln/ui-surface.lua) as `/tmp/kiln-figure.lua`, then run:

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
ui.surface(c, cfg?)
```

## Example

Inside a layout that receives client `c`:

```lua
ui.column({ w = "grow", h = "grow" }, function()
  kiln.widgets.titlebar(c, client.focus == c)
  ui.surface(c, { w = "grow", h = "grow" })
end)
```

## Options

Without `cfg`, both axes use `"grow"`. With a cfg table, omitted axes use
`"fit"`. Accepts the [element options](./common.md#element-options).

The surface ID is
`{ "core.surface", c.handle }`; `cfg.id` does not replace it. Declare a client's
surface at most once per output. Duplicate IDs reject the frame.

For a titlebar, border and floating resize handles, use
[`widgets.client`](../widgets/client.md).
