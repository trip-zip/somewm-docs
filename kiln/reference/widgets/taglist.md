---
title: kiln.widgets.taglist
description: One cell per tag on a screen.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "./_lua/widget-taglist.mdx";

# kiln.widgets.taglist

One cell per tag on a screen.

![Three tags with code selected and occupancy markers on code and web](/img/reference/kiln/widget-taglist.png)

`code` is selected. `code` and `web` each contain a client.

<WidgetSource>

This example temporarily replaces the client layout. Closing the figure restores it.

Save the [Lua file](/img/reference/kiln/widget-taglist.lua) as `/tmp/kiln-figure.lua`, then run:

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
widgets.taglist(s, cfg?)
```

## Example

```lua
widgets.taglist(s)
```

## Options

| Field | Type | Default | Behaviour |
|---|---|---|---|
| `on` | table | `{}` | Press and scroll callbacks; see [handler table](./common.md#the-handler-table). |

## Behaviour

The selected tags use `theme.accent`. An occupied tag gets a square; it is filled when that tag is the focused client's first tag. Pressing selects the tag exclusively. IDs include `taglist:<screen>`, `{ "tag", index }` and `{ "tagsquare", index }`.

[Widget conventions](./common.md) cover declaration, state and IDs.
