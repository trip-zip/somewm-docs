---
title: kiln.widgets.tasklist
description: Client titles and icons for a screen.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "./_lua/widget-tasklist.mdx";

# kiln.widgets.tasklist

Client titles and icons for a screen.

![Two tasklist entries for widgets.lua and ui.lua, with the first focused](/img/reference/kiln/widget-tasklist.png)

The entries belong to two real `foot` windows displaying source files.

<WidgetSource>

Save the [Lua file](/img/reference/kiln/widget-tasklist.lua) as `/tmp/kiln-figure.lua`, then run:

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
widgets.tasklist(s, cfg?)
```

## Example

```lua
widgets.tasklist(s, { width = 160 })
```

## Options

| Field | Type | Default | Behaviour |
|---|---|---|---|
| `filter` | function | `widgets.filter.currenttags` | Predicate `(client, screen)`. See filters below. |
| `width` | sizing | `{ "grow", max = 180 }` | Width of each client row. |
| `on` | table | `{}` | Press and scroll callbacks; see [handler table](./common.md#the-handler-table). |

## Behaviour

Visits clients on `s.tags` in tag order, excluding unmapped and override-redirect clients and removing duplicates. The default filter includes minimized clients. Pressing a minimized row emits `request::minimize(false)`, then attempts focus. It does not select a hidden tag.

Focused rows use `theme.accent`; urgent rows use `theme.urgent`. Titles are clipped and ellipsized. IDs include `tasklist:<screen>` and `task:<handle>`.

## Filters

| Filter | Keeps |
|---|---|
| `widgets.filter.currenttags` | Clients with a selected membership on `s`. |
| `widgets.filter.alltags` | Every candidate from `s.tags`, including hidden tags. |
| `widgets.filter.minimized` | Minimized clients with a selected membership on `s`. |

These filters do not use drawing ownership. A sticky client with no selected membership is excluded by `currenttags`. See [membership and visibility](../client.md#membership-and-visibility).

[Widget conventions](./common.md) cover declaration, state and IDs.
