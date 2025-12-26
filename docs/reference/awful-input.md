---
sidebar_position: 1
title: awful.input Reference
description: Complete reference for the awful.input module
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# awful.input Reference <SomewmOnly />

Runtime input device configuration for SomeWM.

<!-- TODO: Complete property documentation from lua/awful/input.lua -->

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
| `natural_scrolling` | number (0/1) | 0 | Invert scroll direction |
| `pointer_speed` | number | 0.0 | Pointer acceleration (-1.0 to 1.0) |
| `scroll_button` | number | 0 | Button for scroll-on-button-down |
| `left_handed` | number (0/1) | 0 | Swap left/right buttons |
| `middle_emulation` | number (0/1) | 0 | Emulate middle button |
| `scroll_method` | number | 0 | Scroll method (0=default, 1=two-finger, 2=edge, 3=button) |
| `accel_profile` | number | 0 | Acceleration profile (0=adaptive, 1=flat) |
| `drag` | number (0/1) | 1 | Enable tap-and-drag |
| `drag_lock` | number (0/1) | 0 | Enable drag lock |
| `dwt` | number (0/1) | 1 | Disable-while-typing |

## Keyboard Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `xkb_layout` | string | "us" | Keyboard layout (e.g., "us", "de", "us,ru") |
| `xkb_variant` | string | "" | Layout variant |
| `xkb_options` | string | "" | XKB options (e.g., "ctrl:nocaps") |
| `xkb_model` | string | "" | Keyboard model |
| `repeat_rate` | number | 25 | Key repeat rate (keys/second) |
| `repeat_delay` | number | 600 | Delay before repeat starts (ms) |

## Example Configuration

```lua
-- In rc.lua
local awful = require("awful")

-- Touchpad settings
awful.input.tap_to_click = 1
awful.input.natural_scrolling = 1
awful.input.pointer_speed = 0.3

-- Keyboard settings
awful.input.xkb_layout = "us"
awful.input.xkb_options = "ctrl:nocaps,compose:ralt"
awful.input.repeat_rate = 30
awful.input.repeat_delay = 300
```

## See Also

- [Input Device Configuration Guide](/guides/input-devices)
- [somewm-client input commands](/reference/somewm-client#input-commands)
