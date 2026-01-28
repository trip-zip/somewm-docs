---
sidebar_position: 1
title: Input Device Configuration
description: Configure pointer and keyboard settings at runtime
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Input Device Configuration <SomewmOnly />

## Overview

<!-- TODO: Write input devices guide
     - Source: lua/awful/input.lua
     - Explain awful.input module (somewm-only)
     - Pointer settings (tap_to_click, natural_scrolling, etc.)
     - Keyboard settings (keyboard_repeat_rate, keyboard_repeat_delay, layout)
     - Example rc.lua configuration
-->

SomeWM provides `awful.input` for runtime input device configuration - a feature not available in AwesomeWM.

## Pointer Settings

<!-- TODO: Examples for each property -->

```lua
local awful = require("awful")

-- Enable tap-to-click on touchpads
awful.input.tap_to_click = 1

-- Natural (inverted) scrolling
awful.input.natural_scrolling = 1

-- Pointer speed (-1.0 to 1.0)
awful.input.pointer_speed = 0.3
```

## Keyboard Settings

<!-- TODO: Layout, repeat rate/delay -->

```lua
-- Keyboard layout
awful.input.xkb_layout = "us"
awful.input.xkb_variant = ""
awful.input.xkb_options = "ctrl:nocaps"

-- Repeat settings
awful.input.keyboard_repeat_rate = 25    -- keys per second
awful.input.keyboard_repeat_delay = 600  -- ms before repeat starts
```

## All Properties

See [awful.input Reference](/reference/awful/input) for the complete property list.

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
