---
title: kiln.widgets.titlebar
description: A client title with maximise and close buttons.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "./_lua/widget-titlebar.mdx";

# kiln.widgets.titlebar

A client title with maximise and close buttons.

![Two client titlebars showing focused and unfocused colours](/img/reference/kiln/widget-titlebar.png)

The `focused` argument selects the colours. Both clients are real `foot` windows.

<WidgetSource>

This example temporarily replaces the client layout. Closing the figure restores it.

Requires two open clients.

Save the [Lua file](/img/reference/kiln/widget-titlebar.lua) as `/tmp/kiln-figure.lua`, then run:

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
widgets.titlebar(c, focused?)
```

## Example

```lua
widgets.titlebar(c, client.focus == c)
```

## Options

This function takes no cfg table.

## Behaviour

Declare inside a client composite, once per client per output. `focused` selects the active colours; omitted is false. The row uses `theme.titlebar_height`. Left-pressing its body focuses the client and starts a move drag. Inner buttons toggle maximisation or request close.

The title is clipped and ellipsized. IDs are `{ "titlebar", c.handle }`, `{ "maximize", c.handle }` and `{ "close", c.handle }`. Replace this function on `kiln.widgets` to change every stock client titlebar.

[Widget conventions](./common.md) cover declaration, state and IDs.
