---
sidebar_position: 7
title: Display Scaling
description: Logical pixels, output scale and widget DPI in SomeWM 2.0.
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Display Scaling <SomewmOnly />

Output scale maps logical desktop coordinates to physical display pixels. A 3840×2160 output at scale 2 has a 1920×1080 logical area.

## Physical vs Logical Pixels

Positions and sizes in screen geometry, client layout and widgets use logical pixels. The output mode describes physical pixels.

| Scale | Physical width of 100 logical pixels |
| --- | --- |
| 1 | 100 pixels |
| 1.5 | 150 pixels |
| 2 | 200 pixels |

These are lengths. At scale 2, a logical square covers four physical pixels. Fractional coordinates require rounding or filtering when rendered.

## Compositor-Side Scaling

<span id="x11-approach" />
<span id="wayland-approach" />

SomeWM tells Wayland clients their preferred scale. Clients render buffers and the compositor maps those buffers into logical surface rectangles. The result depends on the application's scaling support, not just the compositor setting.

## Fractional Scaling

<span id="the-problem" />
<span id="the-protocol-wp_fractional_scale_v1" />

The [fractional-scale protocol](https://wayland.app/protocols/fractional-scale-v1) supplies a preferred scale, used with `wp_viewport` to map a buffer to a logical surface size. For example, a 100×50 surface at scale 1.5 can use a 150×75 buffer with a 100×50 viewport destination.

The protocol does not require rendering at 3× and then reducing to 1.5×. Applications without fractional-scale support may use integer-sized buffers which the compositor resamples. This can blur text and thin lines.

### App Support

Support depends on the toolkit, application version and selected backend. An application running through XWayland does not use the native Wayland fractional-scale protocol. Check its backend before changing compositor settings to address blur.

## DPI vs Scale

<span id="when-to-use-each" />

Output scale and widget DPI are separate settings:

| Setting | Effect |
| --- | --- |
| `s.scale` / `s.output.scale` | Changes the mapping from logical to physical output coordinates |
| `s.dpi` | Used by DPI-aware Lua sizing |
| `beautiful.xresources.apply_dpi(size, s)` | Returns a number calculated from `size × s.dpi / 96`, rounded to an integer |

`apply_dpi()` computes a value when called. It does not bind a property to later DPI changes.

### Auto-DPI

`awful.screen.set_auto_dpi_enabled(true)` enables DPI calculation from output size and physical dimensions. Its result depends on the dimensions reported by the monitor. It does not replace output scaling.

## Mixed-DPI Setups

<span id="the-challenge" />
<span id="somewms-approach" />

Each output has its own scale. Configure by connector identity so the choice does not depend on geometry that changes as you scale it:

```lua
local panel = output.get_by_name("eDP-1")
if panel then
    panel.scale = 1.5
end
```

Replace `eDP-1` with your connector name. For enabled outputs, `s.scale` delegates to the same output setting. Output objects also let you configure a disabled display before it has a screen.

Client buffers may need updating when a window moves between outputs with different scales. Logical positions still determine where screens meet.

## How Widgets Handle Scale

In 2.0, widgets paint into Cairo drawable surfaces. The backing surface scale controls raster resolution, while logical dimensions control layout. `drawin.surface_scale` can override the raster scale, with `0` selecting the output scale.

Changing an output's scale emits `property::scale` for the output and its screen. It does not rerun expressions already evaluated in your theme. If a setting depends on `s.dpi`, recompute and assign it when that DPI changes. A fixed logical size can still render at the output's physical scale.

## Troubleshooting

### Blurry Text on Fractional Scales

Check whether the application runs natively on Wayland and supports fractional scaling. Comparing with an integer output scale can help identify resampling as the cause.

### XWayland Apps Look Wrong

XWayland clients render through X11. Their toolkit's own scaling and the compositor's buffer scaling can interact. Use the application's toolkit documentation for environment overrides rather than applying one override to every application.

### Widgets Don't Update After Scale Change

Distinguish raster sharpness from logical size. For a size set with `apply_dpi`, inspect `s.dpi` and recompute the assigned value. Calling `apply_dpi` once during theme loading does not install an update handler.

## See Also

- [Fractional Scaling](../guides/fractional-scaling.md)
- [Output Reference](../reference/output.md)
- [Screen Reference](../reference/screen.md)
