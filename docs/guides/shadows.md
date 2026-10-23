---
sidebar_position: 10
title: Shadows
description: Add compositor-level shadows to windows and wiboxes
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Shadows <SomewmOnly />

Enable compositor shadows in your theme, then override them for individual clients or wiboxes. These settings affect whole surfaces, not widgets inside them.

Shadows are drawn around the solved client or wibox frame without reserving layout space. `shadow_clip` and `clip_directional` are ignored in 2.1.

## Enabling Shadows

<span id="recipes" />

In `theme.lua`, before loading the theme:

```lua
theme.shadow_enabled = true
theme.shadow_radius = 12
theme.shadow_opacity = 0.6
theme.shadow_color = "#000000"
```

Reload the configuration to apply theme defaults. For all available settings and defaults, see the [shadow reference](../reference/shadows.md).

## Customizing Shadow Appearance

<span id="shape" />

| Setting | Effect |
| --- | --- |
| `shadow_radius` | Blur radius. Larger values soften the edge. |
| `shadow_opacity` | Opacity from `0` to `1`. |
| `shadow_offset_x`, `shadow_offset_y` | Position relative to the window. Positive values move right and down. |
| `shadow_spread` | Expansion beyond the surface edges before blurring. |
| `shadow_corner_radius` | Rounding of the shadow's corners. Does not round the window itself. |
| `shadow_color` | Hex colour. An alpha byte multiplies the opacity. |

For a downward shadow with rounded corners:

```lua
theme.shadow_offset_x = 0
theme.shadow_offset_y = 8
theme.shadow_spread = 4
theme.shadow_corner_radius = 16
```

For an even coloured glow, use zero offsets, a larger radius and a tinted colour:

```lua
theme.shadow_offset_x = 0
theme.shadow_offset_y = 0
theme.shadow_radius = 24
theme.shadow_color = "#3399FF"
theme.shadow_opacity = 0.5
```

## Different Settings for Panels vs Windows

Wibox defaults use the `shadow_drawin_` prefix:

```lua
theme.shadow_drawin_enabled = true
theme.shadow_drawin_radius = 6
theme.shadow_drawin_opacity = 0.3
```

Set `shadow_drawin_enabled = false` to disable default panel shadows while keeping client shadows.

## Disabling Shadows for Specific Windows

Put this in your existing client rules handler:

```lua
ruled.client.append_rule {
    rule_any = { class = { "^mpv$", "^vlc$" } },
    properties = { shadow = false },
}
```

Rules apply when a client is managed. To change shadows when a property such as `fullscreen` changes later, use a property signal handler.

## Per-Window Control

<span id="per-client-and-per-wibox" />

Set a client's `shadow` to `false`, `true` for theme defaults, or a settings table:

```lua
local c = client.focus
if c then
    c.shadow = {
        radius = 20,
        offset_x = 0,
        offset_y = 0,
        color = "#3399FF",
        opacity = 0.6,
    }
end
```

Assigning a table replaces the override. Omitted fields use the theme defaults.

Reading `c.shadow` returns a configuration table or `false`. Inspect `c.shadow.enabled` when testing whether a returned table enables the shadow. A disabled configuration table is still truthy in Lua.

## Adding Shadows to Wiboxes

```lua
local wibox = require("wibox")
local popup = wibox {
    width = 200,
    height = 50,
    visible = true,
    bg = "#222222",
    shadow = { radius = 10, opacity = 0.6, color = "#000000" },
}
```

For an existing wibar, assign the same table to `s.mywibox.shadow`, using your bar's actual variable name.

## Troubleshooting

Check that the theme loaded and no rule overrides `shadow`. To test the focused window directly:

```bash
somewm-client eval 'if client.focus then client.focus.shadow = true end'
```

Use hex colours such as `#000000` or `#FF000080`. Compare with shadows disabled when investigating rendering cost rather than assuming a fixed memory or performance cost.

## See Also

- [Shadow Reference](../reference/shadows.md)
- [Theme Tutorial](../tutorials/theme.md)
- [Client Rules](client-rules.md)
