---
sidebar_position: 7
title: Fractional Scaling
description: Configure HiDPI displays with fractional scaling
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Fractional Scaling <SomewmOnly />

SomeWM supports fractional output scaling for HiDPI displays through the `screen.scale` property.

## What is Fractional Scaling?

Display scaling makes UI elements larger on high-resolution displays:

| Scale | Effect | Use Case |
|-------|--------|----------|
| 1.0 | Native resolution | Standard 1080p/1440p |
| 1.25 | 25% larger | 1440p HiDPI |
| 1.5 | 50% larger | 4K laptop displays |
| 2.0 | Double size | 4K desktop / Retina |

Without scaling, a 4K display makes everything tiny. Fractional scaling (1.25, 1.5, 1.75) offers more options than just integer scaling (1x, 2x).

## Setting Scale from Lua

### At Startup

In your rc.lua:

```lua
-- Set scale for all screens
awful.screen.connect_for_each_screen(function(s)
    s.scale = 1.5
end)

-- Or just the primary screen
screen.primary.scale = 1.5
```

### Per-Screen Configuration

```lua
awful.screen.connect_for_each_screen(function(s)
    -- Different scale based on screen size
    if s.geometry.width > 3000 then
        s.scale = 1.5  -- 4K display
    elseif s.geometry.width > 2000 then
        s.scale = 1.25  -- 1440p display
    else
        s.scale = 1.0  -- 1080p or smaller
    end
end)
```

### Dynamic Adjustment

```lua
-- Keybinding to adjust scale
awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, "equal", function()
        local s = awful.screen.focused()
        s.scale = s.scale + 0.25
    end, { description = "increase scale", group = "screen" }),

    awful.key({ modkey }, "minus", function()
        local s = awful.screen.focused()
        s.scale = math.max(0.5, s.scale - 0.25)
    end, { description = "decrease scale", group = "screen" }),
})
```

## Setting Scale from CLI

Use `somewm-client` to adjust scale at runtime:

```bash
# Get current scale of focused screen
somewm-client screen scale

# Set focused screen to 1.5
somewm-client screen scale 1.5

# Set specific screen (by index)
somewm-client screen scale 1 1.5
somewm-client screen scale 2 1.0
```

## Making Themes DPI-Aware

Use `beautiful.xresources.apply_dpi()` to scale theme values:

```lua
-- theme.lua
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local theme = {}

-- These values scale with DPI
theme.font = "sans " .. dpi(10)
theme.useless_gap = dpi(4)
theme.border_width = dpi(2)
theme.notification_width = dpi(300)

-- Icon sizes
theme.menu_height = dpi(20)
theme.menu_width = dpi(150)

-- Widget sizes
theme.wibar_height = dpi(24)
theme.systray_icon_spacing = dpi(4)

return theme
```

The `dpi()` function reads the system DPI and scales values accordingly.

### Manual DPI Calculation

If you need more control:

```lua
local function scale_value(value)
    local s = awful.screen.focused()
    return math.floor(value * (s.scale or 1.0))
end

-- Usage
local margin = scale_value(8)  -- 8 at 1x, 12 at 1.5x, etc.
```

## Workarea and Geometry

When you change scale, screen geometry updates:

```lua
local s = screen.primary
print("Before:", s.geometry.width, s.geometry.height)

s.scale = 2.0

print("After:", s.geometry.width, s.geometry.height)
-- Width/height are now halved (logical pixels)
```

The `workarea` also recalculates to account for wibars at the new scale.

## App Compatibility

### Wayland-Native Apps

Apps supporting `wp_fractional_scale_v1` render at native resolution and scale properly. Most modern GTK4 and Qt6 apps support this.

### XWayland Apps

X11 apps through XWayland may appear blurry at fractional scales. Options:

1. **Use integer scaling** (1.0, 2.0) for crisp XWayland apps
2. **Force per-app scaling** via environment variables:

```lua
-- Force 2x for specific app, let Wayland downscale
awful.spawn.with_shell("GDK_SCALE=2 my-gtk-app")
```

### GTK Apps

```bash
# Force GTK3 to use Wayland
export GDK_BACKEND=wayland

# Or set in rc.lua autostart
awful.spawn.with_shell("export GDK_BACKEND=wayland")
```

### Qt Apps

```bash
# Enable Qt Wayland
export QT_QPA_PLATFORM=wayland
export QT_SCALE_FACTOR=1.5
```

### Electron Apps

```bash
# Enable Wayland for Electron
export ELECTRON_OZONE_PLATFORM_HINT=wayland
```

## Mixed-DPI Multi-Monitor

For setups with different DPI monitors:

```lua
awful.screen.connect_for_each_screen(function(s)
    -- Identify screen by geometry or output name
    if s.geometry.width == 3840 then
        s.scale = 1.5  -- 4K monitor
    else
        s.scale = 1.0  -- 1080p monitor
    end
end)
```

### Handling Hotplug

```lua
screen.connect_signal("added", function(s)
    -- New monitor connected, set appropriate scale
    if s.geometry.width > 3000 then
        s.scale = 1.5
    else
        s.scale = 1.0
    end
end)
```

## Common Scale Values

| Resolution | Diagonal | Recommended Scale |
|------------|----------|-------------------|
| 1920x1080 | 24"+ | 1.0 |
| 2560x1440 | 27" | 1.0 - 1.25 |
| 3840x2160 | 27" | 1.5 - 2.0 |
| 3840x2160 | 32" | 1.25 - 1.5 |
| 2880x1800 | 15" (laptop) | 1.5 - 2.0 |

## Troubleshooting

### Blurry Text

- Try integer scaling (1.0, 2.0) instead of fractional
- Ensure app supports Wayland native rendering
- Check font hinting settings

### Widgets Wrong Size

Make sure you're using `dpi()` for all size values in theme.lua:

```lua
-- Wrong: fixed pixel values
theme.useless_gap = 4

-- Right: DPI-aware values
theme.useless_gap = dpi(4)
```

### Scale Not Applying

Check that you're setting scale on the correct screen:

```lua
-- Debug: print all screens and their scales
for s in screen do
    print("Screen " .. s.index .. ": scale = " .. (s.scale or "nil"))
end
```

## See Also

- **[Multi-Monitor Setup](/guides/multi-monitor)** - Per-screen configuration
- **[CLI Control](/guides/cli-control)** - somewm-client screen commands
- **[Theme](/tutorials/theme)** - Creating DPI-aware themes
