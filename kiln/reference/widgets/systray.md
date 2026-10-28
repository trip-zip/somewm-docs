---
title: kiln.widgets.systray
description: Status-notifier item icons.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "./_lua/widget-systray.mdx";

# kiln.widgets.systray

Status-notifier item icons.

![A StatusNotifierItem information icon rendered at size 32](/img/reference/kiln/widget-systray.png)

The capture uses one test StatusNotifierItem on a private D-Bus session.

<WidgetSource>

Displays the items already registered in your session.

Save the [Lua file](/img/reference/kiln/widget-systray.lua) as `/tmp/kiln-figure.lua`, then run:

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
widgets.systray(cfg?)
```

## Example

```lua
widgets.systray { size = 20 }
```

## Options

| Field | Type | Default | Behaviour |
|---|---|---|---|
| `size` | number | `18` | Width and height of each item, in logical pixels. |

## Behaviour

Declares items in registration order. With no items it declares nothing. An item with no icon gets a muted box. Pressing forwards `activate`; scrolling forwards the vertical delta, or the horizontal delta if vertical is zero. It does not provide a context menu.

IDs are `tray:<service>`. Kiln needs a session bus and applications using StatusNotifierItem. See `kiln.systray.items()` in the [module reference](../kiln.md).

[Widget conventions](./common.md) cover declaration, state and IDs.
