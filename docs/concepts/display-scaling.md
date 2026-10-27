---
sidebar_position: 7
title: Display scaling
description: How output scale, logical geometry and theme DPI differ.
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Display scaling <SomewmOnly />

<span id="setting-the-scale" />

Output scale maps logical coordinates to physical pixels. At scale 2, one logical pixel occupies a 2-by-2 block of physical pixels. A 3840-by-2160 output therefore has a logical size of 1920 by 1080, reported by `screen.geometry`.

SomeWM calculates layout in logical pixels. It applies the output scale when rasterising widget content and placing application buffers.

## Changing scale

`screen.scale` controls the associated `output.scale`. Changing it changes the output's logical size, so layouts can move and resize. Text, images and paths are rasterised as needed at the new scale. Client surfaces receive scale information so they can redraw.

Use connector names or physical output modes for automatic scaling. `screen.geometry` is already scaled, so testing its width as if it were a physical resolution can produce the wrong result. See [fractional scaling configuration](../guides/fractional-scaling.md).

## How applications respond

Clients supporting `wp_fractional_scale_v1` can render for the fractional scale requested by the compositor. Other Wayland clients may render at an integer scale and be resampled. XWayland applications have their own scaling limits. Sharpness depends on the application's toolkit and rendering behaviour, not only SomeWM's scale setting.

## Scale and DPI

<span id="mixed-dpi-setups" />
<span id="blurry-apps" />

| Setting | Used for |
| --- | --- |
| `screen.scale`, `output.scale` | Logical-to-physical conversion for an output |
| `screen.dpi`, `beautiful.xresources` | Values used by Lua theme and widget code |
| `beautiful.xresources.apply_dpi(value, screen)` | Convert a theme size using a DPI value at the time of the call |

```lua
local dpi = require("beautiful.xresources").apply_dpi
local height = dpi(24, screen.primary)
```

`height` is a number, not a live binding. A later DPI change does not recompute it. Without a screen argument, `apply_dpi` uses the configured global DPI. Bare numbers also remain fixed in logical pixels, while output scaling still changes how many physical pixels they occupy.

Automatic DPI can derive values from display metadata, but that is separate from choosing an output scale. Avoid applying both adjustments unintentionally.

## Mixed-scale outputs

Outputs can use different scales. Moving a client between them changes the scale information sent to that client. SomeWM also uses each output's scale for the widget content rendered there.

If an application is blurry, check whether it is running through XWayland and whether its toolkit supports fractional scaling. Changing a theme's `dpi()` calls does not fix an application's buffer resolution.
