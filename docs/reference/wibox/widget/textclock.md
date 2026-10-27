---
title: wibox.widget.textclock
description: The time, as a textbox that updates itself.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "../_lua/widget-textclock.mdx";

# wibox.widget.textclock

A [textbox](./textbox.md) that sets its own markup from a date format every `refresh` seconds. All textbox properties apply: `font`, `halign`, `ellipsize` and the rest.

![Five clocks: the default format, seconds, a bold weekday, UTC, and Tokyo](/img/reference/wibox/widget-textclock.png)

Each row sets one property. The outline is the box the widget was given.

<WidgetSource>

Save this as `/tmp/widget-textclock.lua`, then run:

```sh
somewm-client eval 'dofile("/tmp/widget-textclock.lua")'
```

It opens the figure on your focused screen and closes after two minutes. Every row is a textclock with one property set.

<FigureLua />

[Download the Lua file](/img/reference/wibox/widget-textclock.lua). To close it early:

```sh
somewm-client eval 'if somewm_reference_figure then somewm_reference_figure.stop() end'
```

</WidgetSource>

Constructor: `wibox.widget.textclock(format, refresh, timezone)`. [Upstream page](https://awesomewm.org/apidoc/widgets/wibox.widget.textclock.html).

```lua
local clock = wibox.widget {
    format  = " %H:%M ",
    refresh = 60,
    widget  = wibox.widget.textclock,
}
```

## Properties

| Property | Type | Default | What it does | In SomeWM |
| --- | --- | --- | --- | --- |
| `format` | string | `" %a %b %d, %H:%M "` | A [GLib date format](https://docs.gtk.org/glib/method.DateTime.format.html). Pango markup is allowed. | The textbox markup rules apply: one font, color and style spans draw. |
| `refresh` | number | `60` | Seconds between updates. The clock aligns updates to the refresh boundary, so `60` ticks on the minute. | |
| `timezone` | string | the system zone | A [GTimeZone](https://docs.gtk.org/glib/ctor.TimeZone.new.html) name: `"Z"`, `"+02:00"` or `"Europe/Amsterdam"`. | |

Setting a property emits `property::<name>`.

## Methods

| Method | What it does |
| --- | --- |
| `:force_update()` | Redraws the time now instead of at the next refresh. |

The [textbox properties](./textbox.md#properties) and the [common properties, methods and signals](../common.md) apply.
