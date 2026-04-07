---
sidebar_position: 1
title: Input Device Configuration
description: Configure pointer and keyboard settings at runtime
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Input Device Configuration <SomewmOnly />

## Overview

SomeWM provides `awful.input` for runtime input device configuration, a feature not available in AwesomeWM. You can set global defaults that apply to all devices, and use rules to configure specific device types or individual devices differently.

## Global Settings

Global settings apply to all connected devices. Set them directly on `awful.input`:

```lua
local awful = require("awful")

-- Touchpad settings
awful.input.tap_to_click = 1
awful.input.natural_scrolling = 1
awful.input.accel_speed = 0.3

-- Keyboard settings
awful.input.xkb_layout = "us"
awful.input.xkb_options = "ctrl:nocaps"
awful.input.keyboard_repeat_rate = 30
awful.input.keyboard_repeat_delay = 300
```

A value of `-1` means "leave at device default." A value of `0` disables the feature, `1` enables it.

## Per-Device Configuration with Rules

If you use both a touchpad and an external mouse, you probably want different settings for each. Input rules let you do this using the same `{ rule, properties }` pattern as [client rules](/guides/client-rules):

```lua
awful.input.rules = {
    { rule = { type = "touchpad" },
      properties = {
          natural_scrolling = 1,
          tap_to_click = 1,
          tap_3fg_drag = 1,
      } },
    { rule = { type = "pointer" },
      properties = {
          natural_scrolling = 0,
          accel_profile = "flat",
      } },
}
```

Two device types are available:

- **`touchpad`** - Touchpads (any device that supports tap gestures)
- **`pointer`** - Everything else: mice, trackballs, trackpoints

### Targeting a Specific Device

Use the `name` field to match a specific device by name (substring match):

```lua
awful.input.rules = {
    { rule = { type = "touchpad" },
      properties = { natural_scrolling = 1 } },
    { rule = { name = "Logitech G502" },
      properties = { accel_speed = -0.5, accel_profile = "flat" } },
}
```

To find device names on your system:

```bash
libinput list-devices | grep "Device:"
```

### How Globals and Rules Interact

Global `awful.input.*` settings are the baseline. Rules override them per-property, per-device. Later rules take priority over earlier ones:

```lua
-- Global: natural scrolling on for everything
awful.input.natural_scrolling = 1

-- Rule: turn it off for mice
awful.input.rules = {
    { rule = { type = "pointer" },
      properties = { natural_scrolling = 0 } },
}
-- Touchpads get natural scrolling (global default), mice don't (rule override)
```

## All Properties

See [awful.input Reference](/reference/awful/input) for the complete property list and rule API.

## Cursor Theming {#cursor-theming}

### Setting the Cursor Theme

Cursor themes can be configured via environment variables before launching SomeWM:

```bash
export XCURSOR_THEME="Adwaita"  # Theme name (from /usr/share/icons/)
export XCURSOR_SIZE="24"        # Size in pixels
somewm
```

You can also set these in your shell profile (`~/.bashrc`, `~/.zshrc`) or in a wrapper script.

### Runtime Cursor Theme Changes <SomewmOnly />

You can change the cursor theme and size at runtime without restarting:

```lua
-- In rc.lua or via somewm-client eval
root.cursor_theme("Adwaita")  -- Change theme
root.cursor_theme()           -- Returns current theme name

root.cursor_size(32)          -- Change size in pixels
root.cursor_size()            -- Returns current size
```

Via CLI:
```bash
somewm-client eval 'root.cursor_theme("Adwaita")'
somewm-client eval 'root.cursor_size(48)'
somewm-client eval 'return root.cursor_theme(), root.cursor_size()'
```

:::note Fallback Behavior
If a cursor theme cannot be loaded (e.g., theme not installed), wlroots provides built-in fallback cursors. These are basic black-and-white cursors that ensure your mouse always works, even on minimal systems.
:::

### Cursor APIs

SomeWM supports AwesomeWM's cursor APIs:

```lua
-- Set the root/desktop cursor
root.cursor("left_ptr")

-- Set cursor for a wibox (changes when mouse hovers over it)
mywibox.cursor = "hand1"
```

### Theme Variables

Customize cursors for specific operations in your theme:

```lua
-- In theme.lua
theme.cursor_mouse_move = "fleur"      -- During window move
theme.cursor_mouse_resize = "cross"    -- During window resize
theme.enable_spawn_cursor = true       -- Show "watch" during app startup
```

See [Theme Variables: Cursors](/reference/beautiful/theme-variables#cursors) for all options.

### Common Cursor Names

Standard X cursor names include: `left_ptr`, `right_ptr`, `hand1`, `hand2`, `watch`, `xterm`, `crosshair`, `fleur`, `sb_h_double_arrow`, `sb_v_double_arrow`, `top_left_corner`, `top_right_corner`, `bottom_left_corner`, `bottom_right_corner`.

### AwesomeWM Reference

For complete API documentation, see the AwesomeWM docs:
- [root.cursor()](https://awesomewm.org/apidoc/core_components/root.html#cursor)
- [wibox.cursor](https://awesomewm.org/apidoc/popups_and_layered_windows/wibox.html#cursor)
- [Appearance](https://awesomewm.org/apidoc/documentation/06-appearance.md.html) - All theme variables including cursors

## Next Steps

- [CLI Control](/guides/cli-control) - Control SomeWM from scripts
