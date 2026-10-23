---
sidebar_position: 4
title: Widgets in SomeWM 2.1
description: How built-in and custom widgets get their content, size and position in SomeWM 2.1.
---

# Widgets in SomeWM 2.1

A widget combines content, sizing rules and Lua behaviour. You can build your own by combining built-in widgets, supplying a Clay description, or displaying an image drawn with Cairo. [Create or port a custom widget](../guides/custom-widgets.md) has working examples of each approach.

A *widget tree* is the nesting you write in Lua: a wibar contains a layout, the layout contains widgets, and containers wrap those widgets. For example, a textbox inside a margin container inside a background container is a tree with three widgets.

## From widget properties to layout {#what-a-stock-widget-declares}

Each built-in widget has a *describer*: a function that converts its properties into a table of content and sizing rules. A textbox supplies its text and font. A margin container supplies padding and a child. A horizontal layout supplies its children and the gap between them.

SomeWM combines these descriptions and passes them to Clay, the library that calculates sizes and positions. The renderer then draws the text, backgrounds and images in those positions. The same process also places application windows. [How SomeWM draws](./how-somewm-draws.md) explains that part.

For a textbox inside a margin and a background, Clay measures the text, adds the margins, and determines the background's size from the result and the space its parent gives it. Setting `textbox.text` requests an update. You do not have to measure the new text or repaint the background yourself.

| Widget | What its description supplies |
| --- | --- |
| `wibox.widget.textbox` | Text, font, colour, alignment and ellipsizing. Text wraps at words. |
| `wibox.widget.imagebox` | Image content and sizing information. An explicit size supplied by the widget or its ancestors can limit it. Without such a limit, it uses its natural size. See [image sizing](./reading-the-tree.md#where-a-number-comes-from). |
| `wibox.container.background` | A fill, border and shape around its child. Rounded rectangles use a corner radius. Other shapes clip the fill and child to a path. |
| Layouts and containers | Child sizing, direction, padding, spacing and alignment. See the [sizing table](./reading-the-tree.md#sizing). |
| Progressbar, slider, checkbox and arcchart | Shapes and sizes computed from their properties, such as a progressbar's `value` and `max_value`. |
| `awful.widget.taglist`, `tasklist` and `layoutlist` | A layout containing the widgets for each tag, client or layout entry. |

## Custom behaviour and appearance {#the-same-look-without-a-painter}

A widget made from built-in components can still have its own constructor, methods, state, timers, signals and button bindings. For example, a battery widget can read the charge level, update a textbox and progressbar, and change its background when the charge is low. Using built-in components handles its drawing and sizing. It does not restrict the data or behaviour you add.

For new content or sizing rules, `wibox.clay.describe_widget` registers a description for a widget instance. `describe_class` registers one on a class table. A description can contain other widgets as well as drawing elements. The [custom-widget guide](../guides/custom-widgets.md#register-a-clay-description) shows a meter built this way.

Cairo can also draw into an image surface that an imagebox displays. This is useful for custom artwork, but your code must choose the image dimensions and regenerate it when needed. It does not get an automatic callback with the widget's final size.

## Why an old widget disappears {#a-widget-that-paints-itself}

SomeWM 2.0 and AwesomeWM ask widgets to measure themselves with `fit`, place children with `layout`, and paint with `draw`. SomeWM 2.1 calculates placement from descriptions and draws the result centrally. It does not run those widget callbacks.

An instance with its own `draw`, `fit`, `layout`, `before_draw_children` or `after_draw_children` method is omitted, including all its children. The containing wibox can remain visible with just its background. SomeWM logs a warning once per class:

```text
W: awesome: wibox.clay: badge draws itself (:draw, :fit) and is left out of the tree
```

Here `badge` is the name passed to `wibox.widget.base.make_widget`. Without an explicit name, the warning uses the module name derived from the source file. The methods in parentheses identify what must be replaced. Adding a description without removing these methods does not restore the widget.

This affects custom and third-party widgets that use those callbacks. A custom widget that only combines supported built-in components does not need a new drawing implementation. Custom **client layouts** with `arrange` are a separate API and still work. See [client layouts](./clients-in-the-tree.md).

## Properties that warn once

Unsupported property values produce one warning naming the class, property, and resulting behaviour. If the widget is omitted, the warning ends `and is left out of the tree`.

| You set | Warning |
| --- | --- |
| a background's `bg` that is not a colour or a gradient | is not a solid or a gradient and is transparent |
| `systray_max_rows` above 1 | is one row |
| a margin, `spacing`, padding, gap or border width below 0 | is negative and is 0 |
| a textbox's `ellipsize = "start"` or `"middle"` | start and middle ellipsize at the end |
| a property the class no longer has, such as an imagebox's `auto_dpi` | is ignored |

## What looks different

These differences can affect an existing configuration:

- A wibox with `opacity` below 1 blends each fill at that opacity, so overlapping fills add up: a blue container on a blue wibox at 0.5 is denser than either alone. The renderer draws each fill as its own rect and has no step that blends a finished wibox.
- A `bgimage` set to a function is not drawn and warns, because SomeWM no longer calls it to paint the wibox. A file path or image surface is still supported.
- A `shape` function that does more than trace a path is used as the path it traces. A colour it sets or anything it paints is dropped.

[Upgrading from 2.0 to 2.1](../getting-started/upgrading-from-2.0.md) lists removed properties and methods, with migration advice.
