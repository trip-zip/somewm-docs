---
title: kiln.widgets.clock
description: A clock updated at minute boundaries.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "./_lua/widget-clock.mdx";

# kiln.widgets.clock

A clock updated at minute boundaries.

![Kiln clock showing the local date and time](/img/reference/kiln/widget-clock.png)

The capture uses the session’s local time.

<WidgetSource>

Save the [Lua file](/img/reference/kiln/widget-clock.lua) as `/tmp/kiln-figure.lua`, then run:

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
widgets.clock()
```

## Example

```lua
widgets.clock()
```

## Options

This function takes no cfg table.

## Behaviour

Draws `os.date("%a %b %d  %H:%M")` in the theme font. The first declaration arms a shared timer for 50 ms after the next minute boundary. Each timer dirties all screens and rearms. Reload cancels it; the next declaration starts it again.

There are no format or colour arguments. For another format, use `ui.widget` with `every` and `ui.text`, as in the [widgets tutorial](../../tutorials/widgets.md).

[Widget conventions](./common.md) cover declaration, state and IDs.
