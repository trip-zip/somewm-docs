---
title: Client corners
description: Client shape and content radius, their defaults, colors and pointer behavior.
---

# Client corners

`client.shape` supplies the frame's shape. `client.content_radius` supplies an independent rounded rectangle for the application content.

## `client.content_radius`

SomeWM-only, unreleased. Read/write, `number` or `nil`, default `nil`. Values use logical pixels.

| Value | Behavior |
| --- | --- |
| `nil` or `0` | Preserve the corners derived from `shape`, border width and titlebars. Reads back as `nil`. |
| Positive number | Apply that radius to all four content corners, independent of titlebars and border width. |
| Negative number or another type | Raise a Lua error. |

Positive values paint `border_color` behind the content, even with `border_width = 0`. Titlebar colors are independent. Nil or zero adds no backing.

Changing the stored value emits `property::content_radius` and updates the layout. Reassigning the same value emits no signal. `ruled.client` passes the number unchanged.

Fullscreen suppresses the radius until exit without clearing the property. Custom outer shapes clip the rounded content. The inner radius does not affect shadows.

Exposed inner corners belong to the client frame. They do not pass pointer events to the application or the window below.

## `client.shape`

Read/write, `number`, shape function or `nil`, default `nil`. Changing it emits `property::shape`.

A number, `gears.shape.rounded_rect`, or a closure drawing that function supplies native corner radii. The border remains rectangular. The radius is reduced by the border width, then assigned to titlebars on their edges and to the remaining content corners. A positive `content_radius` replaces only the content's derived corners.

Other shape functions define a path around the whole frame, including the border and titlebars. Drawing and input are clipped to that path. Fullscreen ignores the shape.

Nil clears the shape. Negative numeric radii and values other than numbers, functions or nil raise a Lua error.

`shape_bounding`, `shape_clip` and `shape_input` accept assignments but have no effect and return `nil`. `gears.surface.apply_shape_bounding` assigns `client.shape`.

For configuration examples, see [Round client corners](../guides/rounded-corners.md).
