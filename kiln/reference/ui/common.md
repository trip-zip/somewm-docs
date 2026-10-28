---
title: UI conventions
description: Declaration, element options, sizing, input, floats and stacking bands.
---

# UI conventions

Load the module with `local ui = require("kiln").ui`.

## Declaration

Drawing constructors run inside a bar, layout or declare hook. Calling them
outside a frame raises `declare primitives are only callable inside the frame handler`.
They declare the current frame and return no persistent element object.

`ui.bar`, `ui.popup` and `ui.widget` register callbacks. Call them once during
config setup, outside declarations. `bar` and `popup` call their declaration functions during frames.
`widget` returns a function for the caller to invoke inside a declaration.

State changes appear after a new frame. Call `kiln.dirty()` after changing plain
Lua state. See [Frames and dirty](../../concepts/frames-and-dirty.md).

## Element options

`box`, `row`, `column` and `surface` accept these fields. Other constructors
accept only the fields listed on their own pages. Unknown fields are ignored.

| Field | Type | Default | Behaviour |
|---|---|---|---|
| `id` | string or `{ name, index }` | `nil` | ID for readback, anchoring and the inspector. Auto-assigned when an input handler is present. Otherwise the element is anonymous. |
| `w`, `h` | sizing | `"fit"` | Width and height. See sizing below for the forms. |
| `dir` | string | constructor direction | `"row"`/`"ltr"` or `"column"`/`"ttb"`. Overrides the constructor's direction. |
| `pad` | number or table | `0` | All sides, `{ x =, y = }`, or `{ left =, right =, top =, bottom = }`. Named sides override x/y. |
| `gap` | number | `0` | Space between children. |
| `align` | string or table | top-left | `"center"`, or `{ x =, y = }`. x accepts `"left"`, `"center"`, `"right"`; y accepts `"top"`, `"center"`, `"bottom"`. |
| `color` | colour | transparent | Background fill. |
| `radius` | number | `0` | Radius of all four corners. |
| `border` | table | `nil` | `{ width =, color = }`. Width defaults to 1. A width table accepts `left`, `right`, `top`, `bottom` and `between`; omitted sides use 0. `between` draws dividers between children. |
| `float` | table | `nil` | Removes the element from normal layout. See below. |
| `aspect` | number | `nil` | Width divided by height. |
| `clip` | table | `nil` | `{ vertical =, horizontal =, childOffset = { x =, y = } }`. Clips children and offsets their content. |
| `image` | table | `nil` | `{ path = }`. Image fill. |
| `on_press` | function | `nil` | Pointer press `(ev)`. Event fields include `button`, `mods`, `x`, `y` and `screen`. |
| `on_release` | function | `nil` | Pointer release `(ev)`. |
| `on_hover` | function | `nil` | `(over, hit)` on enter (true) or leave (false). `hit` identifies the element. |
| `on_scroll` | function | `nil` | Wheel input `(ev)`, with `dx` and `dy` deltas. |

### Sizing

Dimensions, padding, gaps and offsets use logical pixels.

| Form | Behaviour |
|---|---|
| number | Fixed size. Must be non-negative. |
| `"fit"` | Size follows content. |
| `"grow"` | Fills available space. |
| `"N%"` | Percentage of the parent's size, from `"0%"` to `"100%"`. |
| `{ "fit", min =, max = }` | Content size with bounds. |
| `{ "grow", min =, max = }` | Available space with bounds. |
| `{ "fixed", px = }` | Fixed size. |
| `{ "percent", percent = }` | Fraction of the parent's size, from 0 to 1. |

For bounded sizing, `min` defaults to 0 and `max` to 0 (no maximum).
A nonzero maximum must be at least the minimum.

### IDs and input

IDs must be unique within an output's frame. A duplicate rejects the frame.
For `{ name, index }`, the name is a string and the index is an integer from
0 to 4294967295. Repeated elements need distinct names or indices.

The deepest element with a handler for an event receives it. Input does not
bubble to ancestors. Pointer coordinates are
[global logical coordinates](../screen.md#geometry-and-units).

## Floating elements {#float}

`float` removes an element from normal layout and attaches it to a parent,
root or named element:

| Sub-field | Values | Meaning |
|---|---|---|
| `anchor` | `"center"`, `"top"`, `"bottom"`, `"left"`, `"right"`; any Clay attach point (`"left_top"`, `"center_center"`, `"right_bottom"`, ...); or `{ parent =, element = }` when the two points differ | Attachment points on the target and the element. A string sets both points; the pair form sets them independently. |
| `to` | `"parent"` (default), `"root"`, `"element"` | What the float attaches to. |
| `parent` | element id | The target element, when `to = "element"`. |
| `offset` | `{ x =, y = }` | Offset from the attach point. |
| `band` | band name | Stacking band, see below. |
| `z` | number | Fine z within the band. |
| `passthrough` | boolean | Pointer events pass through the float. |
| `clip` | boolean | The float inherits the clip rectangle of what it attaches to: the part outside is neither drawn nor hittable. For a menu or tooltip anchored inside a `ui.scroll`. Default off: a float extends past its parent freely. |
| `expand` | number, or `{ w =, h = }` | Grow the float's own box outward without moving or resizing its children. One number means both axes. The expanded area receives background paint and pointer input. |
| `fit` | boolean | Keep the float inside the screen's workarea. A `to = "element"` float can flip to the opposite side of its target to reduce overflow. A `to = "root"` float clamps its position. Requires an `id`, because the fit is computed from the element's solved box. |

## Colours

`ui.color(spec)` accepts `"#rrggbb"`, `"#rrggbbaa"` or a table with `r`, `g`, `b`
and `a` channels from 0 to 255. Six-digit strings use alpha 255. Tables pass
through unchanged; nil returns nil. An invalid string raises `bad color`.
The colour fields on UI constructors accept the same forms.

## Bands (z order)

`ui.bands` assigns a base z to each named band:

| Band | Base z |
|---|---|
| `background` | -1000 |
| `below` | 1000 |
| `normal` | 2000 |
| `above` | 3000 |
| `fullscreen` | 4000 |
| `overlay` | 5000 |

A float's effective z is `ui.bands[band] + z`. Without `band`, `z` is used as given; an unknown band name falls back to `normal`. Equal z resolves by declaration order. The in-flow tree sits at z 0.

Layer-shell surfaces declare into the band their protocol layer names: `background` to `background`, `bottom` to `below`, `top` to `above`, `overlay` to `overlay`.
