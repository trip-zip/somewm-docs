---
sidebar_position: 1
title: Input Device Configuration
description: Configure pointer and keyboard settings at runtime
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Input Device Configuration <SomewmOnly />

<span id="set-defaults-for-all-devices" />
<span id="give-different-devices-different-settings" />

<span id="overview" />

Set pointer and keyboard defaults through `awful.input` in `rc.lua`. Use per-device rules when a mouse and touchpad need different settings.

## Global Settings

```lua
local awful = require("awful")
awful.input.tap_to_click = 1
awful.input.natural_scrolling = 1
awful.input.accel_speed = 0.3
awful.input.xkb_layout = "us"
awful.input.xkb_options = "ctrl:nocaps"
awful.input.keyboard_repeat_rate = 30
awful.input.keyboard_repeat_delay = 300
```

For on/off pointer settings, `0` disables, `1` enables and `-1` leaves the current device setting unchanged. Acceleration speed instead ranges from `-1.0` to `1.0`. Keyboard repeat rate is in keys per second and delay is in milliseconds.

## Per-Device Configuration with Rules

<span id="targeting-a-specific-device" />
<span id="how-globals-and-rules-interact" />

```lua
awful.input.rules = {
    {
        rule = { type = "touchpad" },
        properties = { natural_scrolling = 1, tap_to_click = 1 },
    },
    {
        rule = { type = "pointer" },
        properties = { natural_scrolling = 0, accel_profile = "flat" },
    },
    {
        rule = { name = "Logitech G502" },
        properties = { accel_speed = -0.5 },
    },
}
```

`touchpad` matches devices that support tapping. `pointer` matches other pointing devices. `name` is a case-sensitive substring match. When a rule specifies both fields, both must match.

Global settings supply the baseline. Matching rules override individual properties in list order, with the last matching value winning. Assigning `awful.input.rules` replaces the entire rule list. Unsupported device features have no effect.

Find device names with:

```bash
libinput list-devices
```

This command may require permission to read input devices.

## All Properties

See the [input reference](../reference/awful/input.md) for settings such as scroll method, three-finger drag and button mapping. Three-finger drag requires a supporting libinput build and device.

## Cursor Theming {#cursor-theming}

<span id="use-a-different-cursor-per-context" />

### Setting the Cursor Theme

Set these variables in the environment that launches SomeWM:

```bash
export XCURSOR_THEME=Adwaita
export XCURSOR_SIZE=24
somewm
```

A display manager may not read your interactive shell's startup files. Use its session configuration or a launcher script in that case.

### Runtime Cursor Theme Changes <SomewmOnly />

```lua
root.cursor_theme("Adwaita")
root.cursor_size(32)
```

Query the current settings from a terminal:

```bash
somewm-client eval 'return root.cursor_theme(), root.cursor_size()'
```

Install the named cursor theme before selecting it. If cursors fail to load, check the compositor log and try an installed theme.

### Cursor APIs

Set the desktop cursor by name:

```lua
root.cursor("left_ptr")
```

For a panel, set its `cursor` property, such as `s.mywibox.cursor = "hand1"` after creating the wibar. Common names include `left_ptr`, `hand1`, `watch`, `xterm`, `fleur` and `crosshair`.

### Theme Variables

<span id="common-cursor-names" />
<span id="awesomewm-reference" />
<span id="next-steps" />

```lua
theme.cursor_mouse_move = "fleur"
theme.cursor_mouse_resize = "cross"
```

## See Also

- [Keyboard Layout Switching](keyboard-layouts.md)
- [Input Reference](../reference/awful/input.md)
- [CLI Control](cli-control.md)
- [AwesomeWM Cursor API](https://awesomewm.org/apidoc/core_components/root.html#cursor)
