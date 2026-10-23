---
sidebar_position: 2
title: screen
description: Screen (monitor/display) object reference
---

import SomewmOnly from '@site/src/components/SomewmOnly';
import FromAwesomeWM from '@site/src/components/FromAwesomeWM';

# screen

<FromAwesomeWM upstream="core_components/screen" lastSynced="2026-05-11" />

A `screen` is a logical display area with tags, clients, and wibars. Enabling an output creates its screen. Disabling it removes that screen.

## Deviations from AwesomeWM

SomeWM adds output scaling and an `output` link. DPI properties come from AwesomeWM’s `awful.screen` API.

| API | SomeWM behavior | Why |
|-----|-----------------|-----|
| `screen.scale` <SomewmOnly /> | Read/write fractional scale (0.1–10.0). | Sets the Wayland output scale. |
| `screen.output` <SomewmOnly /> | Associated output object. | Configure the connector independently of the screen’s lifetime. |
| `property::scale` signal <SomewmOnly /> | Fires when an output scale changes. | Driven by user or `somewm-client screen scale`. |

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
| `output` <SomewmOnly /> | output/nil | read | Associated output object |
| `content` <SomewmOnly /> | image | read | Captured screen content, used by `awful.screenshot` |
| `name` | string | read/write | User-assignable screen name |

In 1.4, `outputs` is an array, unlike AwesomeWM’s name-keyed table:

```lua
-- Example outputs table
local outputs = {
    [1] = {
        name = "DP-1",
        mm_width = 600,   -- Physical width in millimeters
        mm_height = 340,  -- Physical height in millimeters
        viewport_id = 1,
    }
}
```

### Scaling & DPI

| Property | Type | Access | Description |
|----------|------|--------|-------------|
| `scale` <SomewmOnly /> | number | read/write | Output scale factor (0.1 to 10.0) |
| `dpi` | number | read/write | DPI used by Lua widgets. Can be overridden independently of output scale |
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
| `tiled_clients` | table | read | Visible clients excluding floating, fullscreen, and maximized clients |

## Methods

### Screen Management

```lua
-- Get total screen count
local count = screen.count()

-- Get the workarea
local geo = s:get_bounding_geometry({
    honor_workarea = true,
})

-- Swap two screen indices, if a second screen exists
if screen[2] then screen[1]:swap(screen[2]) end
```

In 1.4, `s:get_bounding_geometry()` honours `honor_workarea` but ignores `honor_padding` and `margins`. It also ignores `tag`, `parent`, and `bounding_rect`, unlike the upstream Lua helper.

### Virtual Screens

`screen.fake_add()` creates a Lua screen object and emits `added`, but it does not create a monitor-backed layout area in 1.4. Clients moved there are hidden and wibars cannot attach to it. It cannot split a monitor into working virtual screens.

| Method | Result |
| --- | --- |
| `screen.fake_add(x, y, width, height)` | Create and return a screen object |
| `s:fake_resize(x, y, width, height)` | Change its geometry |
| `s:fake_remove()` | Remove it |

These methods create no output or monitor. Use a nested compositor to test code that creates fake screens.

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
    print("Screen " .. s.index .. " scale is now " .. s.scale)
end)
```

### Example: Handle Monitor Hotplug

Use [multi-monitor configuration](../guides/multi-monitor.md) to create tags and bars in `request::desktop_decoration`. Adding a second tag-creation handler to the default config creates duplicate tags.

## Common Patterns

### Auto-Scale Based on Resolution

`screen.geometry` is already scaled. For automatic scaling, use output modes or connector names as described in [fractional scaling](../guides/fractional-scaling.md).

### Get Screen Under Mouse

```lua
local s = mouse.screen
```

### Find Screen by Output Name

```lua
local o = output.get_by_name("HDMI-A-1")
local s = o and o.screen
```

## See Also

- [Fractional Scaling Guide](/docs/1.4/guides/fractional-scaling) - Configure HiDPI displays
- [Multi-Monitor Setup](/docs/1.4/guides/multi-monitor) - Per-screen configuration
- [Tag Persistence](/docs/1.4/concepts/tag-persistence) - How tags survive monitor hotplug
- [Display Scaling Concepts](/docs/1.4/concepts/display-scaling) - How scaling works
- [Object Model](/docs/1.4/concepts/object-model) - How screens relate to tags and clients
