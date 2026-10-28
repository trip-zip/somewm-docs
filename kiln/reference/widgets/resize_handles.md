---
title: kiln.widgets.resize_handles
description: Eight pointer targets around a floating client.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "./_lua/widget-resize_handles.mdx";

# kiln.widgets.resize_handles

Eight pointer targets around a floating client.

![Amber outlines around a client showing four edge and four corner resize targets](/img/reference/kiln/widget-resize_handles.png)

The amber outlines mark the solved target boxes. Resize handles normally draw no pixels.

<WidgetSource>

This example temporarily replaces the client layout. Closing the figure restores it.

Requires one open client.

It also sets the client’s floating rectangle to 500 by 240 and restores it on close.

Save the [Lua file](/img/reference/kiln/widget-resize_handles.lua) as `/tmp/kiln-figure.lua`, then run:

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
widgets.resize_handles(c, z?)
```

## Example

```lua
widgets.resize_handles(c, 2001)
```

## Options

This function takes no cfg table.

## Behaviour

Declares invisible edge and corner boxes attached to the current parent. Each uses `theme.resize_handle` for its thickness and `(z or 0) + 1` for its z order. Dimensions come from `c.float`, falling back to the client's size.

A left press starts resize from that edge. Hover sets `theme.cursors.resize[edge]`. IDs are `{ "resize_" .. edge, c.handle }` for `n`, `s`, `e`, `w`, `ne`, `nw`, `se`, `sw`.

The [client composite](./client.md) already adds these when `c.floating` is true. Calling them again would duplicate the IDs.

[Widget conventions](./common.md) cover declaration, state and IDs.
