---
sidebar_position: 7
title: Display Scaling
description: How output scaling works on Wayland
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Display Scaling <SomewmOnly />

This page explains how display scaling works in SomeWM and Wayland compositors.

## Physical vs Logical Pixels

Modern high-resolution displays pack more pixels into the same physical space:

| Display | Resolution | Size | Pixel Density |
|---------|------------|------|---------------|
| Standard 1080p | 1920x1080 | 24" | ~92 PPI |
| 4K | 3840x2160 | 27" | ~163 PPI |
| 4K HiDPI | 3840x2160 | 15" laptop | ~294 PPI |

Without scaling, a 4K display shows everything at half the physical size of a 1080p display. Text becomes unreadable.

**Scaling** creates a distinction between two coordinate systems:

- **Physical pixels** - Actual hardware pixels on your display
- **Logical pixels** - The coordinate system applications use

At scale 2.0, one logical pixel equals four physical pixels (2x2). The UI appears the same physical size but renders at higher detail.

```
Scale 1.0:  1 logical pixel = 1 physical pixel
Scale 1.5:  1 logical pixel = 2.25 physical pixels (1.5 x 1.5)
Scale 2.0:  1 logical pixel = 4 physical pixels (2 x 2)
```

## Compositor-Side Scaling

Wayland handles scaling fundamentally differently from X11.

### X11 Approach

On X11, scaling was an afterthought:

1. Apps render at whatever size they want
2. The X server doesn't know about scaling
3. Tools like `xrandr --scale` zoom the entire framebuffer
4. Result: blurry rendering because scaling happens after the fact

### Wayland Approach

Wayland builds scaling into the protocol:

1. The compositor tells apps what scale factor to use
2. Apps render at the appropriate resolution for that scale
3. The compositor places buffers at the correct position
4. Result: crisp rendering because apps know the target resolution

```
X11:     App renders → X Server displays → Zoom (blurry)
Wayland: Compositor tells scale → App renders at scale → Display (crisp)
```

## Fractional Scaling

Integer scaling (1x, 2x) is straightforward. Fractional scaling (1.25x, 1.5x) is more complex.

### The Problem

At scale 1.5, a 10-pixel line should be 15 physical pixels. But if a line starts at pixel 0.5, it spans pixels 0-14.5. Where does pixel 14.5 go?

### The Protocol: wp_fractional_scale_v1

Wayland's `wp_fractional_scale_v1` protocol solves this:

1. Compositor advertises the exact fractional scale (e.g., 1.5)
2. App renders at a larger size (e.g., 3x the logical size)
3. Compositor downscales to the display (3x → 1.5x = 2x physical)
4. Careful math ensures pixel-perfect alignment

Apps that support this protocol render crisply at any fractional scale. Apps that don't fall back to integer scaling with compositor downscaling.

### App Support

| App Type | Fractional Support | Notes |
|----------|-------------------|-------|
| GTK4 | Full | Native protocol support |
| Qt6 | Full | Native protocol support |
| GTK3 | Integer only | Use `GDK_SCALE=2` and compositor downscale |
| Electron | Varies | Set `ELECTRON_OZONE_PLATFORM_HINT=wayland` |
| XWayland | Integer only | X11 apps through compatibility layer |

## DPI vs Scale

These terms are related but distinct:

**DPI (Dots Per Inch)** - A measure of pixel density based on physical display size:

```lua
-- DPI calculation
local diagonal_pixels = math.sqrt(width^2 + height^2)
local diagonal_inches = math.sqrt(mm_width^2 + mm_height^2) / 25.4
local dpi = diagonal_pixels / diagonal_inches
```

**Scale** - A multiplier that tells apps how to render:

```lua
-- Logical dimensions
logical_width = physical_width / scale
logical_height = physical_height / scale
```

### When to Use Each

| Scenario | Use |
|----------|-----|
| Sizing fonts/widgets | `beautiful.xresources.apply_dpi(value)` |
| Configuring display output | `screen.scale = 1.5` |
| Per-app workarounds | Environment variables like `GDK_SCALE` |

### Auto-DPI

SomeWM can automatically calculate DPI from physical monitor dimensions:

```lua
awful.screen.set_auto_dpi_enabled(true)
```

This reads `mm_width` and `mm_height` from the monitor's EDID data and computes appropriate DPI values.

## Mixed-DPI Setups

Multiple monitors with different pixel densities are challenging:

```
┌─────────────────┐  ┌──────────┐
│  4K @ 1.5x      │  │ 1080p    │
│  2560x1440      │  │ 1920x1080│
│  logical        │  │ @ 1.0x   │
└─────────────────┘  └──────────┘
```

### The Challenge

- Windows moving between screens need to resize
- Widgets need to adapt their DPI
- Coordinates at screen boundaries must align

### SomeWM's Approach

Each screen has its own `scale` property. Under the hood, `screen.scale` delegates to `output.scale` on the backing [output](/reference/output) object, keeping a single source of truth:

```lua
awful.screen.connect_for_each_screen(function(s)
    if s.geometry.width > 3000 then
        s.scale = 1.5   -- equivalent to s.output.scale = 1.5
    else
        s.scale = 1.0
    end
end)
```

You can also configure scale on the output directly, which is useful in `output.connect_signal("added", ...)` handlers where you want to set scale before the screen is created:

```lua
output.connect_signal("added", function(o)
    if o.name:match("^eDP") then
        o.scale = 1.5
    end
end)
```

The compositor handles coordinate translation at screen boundaries. When a client moves between screens, it receives the new scale factor and re-renders.

## How Widgets Handle Scale

SomeWM widgets use DPI-aware sizing:

```lua
local dpi = require("beautiful.xresources").apply_dpi

-- This scales with display DPI
theme.wibar_height = dpi(24)
theme.useless_gap = dpi(4)
```

When `screen.scale` changes, SomeWM:

1. Emits `property::scale` signal
2. Invalidates drawable surfaces
3. Widgets re-render at the new scale
4. `dpi()` function returns scaled values

## Troubleshooting

### Blurry Text on Fractional Scales

Some apps don't support `wp_fractional_scale_v1`. Options:

1. Use integer scaling (1.0, 2.0) for those apps
2. Force the app to use a higher scale, let compositor downscale
3. Switch to a Wayland-native alternative

### XWayland Apps Look Wrong

X11 apps through XWayland only support integer scaling. The compositor scales their buffers, which can cause blur at fractional scales.

Workarounds:

```bash
# Force GTK3 app to render at 2x, compositor downscales
GDK_SCALE=2 my-gtk3-app

# Force Qt app scaling
QT_SCALE_FACTOR=1.5 my-qt-app
```

### Widgets Don't Update After Scale Change

Ensure you're using `dpi()` for all size values in your theme:

```lua
-- Wrong: fixed pixels, won't scale
theme.useless_gap = 4

-- Right: DPI-aware, scales automatically
theme.useless_gap = dpi(4)
```

## See Also

- [Fractional Scaling Guide](/guides/fractional-scaling) - Practical configuration
- [output Reference](/reference/output) - Output object API (hardware identification, display configuration)
- [screen Reference](/reference/screen) - API documentation
- [Wayland vs X11](/concepts/wayland-vs-x11) - Platform differences
