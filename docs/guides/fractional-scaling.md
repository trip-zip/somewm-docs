---
sidebar_position: 7
title: Scale a HiDPI display
description: Configure HiDPI displays with fractional scaling
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Scale a HiDPI display <SomewmOnly />

Increase `screen.scale` to make content larger on a high-resolution output. Start with a value such as `1.25`, `1.5` or `2.0`, then check text and widget sizes on that display.

## Setting Scale from CLI

```bash
somewm-client screen list
somewm-client screen scale
somewm-client screen scale 1 1.5
```

The last command sets screen 1 to `1.5`. With one argument, a decimal such as `1.5` sets the focused screen, while an existing integer screen index queries that screen. Use two arguments when setting scale to avoid ambiguity. Runtime changes are not saved to `rc.lua`.

## Setting Scale from Lua

Set persistent scale by connector name:

```lua
local awful = require("awful")
local scales = { ["eDP-1"] = 1.5, ["DP-1"] = 1.0 }

awful.screen.connect_for_each_screen(function(s)
    local name = s.output and s.output.name
    s.scale = scales[name] or 1.0
end)
```

Replace the connector names with those from your setup. The callback handles existing screens and screens added later.

### Dynamic Adjustment

```lua
awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, "equal", function()
        local s = awful.screen.focused()
        s.scale = math.min(3, s.scale + 0.25)
    end, { description = "increase scale", group = "screen" }),
    awful.key({ modkey }, "minus", function()
        local s = awful.screen.focused()
        s.scale = math.max(0.5, s.scale - 0.25)
    end, { description = "decrease scale", group = "screen" }),
})
```

## Workarea and Geometry

`screen.geometry` and `screen.workarea` use logical coordinates. At a fixed physical mode, increasing scale reduces the available logical area. For example, a 3840×2160 output at scale `2` has a 1920×1080 logical area.

Do not choose a persistent scale by testing `s.geometry.width` against a physical resolution. The width already reflects the current scale.

## Making Themes DPI-Aware

<span id="theme-sizes" />

Output scale and widget DPI are separate settings. `beautiful.xresources.apply_dpi(value, s)` multiplies a logical size by `s.dpi / 96` and rounds it. It does not follow `s.scale` or update a value after the call.

Inside a screen's decoration handler, use it when you intentionally want dimensions based on that screen's DPI:

```lua
local dpi = require("beautiful.xresources").apply_dpi
s.mywibar = awful.wibar {
    screen = s,
    position = "top",
    height = dpi(24, s),
}
```

Output scaling already enlarges logical widget dimensions on the physical display. Multiplying them by `s.scale` again can make them too large. Pango font sizes also use DPI, so avoid applying a pixel-scaling helper to the numeric part of a font string without checking the result.

## App Compatibility

<span id="blurry-apps" />
<span id="troubleshooting" />

Check the application's Wayland backend and fractional-scale support if its text looks blurry. XWayland applications can be resampled, and integer output scale alone does not guarantee sharp text.

For a GTK or Qt application that supports Wayland, test its backend on that launch:

```bash
GDK_BACKEND=wayland my-gtk-app
QT_QPA_PLATFORM=wayland my-qt-app
```

Replace the executable names. These variables affect only that launch. Check output scaling before adding toolkit scale overrides.

## See Also

- [Screen Reference](../reference/screen.md)
- [Display Scaling](../concepts/display-scaling.md)
- [Multi-Monitor Setup](multi-monitor.md)
- [Theme Tutorial](../tutorials/theme.md)
