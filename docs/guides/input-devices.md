---
sidebar_position: 1
title: Input Device Configuration
description: Configure pointer and keyboard settings at runtime
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Input Device Configuration <SomewmOnly />

This guide shows how to configure your touchpad, mouse, and keyboard from your config, give different devices different settings, and change the cursor theme, all at runtime with no restart. The mechanism is `awful.input`, a SomeWM addition (AwesomeWM delegated this to X11 tools).

## Set Defaults for All Devices

Settings written directly on `awful.input` apply to every connected device:

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

## Give Different Devices Different Settings

If you use both a touchpad and an external mouse, you probably want different settings for each. Input rules let you do this using the same `{ rule, properties }` pattern as [client rules](/docs/guides/client-rules):

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

See [awful.input Reference](/docs/reference/awful/input) for the complete property list and rule API.

## Change the Cursor Theme and Size {#cursor-theming}

Try a theme live, then persist the keeper. At runtime, from Lua or the CLI: <SomewmOnly />

```lua
root.cursor_theme("Adwaita")  -- Change theme (no argument returns the current one)
root.cursor_size(32)          -- Change size in pixels
```

```bash
somewm-client eval 'root.cursor_theme("Adwaita")'
somewm-client eval 'return root.cursor_theme(), root.cursor_size()'
```

To persist it, set the standard environment variables before SomeWM starts (shell profile or a wrapper script):

```bash
export XCURSOR_THEME="Adwaita"  # Theme name (from /usr/share/icons/)
export XCURSOR_SIZE="24"        # Size in pixels
```

:::note Fallback Behavior
If a cursor theme cannot be loaded (e.g., theme not installed), wlroots provides built-in fallback cursors. These are basic black-and-white cursors that ensure your mouse always works, even on minimal systems.
:::

## Use a Different Cursor Per Context

The desktop cursor, hover cursors on wiboxes, and the cursors shown during move/resize grabs are each settable. Values are standard X cursor names like `left_ptr` or `hand1` ([the AwesomeWM appearance docs](https://awesomewm.org/apidoc/documentation/06-appearance.md.html) list them):

```lua
-- Root/desktop cursor
root.cursor("left_ptr")

-- Hover cursor for a wibox
mywibox.cursor = "hand1"

-- In theme.lua: per-operation cursors
theme.cursor_mouse_move = "fleur"      -- During window move
theme.cursor_mouse_resize = "cross"    -- During window resize
theme.enable_spawn_cursor = true       -- Show "watch" during app startup
```

See [Theme Variables: Cursors](/docs/reference/beautiful/theme-variables#cursors) for all options.

## Next Steps

- [CLI Control](/docs/guides/cli-control) - Control SomeWM from scripts
