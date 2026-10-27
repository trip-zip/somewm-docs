---
title: wibox.widget.systray
description: The tray icons of running applications, one instance per session.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "../_lua/widget-systray.mdx";

# wibox.widget.systray

Shows the icons that applications publish over StatusNotifierItem, the D-Bus tray protocol. There is one systray per session: every call to the constructor returns the same widget, so it can be in one bar at a time. Applications that only speak XEmbed do not appear; see [Wayland vs X11](../../../concepts/wayland-vs-x11.md).

![The session's tray: two icons at 32 pixels](/img/reference/wibox/widget-systray.png)

The row is the session's own tray. What it shows depends on what is running.

<WidgetSource>

Save this as `/tmp/widget-systray.lua`, then run:

```sh
somewm-client eval 'dofile("/tmp/widget-systray.lua")'
```

It opens the figure on your focused screen and closes after two minutes. The figure shows the tray of the session it runs on.

<FigureLua />

[Download the Lua file](/img/reference/wibox/widget-systray.lua). To close it early:

```sh
somewm-client eval 'if somewm_reference_figure then somewm_reference_figure.stop() end'
```

</WidgetSource>

Constructor: `wibox.widget.systray(reverse)`, returning the one instance. [Upstream page](https://awesomewm.org/apidoc/widgets/wibox.widget.systray.html).

```lua
local tray = wibox.widget.systray()
tray.base_size = 20
```

## Properties

| Property | Type | Default | What it does | In SomeWM |
| --- | --- | --- | --- | --- |
| `base_size` | integer or nil | `nil` | Icon size in pixels. `nil` sizes icons to the bar. | |
| `horizontal` | boolean | `true` | Icons in a row, or in a column. | |
| `reverse` | boolean | `false` | Newest icon first. | |
| `screen` | screen or nil | `nil` | Show the tray on this screen only. | |

Setting a property emits `property::<name>`. The properties belong to the one instance, so the last value set wins wherever it was set.

Theme variables: `beautiful.bg_systray` (a background that is not solid or a gradient warns once and is transparent), `beautiful.systray_icon_spacing`, `beautiful.systray_paddings`, and `beautiful.systray_max_rows`, which warns once and is one row when set above 1.

Gone in SomeWM 2.1: `awesome.systray`, the C entry point. `wibox.widget.systray_icon` is the per-item widget the tray lays out.

The [common properties, methods and signals](../common.md) apply.
