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

Any positive content radius paints `border_color` behind the content, even with `border_width = 0`. Titlebar colours are independent. Nil, numeric zero and all-zero tables add no backing.

Changing the stored radii or switching between numeric and table forms emits `property::content_radius` and updates the layout. Reassigning equivalent values in the same form emits no signal. Nil and numeric zero are equivalent. `ruled.client` accepts both numbers and named corner tables.

Fullscreen suppresses the radii until exit without clearing the property. Custom outer shapes clip the content, including with an empty table. Content radii do not affect shadows or titlebar corners.

Exposed inner corners belong to the client frame. They do not pass pointer events to the application or the window below.

## `client.shape`

Read/write, `number`, shape function or `nil`, default `nil`. Changing it emits `property::shape`.

A number, `gears.shape.rounded_rect`, or a closure drawing that function supplies native corner radii. The border remains rectangular. The radius is reduced by the border width, then assigned to titlebars on their edges and to the remaining content corners. A positive number or table assigned to `content_radius` replaces only the content's derived corners.

Other shape functions define a path around the whole frame, including the border and titlebars. Drawing and input are clipped to that path. Fullscreen ignores the shape.

Nil clears the shape. Negative numeric radii and values other than numbers, functions or nil raise a Lua error.

`shape_bounding`, `shape_clip` and `shape_input` accept assignments but have no effect and return `nil`. `gears.surface.apply_shape_bounding` assigns `client.shape`.

For configuration examples, see [Round client corners](../guides/rounded-corners.md).
