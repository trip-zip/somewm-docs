---
sidebar_position: 4
title: AwesomeWM widgets in that model
description: Every stock wibox class has a describer that turns its properties into Clay declarations. A widget with its own draw or fit method is left out of the tree, and a property the tree cannot hold warns once.
---

# AwesomeWM widgets in that model

A widget in SomeWM is a description of an element, not a thing that paints one. Every stock class in `wibox.widget`, `wibox.layout` and `wibox.container` has a describer, a function in its module that reads the widget's properties and returns Clay declarations. `wibox.clay` walks the widget tree at each frame's `clay::declare`, calls each describer, and hands the result to C. The API you write is AwesomeWM's: the same constructors, properties and declarative tables.

## What a stock widget declares

| Class | Declares |
| --- | --- |
| `wibox.widget.textbox` | its text, font, colour, alignment and whether it ellipsizes. Clay measures the text through its one measure callback and wraps it at words. |
| `wibox.widget.imagebox` | the image and its aspect. Sized from an explicit ancestor size propagated through the tree ([rules](./reading-the-tree.md#where-a-number-comes-from)): a 32-pixel bar and a square image make a 32 by 32 box. Without that bound, it uses the image's dimensions. |
| `wibox.container.background` | a fill, a border and a corner radius around a child that fills it. A `shape` of `gears.shape.rounded_rect`, or a function drawing that path, is a corner radius. Other shapes clip the fill and child to the supplied path. |
| layouts and containers | a direction, a sizing for each child, padding, a gap and an alignment ([table](./reading-the-tree.md#sizing)) |
| `progressbar`, `slider`, `checkbox`, `arcchart` | composed from the values you set: a progressbar's bar is `value` over `max_value` as a percent of its box, a slider's handle is a path placed at `value`, a checkbox or arcchart is a square sized explicitly or from its ancestors. Nothing is measured. |
| `awful.widget.taglist`, `tasklist`, `layoutlist` | pass through to the layout that holds their items; each tag, task or layout entry is an ordinary widget in the tree |

## A widget that paints itself

A widget with its own `draw`, `fit`, `layout`, `before_draw_children` or `after_draw_children` method is left out of the tree, with everything inside it. The log gets one warning per class naming the methods it found. The wibox's own background stays.

A custom widget written the AwesomeWM way, filling its box with a rounded rectangle:

```lua
local gears = require("gears")
local wibox = require("wibox")
local badge = wibox.widget.base.make_widget(nil, "badge")
function badge:fit(context, width, height) return width, height end
function badge:draw(context, cr, width, height)
    cr:set_source(gears.color("#d79921"))
    gears.shape.rounded_rect(cr, width, height)
    cr:fill()
end
local sample = wibox {
    x = 100, y = 100, width = 400, height = 48, visible = true, bg = "#282828",
    widget = badge,
}
```

Loading it writes to the compositor's log:

```
W: awesome: wibox.clay: badge draws itself (:draw, :fit) and is left out of the tree
```

and `somewm-client clay tree` prints the wibox with nothing under it:

```
  drawin screen 1 400x48+100+100 converted: 1 nodes, 0 images clip w=fixed(400) user h=fixed(48) user row attach ROOT offset 100,100 band 25 box 100,100 400x48
```

`badge` is the name given to `make_widget`; without one, the warning names the file that made the widget. The log is the compositor's standard error: under `somewm-session` that is `journalctl --user -u somewm.service`.

## The same look without a painter

```lua
local gears = require("gears")
local wibox = require("wibox")
local sample = wibox {
    x = 100, y = 100, width = 400, height = 48, visible = true, bg = "#282828",
    widget = {
        widget = wibox.container.background,
        bg = "#d79921",
        shape = gears.shape.rounded_rect,
    },
}
```

```
  drawin screen 1 400x48+100+100 converted: 2 nodes, 0 images clip w=fixed(400) user h=fixed(48) user row attach ROOT offset 100,100 band 25 box 100,100 400x48
    51c3b964 wibox.container.background w=grow h=grow row box 100,100 400x48
```

The background fills the wibox. `gears.shape.rounded_rect` defaults to a corner radius of 10.

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

Without any change to `rc.lua`:

- A wibox with `opacity` below 1 blends each fill at that opacity, so overlapping fills add up: a blue container on a blue wibox at 0.5 is denser than either alone. The renderer draws each fill as its own rect and has no step that blends a finished wibox.
- A `bgimage` set to a function is not drawn and warns, because no widget paints into a surface any more.
- A `shape` function that does more than trace a path is used as the path it traces. A colour it sets or anything it paints is dropped.

[Upgrading from 2.0 to 2.1](../getting-started/upgrading-from-2.0.md) lists every removed property and method.
