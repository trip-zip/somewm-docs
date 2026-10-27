---
title: wibox.container.background
description: A fill, text color, shape and border around one widget.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "../_lua/container-background.mdx";

# wibox.container.background

Wraps one widget and paints behind it: a solid or gradient fill, an outline, a shape that clips both. Its `fg` sets the text color of everything inside. The container takes its child's size unless an ancestor sizes it.

```lua
local badge = wibox.widget {
    {
        text   = "3",
        widget = wibox.widget.textbox,
    },
    bg           = "#60a5fa",
    fg           = "#1b1b1f",
    shape        = gears.shape.rounded_rect,
    border_width = 1,
    border_color = "#93c5fd",
    widget       = wibox.container.background,
}
badge.bg = "#f59e0b"
```

![Background properties: bg, fg, shape, border_width, shape with border, and both border strategies](/img/reference/wibox/container-background.png)

Each row sets one property. The outline is the box the widget was given, so you can see what the container paints inside it and where the border goes.

<WidgetSource>

Save this as `/tmp/container-background.lua`, then run:

```sh
somewm-client eval 'dofile("/tmp/container-background.lua")'
```

It opens the figure on your focused screen and closes after two minutes. Every row is the same textbox inside a background container with one property set.

<FigureLua />

[Download the Lua file](/img/reference/wibox/container-background.lua). To close it early:

```sh
somewm-client eval 'if somewm_reference_figure then somewm_reference_figure.stop() end'
```

</WidgetSource>

Constructor: `wibox.container.background(widget, bg, shape)`. [Upstream page](https://awesomewm.org/apidoc/widget_containers/wibox.container.background.html).

## Properties

| Property | Type | Default | What it does | In SomeWM |
| --- | --- | --- | --- | --- |
| `widget` | widget or nil | `nil` | The child. | |
| `bg` | color | none | The fill: a color string such as `"#60a5fa"` or `"#60a5fa80"`, or a `gears.color` gradient. | A value that is neither warns once and is transparent. |
| `fg` | color | inherited | The text color for every textbox inside, until a nested background sets its own. | A value that is not a solid color warns once and draws text transparent. |
| `shape` | function | `gears.shape.rectangle` | A `gears.shape` function. Clips the fill, border and child to its path. | `gears.shape.rounded_rect` and any shape that only traces a path work. A function that also paints or sets a color is used for its path only. |
| `border_width` | number | `0` | Outline thickness in pixels, drawn inside the box. | A negative value warns once and is 0. |
| `border_color` | color | `fg`, else `beautiful.fg_normal` | Outline color. | Must be a solid color, or the border warns once and is transparent. |
| `border_strategy` | `"none"`, `"inner"` | `"none"` | `"none"` draws the border over the edge of the child's area. `"inner"` shrinks the child by the border width so the two do not overlap. | |
| `bgimage` | surface or path | none | An image drawn over `bg`, once at its own size in the top-left corner. Deprecated upstream. | A function is not called and warns once. |

Setting a property emits `property::<name>`.

Gone in SomeWM 2.1: `stretch_horizontally` and `stretch_vertically`; the child always fills the container. `wibox.container.border` is gone too; this container with `border_width`, `border_color` and `shape` replaces it. See the [compatibility list](../../deviations.md#classes-and-properties).

## Methods

| Method | What it does |
| --- | --- |
| `:set_shape(shape, ...)` | Sets `shape` with extra arguments for the shape function, such as the corner radius for `gears.shape.rounded_rect`. |

The [common properties, methods and signals](../common.md) apply.
