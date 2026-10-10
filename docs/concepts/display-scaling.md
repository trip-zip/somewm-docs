---
sidebar_position: 7
title: Display Scaling
description: Each output has its own scale. The tree is solved in logical pixels, clients render at the scale they are told, and only rasters are redone when the scale changes.
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Display Scaling <SomewmOnly />

Every output has a scale, and `screen.scale` is `output.scale` on the screen's backing [output](/docs/reference/output). At scale 2, one logical pixel is a 2 by 2 block of physical pixels. SomeWM solves the whole tree in logical pixels; the output's scale is applied when rasters are drawn and when client buffers are placed. An output's logical size is its mode divided by its scale, and that is what `screen.geometry` reports.

Wayland clients are told the scale and render at it, so text is crisp at any scale. Fractional scales go through `wp_fractional_scale_v1`, which SomeWM advertises; a client without it renders at the next integer and is downscaled. XWayland clients only ever get an integer.

## Setting the scale

```lua
-- Per screen, once the screen exists
awful.screen.connect_for_each_screen(function(s)
    s.scale = s.geometry.width > 3000 and 1.5 or 1.0
end)

-- Per output, before its screen is created
output.connect_signal("added", function(o)
    if o.name:match("^eDP") then o.scale = 1.5 end
end)
```

A scale change emits `property::scale` and rasters every text, image and path on that output again at the new scale. The tree is solved in logical pixels, so no box moves and nothing in Lua repaints ([How SomeWM draws](./how-somewm-draws.md)). A client moving between outputs of different scale is told the new scale and re-renders.

## Scale and DPI

| | Scale | DPI |
| --- | --- | --- |
| What it is | the output's logical-to-physical ratio | pixels per inch, from the mode and the panel's physical size |
| Set by | `screen.scale`, `output.scale` | `beautiful.xresources.set_dpi`, or `awful.screen.set_auto_dpi_enabled(true)` to compute it from EDID |
| Used by | clients, rasters, buffer placement | `beautiful.xresources.apply_dpi`, the `dpi()` in themes |

Theme sizes go through `dpi()` so they follow the output:

```lua
local dpi = require("beautiful.xresources").apply_dpi
theme.wibar_height = dpi(24)
theme.useless_gap  = dpi(4)
```

A size written as a bare number stays that many logical pixels at every DPI.

## Mixed-DPI setups

Each screen carries its own scale, and the compositor translates coordinates at screen boundaries. A 4K panel at 1.5 next to a 1080p panel at 1.0 is two screens with different logical sizes and nothing more to configure.

## Blurry apps

| Symptom | Cause | Fix |
| --- | --- | --- |
| a Wayland app is blurry at 1.5 | it lacks `wp_fractional_scale_v1` (GTK3, some Electron) | use an integer scale, or `GDK_SCALE=2` and let the compositor downscale; `ELECTRON_OZONE_PLATFORM_HINT=wayland` for Electron |
| an X11 app is blurry | XWayland gets an integer scale and its buffer is scaled | `GDK_SCALE=2` or `QT_SCALE_FACTOR=1.5` for that app, or a Wayland-native build |
| widgets did not follow a scale change | a theme size written without `dpi()` | wrap it |

[Fractional Scaling](/docs/guides/fractional-scaling) has the per-app configuration.
