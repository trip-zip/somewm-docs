---
sidebar_position: 2
title: Common properties and signals
description: What every widget, container and layout has, from wibox.widget.base.
---

# Common properties and signals

Every class in `wibox.widget`, `wibox.container` and `wibox.layout` is built on `wibox.widget.base`, and so are the `awful.widget` classes. The per-class pages list only what a class adds; everything here applies to all of them.

## Properties

| Property | Type | Default | What it does | In SomeWM |
| --- | --- | --- | --- | --- |
| `visible` | boolean | `true` | A hidden widget is not drawn and takes no space. | |
| `opacity` | number | `1` | 0 is transparent, 1 is opaque. | Applies to each fill the widget draws, so overlapping fills add up. |
| `forced_width` | number or nil | `nil` | A width in pixels. `nil` lets the layout decide. | A forced size is the size Clay solves the widget at, whatever its content. See [sizing](../../concepts/reading-the-tree.md#sizing). |
| `forced_height` | number or nil | `nil` | A height in pixels. | |
| `buttons` | table | `{}` | The `awful.button` bindings that fire on a click. | |
| `children` | table | `{}` | The direct children. Setting it replaces them on classes that hold children. | |
| `all_children` | table | `{}` | Every descendant, found by walking `children`. Read only. | |
| `animation` | table, false or nil | `nil` | Durations by property for animated changes, `false` to disable animation in this subtree. See [Animation](../../guides/animation.md). | |

Setting any property, here or on a class page, emits `property::<name>` with the new value.

## Methods

| Method | What it does |
| --- | --- |
| `:add_button(button)` | Appends an `awful.button` to `buttons`. |
| `:animate { property = value, ... }` | Changes the named properties with the widget's animation policy. With animation disabled the values apply at once. |
| `:get_children_by_id(id)` | Returns the list of descendants declared with that `id`. Only on the root returned by `wibox.widget { ... }` or `:setup`. |
| `:setup { ... }` | Replaces the widget's children from a declarative table. |
| `:index(widget, recursive)` | Returns the position of `widget` among the children, the parent, and the path to it. |
| `:emit_signal_recursive(name, ...)` | Emits a signal on the widget and on every ancestor in the tree. |
| `:connect_signal(name, fn)`, `:disconnect_signal(name, fn)`, `:emit_signal(name, ...)` | Signals, from `gears.object`. `fn` receives the widget first, then the signal's arguments. |

## Signals

| Signal | Arguments after the widget | When |
| --- | --- | --- |
| `property::<name>` | the new value | A property was set. |
| `button::press`, `button::release` | `lx, ly, button, mods, hit` | A mouse button went down or up over the widget. `lx, ly` are relative to the widget's box, `button` is 1 to 5, `mods` the modifier names. `hit` is the entry described below. |
| `mouse::enter`, `mouse::leave` | `hit` | The pointer moved onto or off the widget. |
| `widget::layout_changed` | | The widget's size may have changed. SomeWM relayouts its subtree. |
| `widget::redraw_needed` | | The widget's look changed. |

A `hit` entry has `widget`, `drawable`, `x`, `y`, `width`, `height` (the widget's box in the wibox), and `widget_width` and `widget_height` (the same box; they differed under a rotate in AwesomeWM). The `hierarchy` field of AwesomeWM is gone with `wibox.hierarchy`.

`awful.button` bindings are the usual way to react to clicks:

```lua
w:add_button(awful.button({}, 1, function() naughty.notification { message = "clicked" } end))
w:connect_signal("mouse::enter", function(self) self.bg = "#333333" end)
```
