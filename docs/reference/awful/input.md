---
sidebar_position: 2
title: awful.input
description: Runtime input device configuration
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# awful.input <SomewmOnly />

Runtime input device configuration for SomeWM. This API is unique to SomeWM and not available in AwesomeWM.

## Usage

```lua
local awful = require("awful")

-- Set properties
awful.input.tap_to_click = 1
awful.input.natural_scrolling = 1

-- Get properties
print(awful.input.accel_speed)
```

## Pointer Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `tap_to_click` | number (0/1) | 0 | Enable tap-to-click on touchpads |
| `natural_scrolling` | number (0/1) | 0 | Invert scroll direction (macOS-style) |
| `accel_speed` | number | 0.0 | Pointer acceleration (-1.0 to 1.0) |
| `scroll_button` | number | 0 | Button for scroll-on-button-down |
| `left_handed` | number (0/1) | 0 | Swap left/right mouse buttons |
| `middle_button_emulation` | number (0/1) | 0 | Emulate middle button with left+right |
| `scroll_method` | string | nil | Scroll method (see below) |
| `accel_profile` | string | nil | Acceleration profile (see below) |
| `tap_and_drag` | number (0/1) | 1 | Enable tap-and-drag |
| `drag_lock` | number (0/1) | 0 | Enable drag lock |
| `tap_3fg_drag` | number (0/1) | -1 | Three-finger drag (tap 3 fingers, drag with 1) |
| `disable_while_typing` | number (0/1) | 1 | Disable while typing |
| `dwtp` | number (0/1) | -1 | Disable touchpad while trackpoint in use (ThinkPad) |
| `scroll_button_lock` | number (0/1) | -1 | Scroll button toggle vs hold (1=toggle, 0=hold) |
| `clickfinger_button_map` | string | nil | Button map for clickfinger mode (see below) |
| `tap_button_map` | string | nil | Button map for tap-to-click mode (see below) |
| `click_method` | string | nil | Click method: `"none"`, `"button_areas"`, `"clickfinger"` |
| `send_events_mode` | string | nil | Send events mode: `"enabled"`, `"disabled"`, `"disabled_on_external_mouse"` |

For Boolean number arguments (0/1) a value of -1 means leave it untouched (i.e., at the device default).

### Button Maps

The `tap_button_map` and `clickfinger_button_map` settings control which mouse button is triggered by multi-finger taps/clicks:

| Value | 1 finger | 2 fingers | 3 fingers |
|-------|----------|-----------|-----------|
| `"lrm"` | Left | Right | Middle |
| `"lmr"` | Left | Middle | Right |

### Scroll Button

The `scroll_button` setting specifies which button activates scroll-on-button mode. Common values:

| Value | Button |
|-------|--------|
| 0 | Device default |
| 274 | Middle mouse button (common for TrackPoints) |
| 8 | Back/thumb button |

### Scroll Methods

| Value | Method |
|-------|--------|
| `nil` | Default (device-dependent) |
| `"two_finger"` | Two-finger scrolling |
| `"edge"` | Edge scrolling |
| `"button"` | Button scrolling |

### Acceleration Profiles

| Value | Profile |
|-------|---------|
| `"adaptive"` | Adaptive (accelerates with speed) |
| `"flat"` | Flat (constant speed) |

## Keyboard Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `xkb_layout` | string | "us" | Keyboard layout (e.g., "us", "de", "us,ru") |
| `xkb_variant` | string | "" | Layout variant (e.g., "dvorak", "colemak") |
| `xkb_options` | string | "" | XKB options (e.g., "ctrl:nocaps") |
| `numlock` | boolean | - | Toggle NumLock on/off |
| `keyboard_repeat_rate` | number | 25 | Key repeat rate (keys per second) |
| `keyboard_repeat_delay` | number | 600 | Delay before repeat starts (milliseconds) |

### Common XKB Options

| Option | Effect |
|--------|--------|
| `ctrl:nocaps` | Caps Lock acts as Ctrl |
| `ctrl:swapcaps` | Swap Caps Lock and Ctrl |
| `compose:ralt` | Right Alt is Compose key |
| `grp:alt_shift_toggle` | Alt+Shift switches layouts |
| `grp:win_space_toggle` | Super+Space switches layouts |

:::warning Wayland Limitation
`grp:*` toggle options do not automatically switch layouts on Wayland. Use explicit keybindings instead. See [Keyboard Layout Switching](/guides/keyboard-layouts) for workarounds.
:::

## Input Rules

Per-device input configuration using the same `{ rule, properties }` pattern as [client rules](/guides/client-rules). Rules let you apply different settings to different devices, for example enabling natural scrolling on your touchpad but not your mouse.

### How Rules Work

Each rule has a **condition** that matches devices and **properties** to apply. Rules are evaluated in order; later matches override earlier ones per property. Global `awful.input.*` settings act as defaults when no rule matches.

```lua
awful.input.rules = {
    { rule = { type = "touchpad" },
      properties = { natural_scrolling = 1, tap_to_click = 1 } },
    { rule = { type = "pointer" },
      properties = { natural_scrolling = 0, accel_profile = "flat" } },
}
```

### Rule Conditions

| Field | Type | Description |
|-------|------|-------------|
| `type` | string | Device type: `"touchpad"` or `"pointer"` (mice, trackballs, trackpoints) |
| `name` | string | Substring match against the device name (e.g., `"Logitech G502"`) |

Both fields are optional. Omitting a field matches all devices. When both are present, both must match.

### Finding Device Names

To see connected device names, use a Lua snippet:

```bash
somewm-client eval 'for _, d in ipairs(awesome._get_input_devices and awesome._get_input_devices() or {}) do print(d) end'
```

Or check your system's libinput device list:

```bash
libinput list-devices | grep "Device:"
```

### Rule Properties

Rules accept any [pointer property](#pointer-properties) listed above. Keyboard properties are not per-device and cannot be used in rules.

### Per-Device Override

Target a specific device by name:

```lua
awful.input.rules = {
    { rule = { type = "touchpad" },
      properties = { natural_scrolling = 1 } },
    { rule = { name = "Logitech G502" },
      properties = { accel_speed = -0.5, accel_profile = "flat" } },
}
```

### Precedence

1. Start with global defaults (`awful.input.*` properties)
2. Apply each matching rule in order
3. Last matching rule wins for any given property

```lua
-- Global default: natural scrolling on for everything
awful.input.natural_scrolling = 1

-- Override: turn it off for mice only
awful.input.rules = {
    { rule = { type = "pointer" },
      properties = { natural_scrolling = 0 } },
}
-- Result: touchpads get natural scrolling (global), mice don't (rule override)
```

### Clearing Rules

Set to `nil` to remove all rules and revert to global-only behavior:

```lua
awful.input.rules = nil
```

## Example Configuration

```lua
-- In rc.lua
local awful = require("awful")

-- Global defaults (apply to all devices unless overridden by rules)
awful.input.disable_while_typing = 1
awful.input.keyboard_repeat_rate = 30
awful.input.keyboard_repeat_delay = 300
awful.input.xkb_layout = "us"
awful.input.xkb_options = "ctrl:nocaps,compose:ralt"

-- Per-device rules
awful.input.rules = {
    { rule = { type = "touchpad" },
      properties = {
          natural_scrolling = 1,
          tap_to_click = 1,
          tap_3fg_drag = 1,
          accel_speed = 0.3,
          dwtp = 1,  -- Disable touchpad while using trackpoint (ThinkPad)
      } },
    { rule = { type = "pointer" },
      properties = {
          natural_scrolling = 0,
          accel_profile = "flat",
      } },
}
```

## See Also

- [Input Device Configuration Guide](/guides/input-devices)
- [Client Rules Guide](/guides/client-rules) - Same `{ rule, properties }` pattern for windows
- [somewm-client input commands](/reference/somewm-client)
