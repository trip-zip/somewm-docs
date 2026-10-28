---
title: kiln.widgets.layoutbox
description: The first selected tag's layout.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "./_lua/widget-layoutbox.mdx";

# kiln.widgets.layoutbox

The first selected tag's layout.

![Layout indicator displaying tile](/img/reference/kiln/widget-layoutbox.png)

Without a family icon, the indicator displays the layout name.

<WidgetSource>

Save the [Lua file](/img/reference/kiln/widget-layoutbox.lua) as `/tmp/kiln-figure.lua`, then run:

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
widgets.layoutbox(s, cfg?)
```

## Example

```lua
widgets.layoutbox(s)
```

## Options

| Field | Type | Default | Behaviour |
|---|---|---|---|
| `on` | table | `{}` | Press and scroll callbacks; see [handler table](./common.md#the-handler-table). |

## Behaviour

Pressing selects the next entry in `kiln.layout.list`. It draws the family icon from `theme.layout_icons` when set; otherwise it draws the layout name, or `?` for an unnamed layout. With no selected tag it declares nothing. The ID is `layoutbox:<screen>`.

[Widget conventions](./common.md) cover declaration, state and IDs.
