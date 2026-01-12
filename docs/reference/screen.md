---
sidebar_position: 2
title: screen
description: Screen (monitor/display) object reference
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# screen

The `screen` object represents a physical or virtual display. Each monitor connected to your system is a screen.

**Upstream documentation:** [AwesomeWM screen docs](https://awesomewm.org/apidoc/core_components/screen.html)

## Accessing Screens

```lua
-- Primary screen
local s = screen.primary

-- Currently focused screen
local s = awful.screen.focused()

-- Iterate all screens
for s in screen do
    print(s.index, s.geometry.width)
end

-- Get screen by index (1-based)
local s = screen[1]

-- Total screen count
local count = screen.count()
```

## Properties

### Geometry & Layout

| Property | Type | Access | Description |
|----------|------|--------|-------------|
| `geometry` | table | read | Screen bounds `{x, y, width, height}` in logical pixels |
| `workarea` | table | read | Usable area after panels/struts `{x, y, width, height}` |
| `index` | number | read | 1-based screen index |
| `padding` | table | read/write | Manual padding `{top, right, bottom, left}` |

### Output Information

| Property | Type | Access | Description |
|----------|------|--------|-------------|
| `outputs` | table | read | Physical output info (see below) |
| `name` | string | read/write | User-assignable screen name |

The `outputs` table is keyed by output name:

```lua
-- Example outputs table
{
    ["DP-1"] = {
        name = "DP-1",
        mm_width = 600,   -- Physical width in millimeters
        mm_height = 340,  -- Physical height in millimeters
        viewport_id = 1,
    }
}
```

### Scaling & DPI <SomewmOnly />

| Property | Type | Access | Description |
|----------|------|--------|-------------|
| `scale` | number | read/write | Output scale factor (0.1 to 10.0) |
| `dpi` | number | read | Screen DPI (computed from physical size) |
| `minimum_dpi` | number | read | Lowest DPI across outputs |
| `maximum_dpi` | number | read | Highest DPI across outputs |
| `preferred_dpi` | number | read | Recommended DPI for this screen |

```lua
-- Get current scale
print(screen.primary.scale)  -- e.g., 1.5

-- Set fractional scale for HiDPI display
screen.primary.scale = 1.5

-- Check DPI
print(screen.primary.dpi)  -- e.g., 144
```

When you change `scale`, the `geometry` and `workarea` update to reflect logical pixel dimensions. For example, a 3840x2160 display at scale 2.0 reports geometry of 1920x1080.

### Tags & Clients

| Property | Type | Access | Description |
|----------|------|--------|-------------|
| `tags` | table | read | All tags on this screen |
| `selected_tags` | table | read | Currently visible tags |
| `selected_tag` | tag | read | First selected tag (or nil) |
| `clients` | table | read | All clients on this screen |
| `tiled_clients` | table | read | Non-floating, non-minimized clients |

## Methods

### Screen Management

```lua
-- Get total screen count
local count = screen.count()

-- Get bounding geometry (respects workarea and padding)
local geo = s:get_bounding_geometry({
    honor_workarea = true,
    honor_padding = true,
})

-- Swap two screens' positions
screen[1]:swap(screen[2])
```

### Virtual Screens

```lua
-- Create a virtual screen
local fake = screen.fake_add(0, 0, 1920, 1080)

-- Resize a virtual screen
fake:fake_resize(0, 0, 2560, 1440)

-- Remove a virtual screen
fake:fake_remove()
```

## Signals

| Signal | Arguments | Description |
|--------|-----------|-------------|
| `added` | `s` | New screen connected |
| `removed` | `s` | Screen disconnected |
| `list` | (none) | Screen list changed |
| `primary_changed` | (none) | Primary screen changed |
| `property::geometry` | `s` | Screen geometry changed |
| `property::workarea` | `s` | Workarea changed (panel added/removed) |
| `property::scale` | `s` | Output scale changed <SomewmOnly /> |
| `property::outputs` | `s` | Output metadata changed |
| `property::index` | `s` | Screen index changed |

### Example: React to Scale Changes

```lua
screen.connect_signal("property::scale", function(s)
    -- Refresh widgets when scale changes
    print("Screen " .. s.index .. " scale is now " .. s.scale)
end)
```

### Example: Handle Monitor Hotplug

```lua
screen.connect_signal("added", function(s)
    -- Set up new monitor with appropriate scale
    if s.geometry.width > 3000 then
        s.scale = 1.5  -- 4K display
    end

    -- Create tags
    awful.tag({ "1", "2", "3" }, s, awful.layout.layouts[1])
end)
```

## Common Patterns

### Auto-Scale Based on Resolution

```lua
awful.screen.connect_for_each_screen(function(s)
    if s.geometry.width > 3000 then
        s.scale = 1.5
    elseif s.geometry.width > 2000 then
        s.scale = 1.25
    else
        s.scale = 1.0
    end
end)
```

### Get Screen Under Mouse

```lua
local s = awful.screen.focused()  -- Follows focus
-- or
local s = mouse.screen  -- Screen containing mouse pointer
```

### Find Screen by Output Name

```lua
for s in screen do
    for name, _ in pairs(s.outputs) do
        if name == "HDMI-A-1" then
            return s
        end
    end
end
```

## See Also

- [Fractional Scaling Guide](/guides/fractional-scaling) - Configure HiDPI displays
- [Multi-Monitor Setup](/guides/multi-monitor) - Per-screen configuration
- [Display Scaling Concepts](/concepts/display-scaling) - How scaling works
- [Object Model](/concepts/object-model) - How screens relate to tags and clients
