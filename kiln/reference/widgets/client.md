---
title: kiln.widgets.client
description: A client surface, titlebar, border and resize handles.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "./_lua/widget-client.mdx";

# kiln.widgets.client

A client surface, titlebar, border and resize handles.

![A client composite with a border, titlebar and terminal displaying Lua source](/img/reference/kiln/widget-client.png)

The terminal content comes from the client’s buffer.

<WidgetSource>

This example temporarily replaces the client layout. Closing the figure restores it.

Requires one open client.

Save the [Lua file](/img/reference/kiln/widget-client.lua) as `/tmp/kiln-figure.lua`, then run:

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
widgets.client(c, cfg?)
```

## Example

```lua
widgets.client(c, { w = "grow", h = "grow" })
```

## Options

| Field | Type | Default | Behaviour |
|---|---|---|---|
| `w` | sizing | `"grow"` | Composite width. |
| `h` | sizing | `"grow"` | Composite height. |
| `z` | number | `0 for handles` | Passed to `widgets.resize_handles`; does not float or restack the composite. |

## Behaviour

Declare once per eligible client in a layout. The composite is a column with `theme.border_width` padding and border, and `theme.client_radius`. The border uses `theme.accent` when focused, `theme.urgent` when urgent, otherwise `theme.bg`.

It calls `widgets.titlebar` unless `c.titlebar == false`, then declares `ui.surface`. Floating clients also get `widgets.resize_handles`. The root ID is `{ "client", c.handle }`. See [custom layouts](../../guides/custom-layouts.md) for placement.

[Widget conventions](./common.md) cover declaration, state and IDs.
