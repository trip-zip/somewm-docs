---
title: Widget conventions
description: Declaration, state, callbacks and replacement for kiln.widgets.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FormsLua from "./_lua/forms.mdx";

# Widget conventions

Load the module with `local widgets = require("kiln").widgets`.

## Declaration and state

Call drawing functions inside a bar, layout or declare hook. Each call declares
elements for the current frame. It does not return a persistent widget object.
`layoutlist` is an exception: call it from an input handler to open a menu.

The caller stores form values. A slider calls `changed(value)`; a toggle calls
`press(ev)`. Update your value in that callback. The slider dirties its screen;
other callbacks that change plain Lua state must call `kiln.dirty()`.

Only fields listed on each widget's page are read. Widgets do not forward an
arbitrary element cfg. Wrap one in a [UI box](../ui/box.md) to add padding,
clipping, a border or a pointer handler.

## Runnable example

The [form example](/examples/kiln/forms.lua) opens progress, separator, toggle
and slider widgets in one popup. Save it as `/tmp/kiln-forms.lua` and load it
in a running Kiln session:

```sh
kiln-client eval 'dofile("/tmp/kiln-forms.lua")'
```

The toggle and slider update local Lua values. Escape closes the popup.
Loading the file again replaces the previous example. To remove it:

```sh
kiln-client eval 'if kiln_reference_forms then kiln_reference_forms:destroy(); kiln_reference_forms = nil end'
```

<WidgetSource>

<FormsLua />

</WidgetSource>

## IDs

IDs must be unique within an output's declaration. A duplicate rejects the
frame. Slider and toggle IDs must be strings because their child IDs are made
by concatenation. Progress and separator accept the ordinary element ID forms.

Stock bar and client widgets derive IDs from screens, tags and clients. Calling
the same widget twice for the same object in one output can duplicate those IDs.

## Handler table {#the-handler-table}

`taglist`, `tasklist` and `layoutbox` accept `on`:

| Callback | Arguments | Behaviour |
|---|---|---|
| `press` | `(item, ev)` | Receives the tag, client or selected tag. Return truthy to suppress the default press action; nil or false allows it. |
| `scroll` | `(ev)` | Receives wheel input. No default scroll action. |

`ev` carries the button or wheel delta and modifier state. Pointer coordinates
are [global logical coordinates](../screen.md#geometry-and-units). The default
press actions do not restrict the mouse button.

## Replacing a widget

Assign the replacement to `kiln.widgets`, for example
`kiln.widgets.titlebar = function(c, focused) ... end`. Stock callers read that
table, so the replacement also applies inside the client composite.
Reload resets `titlebar`; other replacements remain unless your config changes
them. See [reload state](../../guides/reload-and-debugging.md#2-what-survives-what-resets).

## API available to widgets


Every stock widget uses only API a config can reach with the same spelling. `make check` runs `scripts/widget-lint.sh`, which rejects any name outside this list (beyond `ui.*` and `kiln.widgets` itself):

| Name | What a widget uses it for |
|---|---|
| [`core.box`](/kiln/reference/core) | Read back an element's solved box. The slider uses it to convert pointer positions into values. |
| [`core.dirty`](/kiln/reference/core) | Mark a screen dirty so the next frame redeclares. |
| [`core.timer`](/kiln/reference/core), [`core.timer_cancel`](/kiln/reference/core) | One-shot timer and its cancel; the clock arms one per minute rollover. |
| [`core.tray_activate`](/kiln/reference/core) | Forward a press or scroll to a status-notifier item. |
| [`core.input.set_cursor`](/kiln/reference/core) | Set the pointer image; the resize handles set the edge cursors. |
| `kiln.theme` | Colors and metrics. The same table `state.theme` names inside the stdlib. |
| `client` | The client global: `client.focus`, the properties a row draws. |
| `screen.all` | The screen list. |
| `kiln.icon`, `kiln.layout`, `kiln.systray` | Icon resolution, the layout registry, the tray registry. |
| `kiln.keygrabber`, `kiln.mousegrabber` | Grabs. The widgets reach them through `require("kiln.grab")`, the module both names come from. |

:::note
`core.box` returns nil until the element has been solved once, so a widget that reads its own box needs a stable `id`; `widgets.slider` errors without one.
:::
