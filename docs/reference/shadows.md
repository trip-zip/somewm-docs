---
sidebar_position: 4
title: Shadows
description: Compositor-level shadow support for clients and wiboxes
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Shadows <SomewmOnly />

SomeWM provides built-in compositor-level shadows for windows and wiboxes. This replaces the need for external compositors like picom, which only work on X11.

Shadows are rendered using Cairo with a box blur approximation of Gaussian blur, displayed via the wlroots scene graph. They support full customization including color, blur radius, offset, and opacity.

:::note What gets shadows?
This feature applies to **clients** (application windows) and **drawins/wiboxes** (containers like panels and popups). Individual widgets inside a wibox do not get separate shadows. For widget-level shadow effects, use Lua/Cairo drawing techniques.
:::

## Theme Variables

Configure global shadow defaults in your `theme.lua`. Shadows are **disabled by default** and must be explicitly enabled.

### Client Shadow Variables

These control shadows for application windows (clients):

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `shadow_enabled` | boolean | `false` | Enable shadows globally for clients |
| `shadow_radius` | integer | `12` | Blur radius in pixels |
| `shadow_offset_x` | integer | `-15` | Horizontal offset (negative = left/behind window) |
| `shadow_offset_y` | integer | `-15` | Vertical offset (negative = up/behind window) |
| `shadow_opacity` | number | `0.75` | Shadow opacity (0.0 = invisible, 1.0 = solid) |
| `shadow_color` | string | `"#000000"` | Shadow color as hex string |

### Drawin/Wibox Shadow Variables

These control shadows for drawins and wiboxes (panels, popups, notifications). If not specified, they inherit from the client shadow settings.

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `shadow_drawin_enabled` | boolean | (inherits from `shadow_enabled`) | Enable shadows for drawins/wiboxes |
| `shadow_drawin_radius` | integer | (inherits from `shadow_radius`) | Blur radius for drawins |
| `shadow_drawin_offset_x` | integer | (inherits from `shadow_offset_x`) | Horizontal offset for drawins |
| `shadow_drawin_offset_y` | integer | (inherits from `shadow_offset_y`) | Vertical offset for drawins |
| `shadow_drawin_opacity` | number | (inherits from `shadow_opacity`) | Opacity for drawins |
| `shadow_drawin_color` | string | (inherits from `shadow_color`) | Color for drawins |

### Theme Example

```lua
-- In your theme.lua

-- Enable shadows for all windows
theme.shadow_enabled = true
theme.shadow_radius = 12
theme.shadow_offset_x = -15
theme.shadow_offset_y = -15
theme.shadow_opacity = 0.75
theme.shadow_color = "#000000"

-- Disable shadows for panels/wiboxes (optional)
theme.shadow_drawin_enabled = false
```

## Client Properties

### client.shadow

The `shadow` property controls shadows on individual clients.

**Type:** `boolean` or `table`

**Access:** Read/Write

When set to a boolean:
- `true` - Enable shadow using theme defaults
- `false` - Disable shadow for this client

When set to a table, you can override individual shadow parameters:

| Option | Type | Description |
|--------|------|-------------|
| `enabled` | boolean | Enable/disable shadow (default: `true` when table is provided) |
| `radius` | integer | Blur radius in pixels |
| `offset_x` | integer | Horizontal offset |
| `offset_y` | integer | Vertical offset |
| `opacity` | number | Shadow opacity (0.0-1.0) |
| `color` | string or table | Color as `"#RRGGBB"` string or `{r, g, b, a}` table (values 0.0-1.0) |

**Examples:**

```lua
-- Enable shadow with theme defaults
c.shadow = true

-- Disable shadow
c.shadow = false

-- Custom shadow configuration
c.shadow = {
    radius = 8,
    opacity = 0.5,
    color = "#FF0000"  -- Red shadow
}

-- Partial override (other values use theme defaults)
c.shadow = {
    offset_x = -25,
    offset_y = -25
}

-- Color as RGBA table
c.shadow = {
    color = {0.5, 0.0, 0.5, 1.0}  -- Purple
}
```

### Reading Shadow Configuration

When reading `client.shadow`, you receive:
- `false` if shadows are disabled
- A table with all current shadow settings if enabled

```lua
local s = c.shadow
if s then
    print("Shadow enabled with radius:", s.radius)
    print("Shadow color:", s.color)
else
    print("Shadow disabled")
end
```

## Drawin/Wibox Properties

### drawin.shadow

The `shadow` property on drawins and wiboxes works identically to the client shadow property.

**Type:** `boolean` or `table`

**Access:** Read/Write

**Examples:**

```lua
-- Wibox with shadow
local mywibox = wibox {
    width = 300,
    height = 50,
    visible = true,
    shadow = true
}

-- Popup with custom shadow
local popup = awful.popup {
    widget = mytextbox,
    shadow = {
        radius = 16,
        opacity = 0.8
    }
}

-- Notification-style glow effect
local notification_box = wibox {
    width = 400,
    height = 100,
    shadow = {
        color = "#3399FF",
        radius = 20,
        opacity = 0.6
    }
}
```

## Signals

### property::shadow

Emitted when the shadow property changes on a client or drawin.

```lua
client.connect_signal("property::shadow", function(c)
    if c.shadow then
        print(c.name .. " now has shadows enabled")
    end
end)
```

## Using Rules

Apply shadow settings automatically based on window properties:

```lua
ruled.client.append_rule {
    rule = { class = "mpv" },
    properties = { shadow = false }  -- No shadows on video players
}

ruled.client.append_rule {
    rule = { type = "dialog" },
    properties = {
        shadow = {
            radius = 8,
            opacity = 0.9
        }
    }
}

ruled.client.append_rule {
    rule = { class = "Rofi" },
    properties = {
        shadow = {
            color = "#5588FF",
            radius = 24,
            opacity = 0.5
        }
    }
}
```

## Dynamic Control

Use `somewm-client` to control shadows at runtime:

```bash
# Enable shadows on all clients
somewm-client eval 'for _, c in ipairs(client.get()) do c.shadow = true end'

# Set a specific color
somewm-client eval 'for _, c in ipairs(client.get()) do c.shadow = { color = "#888888" } end'

# Disable shadows
somewm-client eval 'for _, c in ipairs(client.get()) do c.shadow = false end'

# Fun: rainbow effect on focused client
somewm-client eval 'client.focus.shadow = { color = "#FF00FF", radius = 20, opacity = 0.8 }'
```

## Complete Example

A full theme.lua shadow configuration:

```lua
local theme = {}

-- ... other theme settings ...

-- Shadow configuration
theme.shadow_enabled = true
theme.shadow_radius = 14
theme.shadow_offset_x = -18
theme.shadow_offset_y = -18
theme.shadow_opacity = 0.7
theme.shadow_color = "#000000"

-- Wiboxes/panels: subtle shadows or none
theme.shadow_drawin_enabled = true
theme.shadow_drawin_radius = 8
theme.shadow_drawin_opacity = 0.4

return theme
```

Combined with rules in rc.lua:

```lua
-- Fullscreen windows don't need shadows
ruled.client.append_rule {
    rule_any = { fullscreen = true },
    properties = { shadow = false }
}

-- Floating windows get enhanced shadows
ruled.client.append_rule {
    rule_any = { floating = true },
    properties = {
        shadow = {
            radius = 20,
            offset_x = -20,
            offset_y = -20,
            opacity = 0.85
        }
    }
}
```

## Technical Notes

- Shadows are rendered using a 9-slice technique: 4 corners and 4 edges, allowing efficient resizing
- Shadow textures are cached based on radius, color, and opacity to avoid redundant rendering
- The blur is a 3-pass box blur approximation of Gaussian blur
- Shadow nodes are placed below content in the wlroots scene graph

## See Also

- [How-To: Shadows](/guides/shadows) - Practical guide for common shadow configurations
- [Theme Tutorial](/tutorials/theme) - Introduction to theming
- [Beautiful Theme Variables](/reference/beautiful/theme-variables) - All theme variables
