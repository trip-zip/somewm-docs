---
sidebar_position: 10
title: Shadows
description: Turn on compositor shadows from the theme, shape them with radius, offset, spread, corner radius and colour, give panels their own settings, and override per client or wibox with rules or the shadow property.
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Shadows <SomewmOnly />

SomeWM draws shadows itself; no picom. A shadow belongs to a client or a wibox, never to a widget inside one, and is drawn by the renderer around the solved frame without taking room from it. They are off until the theme turns them on:

```lua
theme.shadow_enabled = true
```

## Shape

| Variable | Effect |
| --- | --- |
| `shadow_radius` | blur; small is sharp, large is soft |
| `shadow_opacity` | 0 to 1 |
| `shadow_offset_x`, `shadow_offset_y` | where the shadow sits relative to the window. The parts under the window are hidden, so a large offset is a one-sided drop shadow and zero is an even halo. |
| `shadow_spread` | grows the shadow past the window's edges before the blur, so it peeks out on every side even with an offset |
| `shadow_corner_radius` | rounds the shadow's corners; match the window's |
| `shadow_color` | any colour; an alpha byte multiplies `shadow_opacity` |

The same names with `shadow_drawin_` apply to wiboxes, so panels can have lighter shadows or none:

```lua
theme.shadow_drawin_enabled = false      -- or radius 6, opacity 0.3
```

[Shadow reference](../reference/shadows.md) has the defaults.

## Per client and per wibox

`c.shadow` and `wibox.shadow` take `true` (theme defaults), `false`, or a table overriding any field:

```lua
ruled.client.append_rule { rule_any = { class = { "mpv", "vlc" } }, properties = { shadow = false } }
ruled.client.append_rule { rule_any = { fullscreen = true }, properties = { shadow = false } }
ruled.client.append_rule {
    rule_any = { floating = true },
    properties = { shadow = { radius = 24, offset_x = -20, offset_y = -20, opacity = 0.9 } },
}
ruled.client.append_rule {
    rule = { class = "Rofi" },
    properties = { shadow = { color = "#5599FF", radius = 30, opacity = 0.5 } },
}

awful.key({ modkey }, "s", function()
    if client.focus then client.focus.shadow = not client.focus.shadow end
end, { description = "toggle shadow", group = "client" })

s.mywibox.shadow = { radius = 12, offset_x = 0, offset_y = 4, opacity = 0.7 }
local popup = wibox { width = 200, height = 50, shadow = { radius = 10, opacity = 0.6, color = "#222222" } }
```

From a shell: `somewm-client eval 'for _, c in ipairs(client.get()) do c.shadow = { color = "#FF0000" } end'`.

## Recipes

| Look | Settings |
| --- | --- |
| classic drop shadow, light from the top left | `radius = 12, offset_x = 8, offset_y = 8, opacity = 0.6` |
| raised card | `radius = 16, offset_x = 0, offset_y = 8, spread = 4, corner_radius = 16, opacity = 0.6` |
| soft halo | `radius = 24, offset_x = 0, offset_y = 0, opacity = 0.5` |
| coloured glow, as a focus indicator in a `focus` handler | `color = "#3399FF", radius = 20, offset_x = 0, offset_y = 0, opacity = 0.6` |
| tight bevel | `radius = 4, offset_x = 3, offset_y = 3, opacity = 0.9` |

Each works as `theme.shadow_*` or as a `c.shadow` table.

If no shadow appears, `somewm-client eval 'client.focus.shadow = true'` tells you whether the theme or the client is the problem; a colour needs the `#` prefix. A shadow texture is a few kilobytes, so cost is not a concern; a smaller radius is the lever if it ever is.
