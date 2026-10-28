---
title: kiln.widgets
description: Stock widgets, with an option reference and example for each function.
---

# kiln.widgets

`kiln.widgets` declares bars and client decorations from `kiln.ui` elements.
Values belong to your config; these functions do not create persistent widget
objects. Read [widget conventions](./widgets/common.md) for state, callbacks
and IDs.

## Form widgets

| Function | Displays |
|---|---|
| [progress](./widgets/progress.md) | A horizontal fill from 0 to 1. |
| [separator](./widgets/separator.md) | A horizontal or vertical line. |
| [toggle](./widgets/toggle.md) | A boolean switch. |
| [slider](./widgets/slider.md) | A draggable value from 0 to 1. |

### widgets.progress(cfg)

See [progress options and example](./widgets/progress.md).

### widgets.separator(cfg?)

See [separator options and example](./widgets/separator.md).

### widgets.toggle(cfg)

See [toggle options and example](./widgets/toggle.md).

### widgets.slider(cfg)

See [slider options and example](./widgets/slider.md).

## Bar cells

| Function | Displays |
|---|---|
| [taglist](./widgets/taglist.md) | Tags on a screen. |
| [tasklist](./widgets/tasklist.md) | Client titles and icons. |
| [systray](./widgets/systray.md) | Status-notifier items. |
| [layoutbox](./widgets/layoutbox.md) | The selected layout. |
| [layoutlist](./widgets/layoutlist.md) | A menu for selecting layouts. |
| [clock](./widgets/clock.md) | Date and time, updated each minute. |

### widgets.filter

See [tasklist filters](./widgets/tasklist.md#filters).

### The handler table

See [press and scroll callbacks](./widgets/common.md#the-handler-table).

## Client widgets

| Function | Declares |
|---|---|
| [client](./widgets/client.md) | Border, titlebar, surface and resize handles. |
| [titlebar](./widgets/titlebar.md) | Title and window buttons. |
| [resize_handles](./widgets/resize_handles.md) | Eight invisible resize targets. |

## The module table is the extension point

See [replacing a widget](./widgets/common.md#replacing-a-widget).

## Writable by a config

See [the API available to widgets](./widgets/common.md#api-available-to-widgets).

## See also

- [UI elements](./ui.md)
- [Widgets tutorial](../tutorials/widgets.md)
- [Data widgets](../guides/data-widgets.md)
