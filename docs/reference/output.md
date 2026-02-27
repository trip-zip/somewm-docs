---
sidebar_position: 3
title: output
description: Output (physical monitor connector) object reference
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# output <SomewmOnly />

The `output` object represents a physical monitor connector. Unlike [screen](/reference/screen) objects (which are created and destroyed when outputs are enabled or disabled), output objects persist from the moment a monitor is plugged in until it is physically disconnected.

This is a SomeWM-only feature. AwesomeWM has no equivalent because X11 delegates monitor management to `xrandr`. On Wayland, the compositor owns the output lifecycle, so SomeWM exposes it directly.

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
| `mode` | table | write | Set resolution `{width, height, refresh?}` |
| `position` | table | read/write | Layout position `{x, y}` |
| `adaptive_sync` | boolean | read/write | Variable refresh rate (VRR/FreeSync) |

```lua
local o = output.get_by_name("eDP-1")

-- Scale a HiDPI laptop display
o.scale = 1.5

-- Rotate an external monitor
o.transform = "90"

-- Set resolution
o.mode = { width = 2560, height = 1440 }

-- Position right of another output
o.position = { x = 2560, y = 0 }

-- Disable an output
o.enabled = false
```

#### Transform Values

The `transform` property accepts both integers (Wayland protocol values) and strings:

| Integer | String | Effect |
|---------|--------|--------|
| 0 | `"normal"` | No transformation |
| 1 | `"90"` | 90 degrees clockwise |
| 2 | `"180"` | 180 degrees |
| 3 | `"270"` | 270 degrees clockwise |
| 4 | `"flipped"` | Horizontal flip |
| 5 | `"flipped-90"` | Flip + 90 degrees |
| 6 | `"flipped-180"` | Flip + 180 degrees |
| 7 | `"flipped-270"` | Flip + 270 degrees |

Reading `transform` always returns an integer. Setting it accepts either form.

### Mode Information

| Property | Type | Access | Description |
|----------|------|--------|-------------|
| `modes` | table | read | All supported modes |
| `current_mode` | table/nil | read | Active mode (nil if disabled) |

Each mode is a table: `{width, height, refresh, preferred}`.

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
| `virtual` | boolean | read | True for headless, nested, or fake screen outputs |

```lua
-- Navigate from output to screen and back
local o = output[1]
local s = o.screen           -- the screen for this output
assert(s.output == o)        -- bidirectional link
```

## Methods

### Class Methods

```lua
-- Count all connected outputs (enabled + disabled)
output.count()

-- Find output by connector name
output.get_by_name("HDMI-A-1")  -- returns output or nil

-- Numeric indexing
output[1]
output(2)

-- Iterate
for o in output do ... end
```

### Instance Methods

```lua
-- Connect to instance signals
o:connect_signal("property::scale", function() ... end)
o:disconnect_signal("property::scale", handler)
o:emit_signal("my-custom-signal")
```

## Signals

### Class Signals

| Signal | Arguments | Description |
|--------|-----------|-------------|
| `added` | `o` | New output connected. Fires after screen is ready, so `o.screen` is available. |
| `removed` | `o` | Output disconnected. Fires while output is still valid (properties readable). |

### Instance Signals

| Signal | Arguments | Description |
|--------|-----------|-------------|
| `property::enabled` | (none) | Output enabled or disabled |
| `property::scale` | (none) | Scale factor changed |
| `property::transform` | (none) | Rotation/flip changed |
| `property::mode` | (none) | Resolution changed |
| `property::position` | (none) | Layout position changed |
| `property::adaptive_sync` | (none) | VRR toggled |
| `property::screen` | (none) | Screen link changed (nil to screen, or screen to nil) |

Property signals fire regardless of how the change was made. If an external tool like `wlr-randr` or `kanshi` changes the output, the corresponding `property::*` signals still fire, keeping Lua in sync.

## Common Patterns

### Per-Output Configuration

The output object's persistence is its key feature. Because the same output object stays alive across enable/disable cycles, you can use it as a stable key for configuration:

```lua
local output_config = {}

output.connect_signal("added", function(o)
    -- Configure based on hardware
    if o.name:match("^eDP") then
        output_config[o] = { scale = 1.5, tags = {"1","2","3","4","5"} }
    elseif o.make == "Dell" then
        output_config[o] = { scale = 1.0, tags = {"web","code","docs"} }
    else
        output_config[o] = { scale = 1.0, tags = {"1","2","3"} }
    end

    -- Apply scale immediately
    o.scale = output_config[o].scale
end)

screen.connect_signal("request::desktop_decoration", function(s)
    local config = output_config[s.output]
    if config then
        awful.tag(config.tags, s, awful.layout.suit.tile)
    end
end)
```

### Identify Monitor Hardware

```lua
output.connect_signal("added", function(o)
    print("Connected: " .. o.name)
    print("  Make:   " .. (o.make or "unknown"))
    print("  Model:  " .. (o.model or "unknown"))
    print("  Serial: " .. (o.serial or "unknown"))
    print("  Size:   " .. o.physical_width .. "x" .. o.physical_height .. " mm")
end)
```

### React to External Tool Changes

```lua
-- Fires whether scale was set from Lua, wlr-randr, or kanshi
output[1]:connect_signal("property::scale", function()
    print("Scale changed to: " .. output[1].scale)
end)
```

### Detect Hotplug

```lua
output.connect_signal("added", function(o)
    -- o.screen is guaranteed to be available here
    print("Plugged in: " .. o.name .. " → screen " .. o.screen.index)
end)

output.connect_signal("removed", function(o)
    -- Output is still valid during this handler
    print("Unplugged: " .. o.name)
end)
```

### Track Screen Link Changes

```lua
output[1]:connect_signal("property::screen", function()
    local s = output[1].screen
    if s then
        print("Output now has screen " .. s.index)
    else
        print("Output has no screen (disabled)")
    end
end)
```

## See Also

- [screen Reference](/reference/screen) - The logical display object
- [Multi-Monitor Setup](/guides/multi-monitor) - Practical configuration patterns
- [The Object Model](/concepts/object-model) - How output relates to screen, tags, and clients
- [Display Scaling](/concepts/display-scaling) - How output scaling works
