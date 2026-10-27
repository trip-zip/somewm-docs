---
sidebar_position: 1
title: wibox
description: Every stock widget, container and layout, with a page each.
---

# wibox

`wibox` provides the window that shows widgets, and the widgets, containers and layouts that go in it. [The object model](../../concepts/object-model.md#widget) defines the terms.

SomeWM has three layers. **Primitives** are the objects C gives Lua: `wibox`, `client`, `screen`, `tag`, input and signals. **Built-ins** are everything Lua composes from them: the classes on this page, plus `awful.popup`, `awful.wibar`, `awful.menu`, `naughty` and the rest. **Usability widgets** are whole features built from built-ins and wired into the default configuration: the launcher, the hotkeys popup, the notification history. Everything SomeWM ships is built from the same parts you get, so you can take it as is, change it, or leave it out. This reference covers the built-ins in `wibox`.

Each class below has its own page with every property, method and signal, and what SomeWM does differently from AwesomeWM. Properties and signals shared by every class are on the [common page](./common.md). Every widget and container has a page. Layout pages wait for the Clay documentation, since a layout's behavior is a Clay sizing rule; until then the upstream page is the property list and the [compatibility list](../deviations.md) has the SomeWM differences.

## Widgets

Show content: text, an image, a value.

| Class | Shows |
| --- | --- |
| [`wibox.widget.calendar`](./widget/calendar.md) | A month or a year, one cell per day |
| [`wibox.widget.checkbox`](./widget/checkbox.md) | A box that is checked or not |
| [`wibox.widget.graph`](./widget/graph.md) | A bar or line graph of values added over time |
| [`wibox.widget.imagebox`](./widget/imagebox.md) | An image file, SVG or Cairo surface |
| [`wibox.widget.piechart`](./widget/piechart.md) | A pie chart of named values |
| [`wibox.widget.progressbar`](./widget/progressbar.md) | A horizontal bar filled to a value |
| [`wibox.widget.separator`](./widget/separator.md) | A line, or any shape, between other widgets |
| [`wibox.widget.slider`](./widget/slider.md) | A draggable handle on a bar |
| [`wibox.widget.systray`](./widget/systray.md) | The tray icons of running applications |
| [`wibox.widget.textbox`](./widget/textbox.md) | Plain or markup text |
| [`wibox.widget.textclock`](./widget/textclock.md) | The time, as a textbox that updates itself |

The widgets that need the compositor live in `awful.widget`: `taglist`, `tasklist`, `layoutbox`, `layoutlist`, `launcher`, `prompt`, `watch`, `clienticon`, `keyboardlayout`, `button`, `only_on_screen`. Notification parts live in `naughty.widget` and `naughty.list`.

## Containers

Wrap one child and change how it looks or how much room it gets.

| Class | Does |
| --- | --- |
| [`wibox.container.arcchart`](./container/arcchart.md) | Draws one or more values as arcs around the child |
| [`wibox.container.background`](./container/background.md) | Fill, text color, shape and border |
| [`wibox.container.constraint`](./container/constraint.md) | A minimum, maximum or exact size |
| [`wibox.container.margin`](./container/margin.md) | Space around the child, optionally colored |
| [`wibox.container.mirror`](./container/mirror.md) | Flips the child horizontally or vertically |
| [`wibox.container.place`](./container/place.md) | Aligns the child inside the space it gets |
| [`wibox.container.radialprogressbar`](./container/radialprogressbar.md) | A ring filled to a value around the child |
| [`wibox.container.rotate`](./container/rotate.md) | Turns the child by a quarter, half or three quarters |
| [`wibox.container.scroll`](./container/scroll.md) | Scrolls a child that is wider or taller than its box |
| [`wibox.container.tile`](./container/tile.md) | Draws the child once; tiling is not applied in SomeWM |

`wibox.container.border` is gone in SomeWM 2.1. Use `background` with `border_width`, `border_color` and `shape`.

## Layouts

Arrange several children.

| Class | Arranges children |
| --- | --- |
| `wibox.layout.align` | In three slots: start, middle, end |
| `wibox.layout.fixed` | In order, each at its own size |
| `wibox.layout.flex` | In order, all the same size |
| `wibox.layout.grid` | In rows and columns |
| `wibox.layout.manual` | At positions you give |
| `wibox.layout.overflow` | In order, scrolling when they do not fit |
| `wibox.layout.ratio` | In order, each with a share of the space |
| `wibox.layout.stack` | On top of one another |

`align`, `fixed`, `flex`, `overflow` and `ratio` come as `.horizontal` and `.vertical`. `grid` has `.horizontal` and `.vertical` too, naming the direction it grows in.

## The window

| Page | Covers |
| --- | --- |
| [Wibar properties](./wibar.md) | `awful.wibar`, a wibox on a screen edge |

## Writing a widget tree

Widgets are declared as nested tables. `widget` or `layout` names the class, named fields are its properties, unnamed entries are its children:

```lua
wibox.widget {
    {
        {
            text = "Hello",
            widget = wibox.widget.textbox,
        },
        margins = 8,
        widget = wibox.container.margin,
    },
    bg = "#333333",
    shape = gears.shape.rounded_rect,
    widget = wibox.container.background,
}
```

An `id` on a nested widget lets you reach it later from the root:

```lua
local w = wibox.widget {
    {
        id = "my_text",
        text = "",
        widget = wibox.widget.textbox,
    },
    widget = wibox.container.margin,
}

w:get_children_by_id("my_text")[1].text = "Updated"
```

Custom widgets compose these classes, register a Clay description, or display a Cairo image surface. See [Create or port a custom widget](../../guides/custom-widgets.md). [How widgets are laid out](../../concepts/widgets-in-the-tree.md) explains how a tree becomes sizes and positions.

## Behavioral notes {#behavioral-notes}

SomeWM uses the SNI (StatusNotifierItem) protocol for the system tray instead of X11's XEmbed. See [Wayland vs X11](../../concepts/wayland-vs-x11.md).

A widget class with its own `fit`, `draw` or `layout` method is left out of the tree with a warning. See [Upgrading from 2.0 to 2.1](../../getting-started/upgrading-from-2.0.md).
