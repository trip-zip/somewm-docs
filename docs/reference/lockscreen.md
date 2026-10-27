---
sidebar_position: 6
title: lockscreen
description: Default lockscreen module reference
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# lockscreen <SomewmOnly />

`lockscreen.init()` creates a password prompt and cover surfaces using the [Lock API](lock.md). The default config calls it after loading the theme.

## Usage

```lua
-- In rc.lua, after beautiful.init()
require("lockscreen").init({
    bg_color = "#000000",
    font_large = "monospace bold 64",
    clock_format = "%I:%M %p",
})
```

Call `init()` once, after `beautiful.init()`. Omit its argument to use theme defaults. Later calls are ignored, including their options.

## Configuration Options

| Option | Type | Default | beautiful fallback | Description |
|--------|------|---------|-------------------|-------------|
| `bg_color` | string | `beautiful.bg_normal` or `"#1a1a2e"` | `lockscreen_bg_color` | Background color |
| `fg_color` | string | `beautiful.fg_normal` or `"#e0e0e0"` | `lockscreen_fg_color` | Text color |
| `input_bg` | string | `beautiful.bg_focus` or `"#2a2a4e"` | `lockscreen_input_bg` | Password input background |
| `border_color` | string | `beautiful.border_color_active` or `"#4a4a6e"` | `lockscreen_border_color` | Input box border color |
| `error_color` | string | `beautiful.bg_urgent` or `"#ff6b6b"` | `lockscreen_error_color` | Error message color |
| `font` | string | `"sans 14"` | `lockscreen_font` or `font` | Regular text font |
| `font_large` | string | `"sans bold 48"` | `lockscreen_font_large` | Clock display font |
| `clock_format` | string | `"%H:%M"` | `lockscreen_clock_format` | Clock format (strftime) |
| `date_format` | string | `"%A, %B %d"` | `lockscreen_date_format` | Date format (strftime) |
| `lock_screen` | screen/function/nil | `nil` | none | Screen for interactive UI (nil = primary) |

### Config Resolution Order

For colour and font options, the module checks in order:

1. `opts.option` (passed to `init()`)
2. `beautiful.lockscreen_option` (theme variable)
3. Core `beautiful` variable (e.g., `beautiful.bg_normal` for `bg_color`)
4. Built-in default

## Keyboard Input

| Key | Action |
|-----|--------|
| Printable characters | Append one UTF-8 character. Further input is ignored once the password exceeds 256 bytes |
| `Return` | Submit password for PAM verification |
| `BackSpace` | Delete last character (UTF-8 aware) |
| `Escape` | Clear entire password |
| Caps Lock (active) | Shows "Caps Lock is on" warning while typing |

Password characters are displayed as bullets (U+25CF) rather than plaintext.

## Multi-Monitor Behavior

The lock screen creates two types of surfaces:

- **Interactive surface** on the primary screen (or the screen specified by `lock_screen`): shows clock, date, password input, and status text.
- **Cover surfaces** on all other screens: opaque background-only wiboxes that block content.

On screen hotplug while locked:

- **Screen added:** A new cover is created and shown immediately.
- **Interactive screen removed:** The UI migrates to the new primary screen. The cover on that screen is promoted to an interactive surface.

## Signals Used

The module connects to these signals internally:

| Signal | Purpose |
|--------|---------|
| `lock::activate` | Show lock surfaces, start keygrabber |
| `lock::deactivate` | Hide all surfaces, clear password, stop keygrabber |
| `screen.added` | Create cover for new screen, show if locked |
| `screen.removed` | Migrate interactive UI or remove cover |

<span id="double-init-guard" />

## See Also

- [Lock, Idle, and DPMS Reference](/docs/next/reference/lock) - Core API
- [Lockscreen Guide](/docs/next/guides/lockscreen) - Task-oriented examples
- [Theme Variables](/docs/next/reference/beautiful/theme-variables) - `lockscreen_*` variables
