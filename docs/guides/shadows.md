---
sidebar_position: 10
title: Shadows
description: Add compositor-level shadows to windows and wiboxes
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Shadows <SomewmOnly />

SomeWM includes built-in shadow support, eliminating the need for external compositors like picom. This guide shows you how to enable and customize shadows.

:::note
Shadows apply to **clients** (windows) and **wiboxes** (containers), not individual widgets inside a wibox. For widget-level effects, use Lua/Cairo drawing.
:::

## Enabling Shadows

Add these lines to your `theme.lua`:

```lua
theme.shadow_enabled = true
```

That's it! All windows now have shadows with sensible defaults (12px blur radius, 75% opacity, black color).

## Customizing Shadow Appearance

### Soft, Diffuse Shadows

For a gentle, modern look:

```lua
theme.shadow_enabled = true
theme.shadow_radius = 20      -- Larger blur = softer
theme.shadow_opacity = 0.5    -- More transparent
theme.shadow_offset_x = -25   -- Spread further
theme.shadow_offset_y = -25
```

### Sharp, Defined Shadows

For a more dramatic effect:

```lua
theme.shadow_enabled = true
theme.shadow_radius = 6       -- Small blur = sharp edges
theme.shadow_opacity = 0.9    -- Nearly solid
theme.shadow_offset_x = -8
theme.shadow_offset_y = -8
```

### Adjusting Shadow Position

The offset values control where the shadow appears relative to the window:

- **Negative values** place the shadow behind/above the window (typical)
- **Positive values** place the shadow in front/below (unusual, but can create interesting effects)

```lua
-- Shadow directly behind (centered)
theme.shadow_offset_x = 0
theme.shadow_offset_y = 0

-- Shadow to the bottom-right (light source top-left)
theme.shadow_offset_x = 10
theme.shadow_offset_y = 10
```

By default, shadows are clipped to only appear on the offset side (`shadow_clip = true`). This prevents shadows from showing on both sides of the window. To show a full shadow on all sides, disable clipping:

```lua
theme.shadow_clip = false
```

Or control it per-window:

```lua
c.shadow = {
    offset_x = -15,
    offset_y = -15,
    clip_directional = false  -- Show shadow on all sides
}
```

## Using Colored Shadows

Shadows don't have to be black! Create glow effects or match your color scheme:

```lua
-- Subtle blue tint
theme.shadow_color = "#1a1a2e"

-- Cyan glow
theme.shadow_color = "#00FFFF"
theme.shadow_opacity = 0.4
theme.shadow_radius = 24

-- Warm amber
theme.shadow_color = "#FFB347"
```

### Dynamic Color Effects

Change shadow colors at runtime using `somewm-client`:

```bash
# Red alert mode
somewm-client eval 'for _, c in ipairs(client.get()) do c.shadow = { color = "#FF0000" } end'

# Calm blue
somewm-client eval 'for _, c in ipairs(client.get()) do c.shadow = { color = "#4488FF" } end'

# Purple haze
somewm-client eval 'for _, c in ipairs(client.get()) do c.shadow = { color = "#8800FF" } end'

# Back to black
somewm-client eval 'for _, c in ipairs(client.get()) do c.shadow = { color = "#000000" } end'
```

## Different Settings for Panels vs Windows

You might want shadows on application windows but not on your wibar or other panels:

```lua
-- Enable shadows for windows
theme.shadow_enabled = true
theme.shadow_radius = 14
theme.shadow_opacity = 0.7

-- Disable shadows for panels/wiboxes
theme.shadow_drawin_enabled = false
```

Or use subtler shadows for panels:

```lua
-- Windows get full shadows
theme.shadow_enabled = true
theme.shadow_radius = 16
theme.shadow_opacity = 0.8

-- Panels get lighter shadows
theme.shadow_drawin_enabled = true
theme.shadow_drawin_radius = 6
theme.shadow_drawin_opacity = 0.3
```

## Disabling Shadows for Specific Windows

Use rules to control shadows per-application:

```lua
-- No shadows on video players (might interfere with viewing)
ruled.client.append_rule {
    rule = { class = "mpv" },
    properties = { shadow = false }
}

ruled.client.append_rule {
    rule = { class = "vlc" },
    properties = { shadow = false }
}

-- No shadows on fullscreen windows
ruled.client.append_rule {
    rule_any = { fullscreen = true },
    properties = { shadow = false }
}
```

### Enhanced Shadows for Floating Windows

Make floating windows stand out:

```lua
ruled.client.append_rule {
    rule_any = { floating = true },
    properties = {
        shadow = {
            radius = 24,
            offset_x = -20,
            offset_y = -20,
            opacity = 0.9
        }
    }
}
```

### Special Effects for Launchers

Give your application launcher a glow:

```lua
ruled.client.append_rule {
    rule = { class = "Rofi" },
    properties = {
        shadow = {
            color = "#5599FF",
            radius = 30,
            opacity = 0.5
        }
    }
}
```

## Per-Window Control

Toggle shadows on individual windows programmatically:

```lua
-- In a keybinding
awful.key({ modkey }, "s", function()
    local c = client.focus
    if c then
        c.shadow = not c.shadow
    end
end, {description = "toggle shadow", group = "client"})
```

Or create custom shadow presets:

```lua
local shadow_presets = {
    none = false,
    subtle = { radius = 8, opacity = 0.4 },
    normal = { radius = 12, opacity = 0.7 },
    dramatic = { radius = 24, opacity = 0.9 },
    glow = { radius = 20, opacity = 0.5, color = "#00AAFF" }
}

-- Cycle through presets
local current_preset = 1
local preset_names = {"none", "subtle", "normal", "dramatic", "glow"}

awful.key({ modkey, "Shift" }, "s", function()
    local c = client.focus
    if c then
        current_preset = current_preset % #preset_names + 1
        c.shadow = shadow_presets[preset_names[current_preset]]
        naughty.notify { text = "Shadow: " .. preset_names[current_preset] }
    end
end, {description = "cycle shadow presets", group = "client"})
```

## Adding Shadows to Wiboxes

Create wiboxes with shadows:

```lua
local mybox = wibox {
    width = 300,
    height = 100,
    visible = true,
    shadow = true  -- Uses theme defaults
}

-- Or with custom settings
local popup = wibox {
    width = 200,
    height = 50,
    shadow = {
        radius = 10,
        opacity = 0.6,
        color = "#222222"
    }
}
```

## Shadow Recipes

Tested configurations you can copy directly into your setup.

### Classic Drop Shadow

A traditional shadow cast to the bottom-right, as if the light source is at the top-left:

```lua
-- In theme.lua
theme.shadow_enabled = true
theme.shadow_radius = 12
theme.shadow_offset_x = 8
theme.shadow_offset_y = 8
theme.shadow_opacity = 0.6

-- Or per-window
c.shadow = {
    radius = 12,
    offset_x = 8,
    offset_y = 8,
    opacity = 0.6,
    clip_directional = true
}
```

### Soft Halo

An even glow on all sides, giving windows a floating appearance:

```lua
-- In theme.lua
theme.shadow_enabled = true
theme.shadow_radius = 24
theme.shadow_offset_x = 0
theme.shadow_offset_y = 0
theme.shadow_opacity = 0.5
theme.shadow_clip = false

-- Or per-window
c.shadow = {
    radius = 24,
    offset_x = 0,
    offset_y = 0,
    opacity = 0.5,
    clip_directional = false
}
```

### Colored Glow

A blue neon glow surrounding the window. Works well as a focused-window indicator:

```lua
-- Per-window (e.g., in a focus signal handler)
c.shadow = {
    color = "#3399FF",
    radius = 20,
    offset_x = 0,
    offset_y = 0,
    opacity = 0.6,
    clip_directional = false
}
```

### Tight, Sharp Shadow

A small, crisp shadow for a subtle beveled look:

```lua
-- In theme.lua
theme.shadow_enabled = true
theme.shadow_radius = 4
theme.shadow_offset_x = 3
theme.shadow_offset_y = 3
theme.shadow_opacity = 0.9

-- Or per-window
c.shadow = {
    radius = 4,
    offset_x = 3,
    offset_y = 3,
    opacity = 0.9,
    clip_directional = true
}
```

### Wibar Panel Shadow

A downward shadow on the top panel, making it float above the desktop:

```lua
-- In rc.lua, after creating the wibar
s.mywibox.shadow = {
    radius = 12,
    offset_x = 0,
    offset_y = 4,
    opacity = 0.7,
    clip_directional = true
}
```

## Troubleshooting

### Shadows not appearing

1. Check that `theme.shadow_enabled = true` is in your theme
2. Verify your theme is loading correctly (check for errors on startup)
3. Try enabling shadows directly: `somewm-client eval 'client.focus.shadow = true'`

### Shadows appear but wrong color

Make sure you're using hex color format with the `#` prefix:

```lua
-- Correct
theme.shadow_color = "#FF0000"

-- Wrong (won't work)
theme.shadow_color = "FF0000"
theme.shadow_color = "red"
```

### Performance concerns

Shadow textures are tiny (~2.5KB per shadow), so performance impact is minimal. If you notice any issues:
- Reduce `shadow_radius` (smaller blur = fewer pixels)
- Lower the number of windows with unique shadow configurations

## See Also

- [Shadow Reference](/reference/shadows) - Complete API documentation
- [Theme Tutorial](/tutorials/theme) - Introduction to theming
- [Client Rules](/tutorials/basics) - How to set up client rules
