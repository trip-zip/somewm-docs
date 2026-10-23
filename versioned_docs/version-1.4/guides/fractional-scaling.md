---
sidebar_position: 7
title: Fractional Scaling
description: Configure HiDPI displays with fractional scaling
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Fractional Scaling <SomewmOnly />

<span id="what-is-fractional-scaling" />

Set `screen.scale` to enlarge the logical desktop on a high-resolution output. Start with a value such as `1.25`, `1.5` or `2.0`, then check text and widget sizes on that display.

## Setting Scale from CLI

```bash
somewm-client screen list
somewm-client screen scale
somewm-client screen scale 1 1.5
```

The last command sets screen 1 to `1.5`. With one numeric argument, `screen scale 1.5` changes the focused screen. Runtime changes are not saved to `rc.lua`.

## Setting Scale from Lua

<span id="at-startup" />
<span id="per-screen-configuration" />

Configure each output by connector name, which is more reliable than its screen index or current logical width:

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

The `0.5`–`3` bounds are a choice made by these bindings.

## Workarea and Geometry

`screen.geometry` and `screen.workarea` use logical coordinates. At a fixed physical mode, increasing scale reduces the available logical area. For example, a 3840×2160 output at scale `2` has a 1920×1080 logical area.

Do not choose a persistent scale by testing `s.geometry.width` against a physical resolution. The width already reflects the current scale.

## Making Themes DPI-Aware

<span id="manual-dpi-calculation" />

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

<span id="wayland-native-apps" />
<span id="xwayland-apps" />
<span id="gtk-apps" />
<span id="qt-apps" />
<span id="electron-apps" />
<span id="mixed-dpi-multi-monitor" />
<span id="handling-hotplug" />
<span id="common-scale-values" />

Check the application's Wayland backend and fractional-scale support if its text looks blurry. XWayland applications can be resampled, and integer output scale alone does not guarantee sharp text.

For a GTK or Qt application that supports Wayland, test its backend on that launch:

```bash
GDK_BACKEND=wayland my-gtk-app
QT_QPA_PLATFORM=wayland my-qt-app
```

Replace the example executable names. These variables affect only the launched process. Setting them with `export` in a short-lived child shell does not configure future applications. Avoid combining toolkit scale overrides with output scaling until you have checked each separately.

## Troubleshooting

<span id="blurry-text" />
<span id="widgets-wrong-size" />
<span id="scale-not-applying" />

- **Scale changes the wrong monitor:** run `screen list` again and check the connector name used by your config.
- **Widgets are too large:** check for both output scaling and manual multiplication of widget dimensions.
- **Only one application is blurry:** check its backend and scaling settings before changing the whole output.
- **Scale resets after reload:** add the per-output setting to `rc.lua`.

## See Also

- [Screen Reference](../reference/screen.md)
- [Display Scaling](../concepts/display-scaling.md)
- [Multi-Monitor Setup](multi-monitor.md)
- [Theme Tutorial](../tutorials/theme.md)
