---
sidebar_position: 3
title: output
description: Output (physical monitor connector) object reference
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# output <SomewmOnly />

An `output` represents a connected monitor or a nested/headless display. It persists across disable/enable cycles until the output is removed. Its [screen](screen.md) exists only while enabled.

## Output vs Screen

| | output | screen |
|---|--------|--------|
| **Represents** | Physical connector (HDMI-A-1, DP-2, eDP-1) | Logical display area |
| **Lifecycle** | Plug to unplug | Enable to disable |
| **Persists across disable/enable** | Yes | No (destroyed and recreated) |
| **Use for** | Hardware identification, display configuration | Tags, clients, wibars |

A single output can have zero or one screen. When the output is enabled, `output.screen` points to the active screen. When disabled, `output.screen` is nil but the output object remains valid.

## Accessing Outputs

```lua
-- Get output by index (1-based)
local o = output[1]

-- Get output by connector name
local o = output.get_by_name("HDMI-A-1")

-- Total output count (enabled + disabled)
local count = output.count()

-- Iterate all outputs
for o in output do
    print(o.name, o.enabled)
end

-- From a screen
local o = screen.primary.output
```

## Properties

### Hardware Identification

| Property | Type | Access | Description |
|----------|------|--------|-------------|
| `name` | string | read | Connector name (e.g., "HDMI-A-1", "eDP-1") |
| `description` | string/nil | read | Human-readable description from EDID |
| `make` | string/nil | read | Manufacturer name from EDID |
| `model` | string/nil | read | Model name from EDID |
| `serial` | string/nil | read | Serial number from EDID |
| `physical_width` | number | read | Physical width in millimeters |
| `physical_height` | number | read | Physical height in millimeters |

```lua
local o = output[1]
print(o.name)            -- "HDMI-A-1"
print(o.make)            -- "Dell" or nil
print(o.model)           -- "U2723QE" or nil
print(o.serial)          -- "ABC1234" or nil
print(o.physical_width)  -- 597 (mm)
```

### Display State

| Property | Type | Access | Description |
|----------|------|--------|-------------|
| `enabled` | boolean | read/write | Whether the output is active |
| `scale` | number | read/write | Output scale factor (0.1 to 10.0) |
| `transform` | number/string | read/write | Rotation/flip (see values below) |
| `mode` | table | write | Set `{width, height, refresh?}`. Refresh is in millihertz. Read `current_mode` to inspect it |
| `position` | table | read/write | Layout position `{x, y}` |
| `adaptive_sync` | boolean | read/write | Variable refresh rate (VRR/FreeSync) |

```lua
local o = output[1]
o.scale = 1.5
```

Mode, transform, and adaptive-sync changes depend on backend and monitor support. A failed commit raises a Lua error.

#### Transform Values

The `transform` property accepts both integers (Wayland protocol values) and strings:

| Integer | String | Effect |
|---------|--------|--------|
| 0 | `"normal"` | No transformation |
| 1 | `"90"` | 90 degrees counter-clockwise |
| 2 | `"180"` | 180 degrees |
| 3 | `"270"` | 270 degrees counter-clockwise |
| 4 | `"flipped"` | Horizontal flip |
| 5 | `"flipped-90"` | Flip + 90 degrees |
| 6 | `"flipped-180"` | Flip + 180 degrees |
| 7 | `"flipped-270"` | Flip + 270 degrees |

Reading `transform` always returns an integer. Setting it accepts either form.

### Mode Information

| Property | Type | Access | Description |
|----------|------|--------|-------------|
| `modes` | table | read | All supported modes |
| `current_mode` | table/nil | read | Active advertised mode. Nil if disabled or using a custom mode, including many nested/headless outputs |

Each mode is `{width, height, refresh, preferred}`. Width and height are physical pixels. Refresh is millihertz, so `60000` means 60 Hz. Setting a mode requires a listed resolution. An omitted or zero refresh selects the first matching resolution, otherwise the closest listed refresh is used.

```lua
-- List all supported modes
for _, m in ipairs(o.modes) do
    local flag = m.preferred and " (preferred)" or ""
    print(m.width .. "x" .. m.height .. "@" .. m.refresh .. flag)
end

-- Current active mode
local m = o.current_mode
if m then
    print("Running at " .. m.width .. "x" .. m.height)
end
```

### Object References

| Property | Type | Access | Description |
|----------|------|--------|-------------|
| `screen` | screen/nil | read | Associated screen (nil when disabled) |
| `valid` | boolean | read | False after physical disconnect |
| `virtual` | boolean | read | True for headless or nested outputs |

```lua
-- Navigate from output to screen and back
local o = output[1]
local s = o.screen           -- the screen for this output
if s then assert(s.output == o) end
```

After removal, only `o.valid` remains readable. Other property access raises `invalid object`.

## Methods

### Class Methods

```lua
-- Count all connected outputs (enabled + disabled)
output.count()

-- Find output by connector name
output.get_by_name("HDMI-A-1")  -- returns output or nil

-- Numeric indexing
local first = output[1]
local second = output(2)

-- Iterate
for o in output do print(o.name) end
```

### Instance Methods

```lua
-- Connect to instance signals
local handler = function(o) print(o.scale) end
o:connect_signal("property::scale", handler)
o:disconnect_signal("property::scale", handler)
o:emit_signal("my-custom-signal")
```

## Signals

### Class Signals

| Signal | Arguments | Description |
|--------|-----------|-------------|
| `added` | `o` | Output connected, after initial screen setup. `o.screen` is nil if disabled |
| `removed` | `o` | Output disconnected. Fires while output is still valid (properties readable). |

### Instance Signals

| Signal | Arguments | Description |
|--------|-----------|-------------|
| `property::enabled` | `o` | Output enabled or disabled |
| `property::scale` | `o` | Scale factor changed |
| `property::transform` | `o` | Rotation/flip changed |
| `property::mode` | `o` | Resolution changed |
| `property::position` | `o` | Layout position changed |
| `property::adaptive_sync` | `o` | VRR toggled |
| `property::screen` | `o` | Screen link changed (nil to screen, or screen to nil) |

Compositor and external output-management changes queue property signals. Lua setters generally deliver them inline. See [signal dispatch](signals.md#dispatch) for exceptions.

Output-management changes made by tools such as `wlr-randr` also emit property signals. Connecting a class `added` handler immediately calls it for existing outputs as well as future ones.

## Common Patterns

### Per-Output Configuration

See [Multi-monitor setup](../guides/multi-monitor.md) for connector-specific scale, position, tags, and wibars. `request::desktop_decoration` can run before `output.added`, so tag creation must not depend on data first populated in `added`.

### Identify Monitor Hardware

```lua
for o in output do
    print(o.name, o.make, o.model, o.serial)
end
```

### React to External Tool Changes

```lua
output[1]:connect_signal("property::scale", function(o)
    print(o.name, o.scale)
end)
```

### Detect Hotplug

```lua
output.connect_signal("added", function(o)
    print("Available:", o.name, o.screen and o.screen.index)
end)

output.connect_signal("removed", function(o)
    print("Removed:", o.name)
end)
```

### Track Screen Link Changes

```lua
output[1]:connect_signal("property::screen", function(o)
    print(o.name, o.screen and o.screen.index)
end)
```

## See Also

- [screen Reference](/docs/2.0/reference/screen) - The logical display object
- [Multi-Monitor Setup](/docs/2.0/guides/multi-monitor) - Practical configuration patterns
- [The Object Model](/docs/2.0/concepts/object-model) - How output relates to screen, tags, and clients
- [Display Scaling](/docs/2.0/concepts/display-scaling) - How output scaling works
