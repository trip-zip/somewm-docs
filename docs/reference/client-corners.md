---
title: Client corners
description: Client shape and content radius, their defaults, colors and pointer behavior.
---

# Client corners

`client.shape` supplies the frame's shape. `client.content_radius` supplies an independent rounded rectangle for the [client content](../concepts/object-model.md#client).

## `client.content_radius`

SomeWM-only, unreleased. Read/write, `number`, `table` or `nil`, default `nil`. Values use logical pixels.

| Value | Behavior |
| --- | --- |
| `nil` or `0` | Restore the corners derived from `shape`, border width and titlebars. Reads back as `nil`. |
| Positive number | Apply that radius to all four content corners, independent of titlebars and border width. |
| Named corner table | Replace all four content radii. Omitted or `nil` corners become zero (square). |
| `{}` | Make all four content corners square. |

Tables accept only `top_left`, `top_right`, `bottom_right` and `bottom_left`. Each radius must be a finite, non-negative number within the supported range (up to `FLT_MAX`, approximately `3.4e38`). Invalid keys, positional arrays, non-numeric values and out-of-range radii raise a Lua error without changing the property.

```lua
c.content_radius = { top_left = 18, top_right = 18 }
```

This sets both bottom corners to zero. Assignments copy the table. Reading the property returns a new table with all four fields, including zero values. To change one corner, assign the edited table back:

```lua
local corners = c.content_radius
corners.bottom_left = 12
c.content_radius = corners
```

The read-modify-write example requires the property to be in table form. A positive numeric assignment reads back as a number.

Any positive content radius paints `content_background_color` behind the content, or `border_color` when unset, even with `border_width = 0`. Titlebar colours are independent. Nil, numeric zero and all-zero tables add no backing.

Changing the stored radii or switching between numeric and table forms emits `property::content_radius` and updates the layout. Reassigning equivalent values in the same form emits no signal. Nil and numeric zero are equivalent. `ruled.client` accepts both numbers and named corner tables.

Fullscreen suppresses the radii until exit without clearing the property. The outer shape clips the content, including with an empty table. Content radii do not affect shadows or titlebar corners.

Exposed inner corners belong to the client frame. They do not pass pointer events to the application or the window below.

## `client.content_background_color`

SomeWM-only, unreleased. Read/write, solid colour string or `nil`, default `nil`.

This colour fills the exposed corners of rounded content. Nil follows `border_color`, including changes caused by focus. An explicit colour does not change the border colour or follow titlebar colours automatically. It applies even when `border_width = 0`.

The property has no effect unless at least one content radius is positive. Fullscreen suppresses the fill without clearing the property. The outer shape clips the fill.

Colour strings accept hex values, including alpha, and named colours supported by `gears.color.parse_color`. Gradients, patterns, tables and invalid colour strings raise an error without changing the property.

Changing the stored value emits `property::content_background_color`. Assigning the current value again emits no signal. `ruled.client` accepts the property.

## `client.shape`

Read/write, `number`, shape function or `nil`, default `nil`. Changing it emits `property::shape`.

A number, `gears.shape.rounded_rect`, or a closure drawing that function supplies native corner radii. The shape clips the entire frame, including the border, titlebars and content backing. The outer silhouette does not depend on `content_radius`.

The radius is reduced by the border width, then assigned to titlebars on their edges and to the remaining content corners. A positive number or table assigned to `content_radius` replaces only the content's derived corners. Explicitly square content remains inside the rounded border.

Other shape functions define a path around the whole frame, including the border and titlebars. Drawing and input are clipped to that path. Fullscreen ignores the shape.

Nil clears the shape. Negative numeric radii and values other than numbers, functions or nil raise a Lua error.

`shape_bounding`, `shape_clip` and `shape_input` accept assignments but have no effect and return `nil`. `gears.surface.apply_shape_bounding` assigns `client.shape`.

## Titlebar `corner_padding`

SomeWM-only, unreleased. An option in `awful.titlebar(c, args)`, default `true`. It insets widgets at both ends of a titlebar without moving its background or changing the client's content radius.

| Value | Behaviour |
| --- | --- |
| `true` or omitted | Use the recognised outer shape radius minus border width, clamped to zero. |
| `false` | Add no corner inset. |
| Number from 0 to 65535 | Set both end insets in logical pixels, rounded to the nearest integer. |

For automatic padding on a left or right titlebar, the top and bottom titlebar heights reduce their respective end insets, down to zero. An unrecognised custom shape has no automatic inset; a numeric option supplies one. Invalid types and numbers outside the range raise an error.

Automatic padding updates when the shape, border width, or top/bottom titlebar size changes. Widget margins are added to these insets. `content_radius` does not affect them.

For configuration examples, see [Round client corners](../guides/rounded-corners.md).
