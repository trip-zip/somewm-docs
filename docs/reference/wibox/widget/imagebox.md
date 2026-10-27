---
title: wibox.widget.imagebox
description: An image file, SVG or Cairo surface, scaled to fit or shown at its own size.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "../_lua/widget-imagebox.mdx";

# wibox.widget.imagebox

Shows one image. Without a size from `forced_width`, `forced_height` or an ancestor, the box is the image's own size. With a size on one axis the image scales to it, keeping its aspect; with both, it fits inside.

![A 64 by 40 image at its own size, scaled to a height of 80, fitted into 200 by 60, unscaled, not upscaled, aligned bottom right, and clipped to a circle](/img/reference/wibox/widget-imagebox.png)

Each row sets one property. The outline is the box the widget was given.

<WidgetSource>

Save this as `/tmp/widget-imagebox.lua`, then run:

```sh
somewm-client eval 'dofile("/tmp/widget-imagebox.lua")'
```

It opens the figure on your focused screen and closes after two minutes. Every row is the same Cairo-drawn 64 by 40 image with one property set.

<FigureLua />

[Download the Lua file](/img/reference/wibox/widget-imagebox.lua). To close it early:

```sh
somewm-client eval 'if somewm_reference_figure then somewm_reference_figure.stop() end'
```

</WidgetSource>

Constructor: `wibox.widget.imagebox(image, resize_allowed, clip_shape, ...)`. [Upstream page](https://awesomewm.org/apidoc/widgets/wibox.widget.imagebox.html).

```lua
local icon = wibox.widget {
    image         = beautiful.awesome_icon,
    forced_height = 16,
    widget        = wibox.widget.imagebox,
}
```

## Properties

| Property | Type | Default | What it does | In SomeWM |
| --- | --- | --- | --- | --- |
| `image` | string, surface, handle or nil | `nil` | A file path (PNG, SVG and what `gears.surface` loads), a Cairo image surface, or an rsvg handle. `nil` shows nothing and takes no space. | An image with no size, such as an SVG handle without dimensions, warns once and is left out. |
| `resize` | boolean | `true` | Scale the image to the box. `false` draws it at its own size, cut at the box. | |
| `upscale` | boolean | `resize` | Allow scaling up. | |
| `downscale` | boolean | `resize` | Allow scaling down. | |
| `halign` | `"left"`, `"center"`, `"right"` | `"center"` | Where the image sits when the box is wider. | |
| `valign` | `"top"`, `"center"`, `"bottom"` | `"center"` | Where the image sits when the box is taller. | |
| `clip_shape` | function | `gears.shape.rectangle` | A `gears.shape` the image is clipped to. Extra constructor arguments go to it. | |
| `max_scaling_factor` | number | `0` | Largest scale allowed; `0` means no limit. | |
| `horizontal_fit_policy` | string | `"auto"` | How the width is used: `"auto"`, `"none"`, `"fit"`, `"repeat"`, `"reflect"`, `"pad"`. | Any value but `"auto"` warns once and draws as `"auto"`. |
| `vertical_fit_policy` | string | `"auto"` | The same for the height. | Same. |
| `scaling_quality` | string | `"good"` | Scaling filter: `"fast"`, `"good"`, `"best"`, `"nearest"`, `"bilinear"`. | Not applied. The renderer picks the filter. |
| `stylesheet` | string | `""` | CSS applied to an SVG, as text or a file path. | |
| `dpi` | number or table | `96` | DPI an SVG is rendered at. | |
| `source_height` | number | | The image's own height. Read only. | |

Setting a property emits `property::<name>`.

Gone in SomeWM 2.1: `auto_dpi` and `source_width`. The output's scale applies. An imagebox with no size on either axis is the image's own size and can overflow a layout; see the [compatibility list](../../deviations.md#layout-rendering-and-client-behaviour).

## Methods

| Method | What it does |
| --- | --- |
| `:set_image(image)` | Sets `image` and returns `true`, or `false` when the file could not be loaded. |
| `:set_clip_shape(shape, ...)` | Sets `clip_shape` with arguments for the shape function. |

The [common properties, methods and signals](../common.md) apply.
