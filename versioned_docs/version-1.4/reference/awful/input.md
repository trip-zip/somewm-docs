---
sidebar_position: 2
title: awful.input
description: Runtime input device configuration
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# awful.input <SomewmOnly />

`awful.input` sets global keyboard and pointer settings. Device rules override individual pointer settings.

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
| `tap_to_click` | number (0/1) | -1 | Enable tap-to-click on touchpads |
| `natural_scrolling` | number (0/1) | -1 | Invert scroll direction (macOS-style) |
| `accel_speed` | number | 0.0 | Pointer acceleration (-1.0 to 1.0) |
| `scroll_button` | number | 0 | Button for scroll-on-button-down |
| `left_handed` | number (0/1) | -1 | Swap left/right mouse buttons |
| `middle_button_emulation` | number (0/1) | -1 | Emulate middle button with left+right |
| `scroll_method` | string | nil | Scroll method (see below) |
| `accel_profile` | string | nil | Acceleration profile (see below) |
| `tap_and_drag` | number (0/1) | -1 | Enable tap-and-drag |
| `drag_lock` | number (0/1) | -1 | Enable drag lock |
| `tap_3fg_drag` | number (0/1) | -1 | Three-finger drag (tap 3 fingers, drag with 1) |
| `disable_while_typing` | number (0/1) | -1 | Disable while typing |
| `dwtp` | number (0/1) | -1 | Disable touchpad while trackpoint in use (ThinkPad) |
| `scroll_button_lock` | number (0/1) | -1 | Scroll button toggle vs hold (1=toggle, 0=hold) |
| `clickfinger_button_map` | string | nil | Button map for clickfinger mode (see below) |
| `tap_button_map` | string | nil | Button map for tap-to-click mode (see below) |
| `click_method` | string | nil | Click method: `"none"`, `"button_areas"`, `"clickfinger"` |
| `send_events_mode` | string | nil | Send events mode: `"enabled"`, `"disabled"`, `"disabled_on_external_mouse"` |

The table lists initial `awful.input` values before configuration. For 0/1 settings, `-1` leaves the device setting untouched. It does not undo a value already applied. Unsupported settings depend on the device and installed libinput version.

### Button Maps

The `tap_button_map` and `clickfinger_button_map` settings control which mouse button is triggered by multi-finger taps/clicks:

| Value | 1 finger | 2 fingers | 3 fingers |
|-------|----------|-----------|-----------|
| `"lrm"` | Left | Right | Middle |
| `"lmr"` | Left | Middle | Right |

### Scroll Button

`scroll_button` uses Linux evdev button codes, not `awful.button` numbers:

| Value | Button |
|-------|--------|
| 0 | Do not override the scroll button |
| 274 | Middle mouse button (common for TrackPoints) |
| 275 | Side/thumb button (`BTN_SIDE`) |
| 278 | Back button (`BTN_BACK`) |

### Scroll Methods

| Value | Method |
|-------|--------|
| `nil` | Do not override the method |
| `"no_scroll"` | Disable scrolling |
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
| `xkb_layout` | string | "" | Keyboard layout (e.g., "us", "de", "us,ru") |
| `xkb_variant` | string | "" | Layout variant (e.g., "dvorak", "colemak") |
| `xkb_options` | string | "" | XKB options (e.g., "ctrl:nocaps") |
| `xkb_model` | string | "" | XKB model (e.g., "pc105") |
| `xkb_rules` | string | "" |  XKB rules (e.g., "base") |
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

:::warning Layout switching in 1.4
SomeWM 1.4 does not switch layout groups through `grp:*` options. Use explicit keybindings instead. See [Keyboard Layout Switching](/docs/1.4/guides/keyboard-layouts) for workarounds.
:::

## Input Rules

Per-device input configuration using the same `{ rule, properties }` pattern as [client rules](/docs/1.4/guides/client-rules). Rules let you apply different settings to different devices, for example enabling natural scrolling on your touchpad but not your mouse.

### How Rules Work

Each rule has a **condition** that matches devices and **properties** to apply. Rules are evaluated in order. Later matches override earlier ones per property. Properties absent from matching rules retain their global settings.

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
| `name` | string | Case-sensitive substring match against the device name (e.g., `"Logitech G502"`) |

Both fields are optional. An empty `rule` matches all pointer devices. When both fields are present, both must match.

### Finding Device Names

Device names are listed by:

```bash
libinput list-devices
```

### Rule Properties

Rules accept any [pointer property](#pointer-properties) listed above. Keyboard properties are not per-device and cannot be used in rules.

### Per-Device Override

```lua
awful.input.rules = {
    { rule = { type = "touchpad" },
      properties = { natural_scrolling = 1 } },
    { rule = { name = "Logitech G502" },
      properties = { accel_speed = -0.5, accel_profile = "flat" } },
}
```

### Precedence

Global settings apply first, followed by each matching rule. The last value specified for a property wins.

### Clearing Rules

Assigning `rules` reapplies settings to connected devices and affects newly connected devices. Set it to `nil` to remove all rules:

```lua
awful.input.rules = nil
```

## Example Configuration

See [Input devices](../../guides/input-devices.md) for a complete configuration and [Keyboard layouts](../../guides/keyboard-layouts.md) for layout switching and NumLock. `numlock` is not an `awful.input` property in 1.4.

## See Also

- [Input Device Configuration Guide](/docs/1.4/guides/input-devices)
- [Client Rules Guide](/docs/1.4/guides/client-rules) - Same `{ rule, properties }` pattern for windows
- [somewm-client input commands](/docs/1.4/reference/somewm-client)
