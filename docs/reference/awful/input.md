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
print(awful.input.pointer_speed)
```

## Pointer Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `tap_to_click` | number (0/1) | 0 | Enable tap-to-click on touchpads |
| `natural_scrolling` | number (0/1) | 0 | Invert scroll direction (macOS-style) |
| `pointer_speed` | number | 0.0 | Pointer acceleration (-1.0 to 1.0) |
| `scroll_button` | number | 0 | Button for scroll-on-button-down |
| `left_handed` | number (0/1) | 0 | Swap left/right mouse buttons |
| `middle_emulation` | number (0/1) | 0 | Emulate middle button with left+right |
| `scroll_method` | number | 0 | Scroll method (see below) |
| `accel_profile` | number | 0 | Acceleration profile (see below) |
| `drag` | number (0/1) | 1 | Enable tap-and-drag |
| `drag_lock` | number (0/1) | 0 | Enable drag lock |
| `tap_3fg_drag` | number (0/1) | -1 | Three-finger drag (tap 3 fingers, drag with 1) |
| `disable_while_typing` | number (0/1) | 1 | Disable while typing |
| `dwtp` | number (0/1) | -1 | Disable touchpad while trackpoint in use (ThinkPad) |
| `scroll_button_lock` | number (0/1) | -1 | Scroll button toggle vs hold (1=toggle, 0=hold) |
| `clickfinger_button_map` | string | nil | Button map for clickfinger mode (see below) |
| `tap_button_map` | string | nil | Button map for tap-to-click mode (see below) |

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
| 0 | Default (device-dependent) |
| 1 | Two-finger scrolling |
| 2 | Edge scrolling |
| 3 | Button scrolling |

### Acceleration Profiles

| Value | Profile |
|-------|---------|
| 0 | Adaptive (accelerates with speed) |
| 1 | Flat (constant speed) |

## Keyboard Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `xkb_layout` | string | "us" | Keyboard layout (e.g., "us", "de", "us,ru") |
| `xkb_variant` | string | "" | Layout variant (e.g., "dvorak", "colemak") |
| `xkb_options` | string | "" | XKB options (e.g., "ctrl:nocaps") |
| `xkb_model` | string | "" | Keyboard model |
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

## Example Configuration

```lua
-- In rc.lua
local awful = require("awful")

-- Touchpad settings
awful.input.tap_to_click = 1
awful.input.natural_scrolling = 1
awful.input.pointer_speed = 0.3
awful.input.tap_3fg_drag = 1  -- Three-finger drag
awful.input.disable_while_typing = 1   -- Disable touchpad while typing
awful.input.dwtp = 1  -- Disable touchpad while using trackpoint (ThinkPad)

-- Keyboard settings
awful.input.xkb_layout = "us"
awful.input.xkb_options = "ctrl:nocaps,compose:ralt"
awful.input.keyboard_repeat_rate = 30
awful.input.keyboard_repeat_delay = 300
```

## See Also

- [Input Device Configuration Guide](/guides/input-devices)
- [somewm-client input commands](/reference/somewm-client)
