---
title: kiln.ui
description: UI constructors, shared element options and popup controllers.
sidebar_position: 8
---

# kiln.ui

`kiln.ui` declares elements for each frame. Load it with
`local ui = require("kiln").ui`. Stock compositions are in
[`kiln.widgets`](./widgets.md).

## Constructors

| Function | Declares |
|---|---|
| [box, row, column, spacer](./ui/box.md) | Containers and flexible space. |
| [text](./ui/text.md) | Text, including font selection and truncation. |
| [image](./ui/image.md) | An image file, optionally recoloured. |
| [surface](./ui/surface.md) | A client's surface tree. |
| [scroll](./ui/scroll.md) | A vertically scrolling column. |
| [each](./ui/each.md) | List items with retained per-key state. |

| Function | Registers |
|---|---|
| [widget](./ui/widget.md) | Signal and timer redraws for a declaration function. |
| [bar](./ui/bar.md) | An edge bar that reserves workarea. |
| [popup](./ui/popup.md) | A popup with show, close and toggle methods. |

## The declare-time contract

Drawing constructors run inside a bar, layout or declare hook. Registration
functions run during config setup. See [declaration rules](./ui/common.md#declaration).

## The cfg contract

[Element options](./ui/common.md#element-options) define sizing, padding,
alignment, borders and input for `box`, `row`, `column` and `surface`.
Other constructors accept only the fields on their own pages.

### float

[Floating elements](./ui/common.md#float) attach to a parent, root or named
element outside normal layout.

## Bars

[Bar options](./ui/bar.md) cover edge selection, workarea and per-frame defaults.

## Popups

[Popup options and methods](./ui/popup.md) cover positioning, keyboard claims,
scrims and controller lifetime.

## Fonts

[Text fonts](./ui/text.md#fonts) use Pango descriptions. Font size is a separate field.

## Truncation

[Ellipsizing](./ui/text.md#truncation) requires a horizontally clipping ancestor.

## Bands (z order)

[Stacking bands](./ui/common.md#bands-z-order) define the base z values in `ui.bands`.

## Menus

`ui.menu(cfg)` aliases [`kiln.menu.show`](./menu.md).
`ui.tooltip(text)` aliases [`kiln.tooltip.attach`](./kiln.md#kilntooltip).
`ui.hotkeys(s)` aliases [`kiln.hotkeys.show`](../guides/hotkeys-popup.md).
`ui.color(spec)` parses [colour specifications](./ui/common.md#colours).

## See also

- [A bar from scratch](../tutorials/a-bar-from-scratch.md)
- [Create a popup](../guides/popups.md)
- [Nodes, floats and bands](../concepts/nodes-floats-and-bands.md)
