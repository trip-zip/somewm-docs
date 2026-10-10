---
sidebar_position: 7
title: Fractional Scaling
description: Set screen.scale per screen from rc.lua or somewm-client, keep the theme DPI-aware, and handle apps that render blurry at a fractional scale.
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Fractional Scaling <SomewmOnly />

`screen.scale` is a writable property, any value above 0; [Display Scaling](/docs/concepts/display-scaling) explains what it does.

| Panel | Scale |
| --- | --- |
| 1080p or 1440p at 24 to 27 inches | 1.0, 1440p up to 1.25 |
| 4K at 27 inches | 1.5 to 2.0 |
| 4K at 32 inches | 1.25 to 1.5 |
| 2880x1800 laptop | 1.5 to 2.0 |

```lua
awful.screen.connect_for_each_screen(function(s)
    s.scale = s.geometry.width > 3000 and 1.5 or s.geometry.width > 2000 and 1.25 or 1.0
end)

awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, "equal", function() local s = awful.screen.focused(); s.scale = s.scale + 0.25 end,
        { description = "increase scale", group = "screen" }),
    awful.key({ modkey }, "minus", function() local s = awful.screen.focused(); s.scale = math.max(0.5, s.scale - 0.25) end,
        { description = "decrease scale", group = "screen" }),
})
```

`connect_for_each_screen` also covers a monitor plugged in later. To set the scale before the screen exists, use the output's `added` signal ([Multi-Monitor](./multi-monitor.md#configure-by-output)).

```bash
somewm-client screen scale          # read
somewm-client screen scale 1.5      # the focused screen
somewm-client screen scale 2 1.0    # screen 2
```

After a change, `s.geometry` reports the new logical size and `s.workarea` follows.

## Theme sizes

Every size in `theme.lua` goes through `dpi()`:

```lua
local dpi = require("beautiful.xresources").apply_dpi
theme.useless_gap = dpi(4)
theme.border_width = dpi(2)
theme.wibar_height = dpi(24)
theme.notification_width = dpi(300)
theme.menu_height = dpi(20)
```

A bare number stays that many logical pixels at every DPI, which is the usual reason widgets look wrong after a scale change.

## Blurry apps

| App | Fix |
| --- | --- |
| XWayland | integer scale only; `GDK_SCALE=2` or `QT_SCALE_FACTOR=1.5` per app, or a Wayland-native build |
| GTK3 | `GDK_BACKEND=wayland` in the environment; renders at the next integer and is downscaled |
| Qt | `QT_QPA_PLATFORM=wayland`, `QT_SCALE_FACTOR=1.5` |
| Electron | `ELECTRON_OZONE_PLATFORM_HINT=wayland` |

GTK4 and Qt6 apps support `wp_fractional_scale_v1` and are crisp at any scale. `for s in screen do print(s.index, s.scale) end` shows which screen got which scale when one looks wrong.
