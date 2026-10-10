---
sidebar_position: 1
title: Input Device Configuration
description: "awful.input sets pointer and keyboard properties for every device; awful.input.rules sets them per device type or name. Cursor theme, size and per-context cursors, all at runtime."
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Input Device Configuration <SomewmOnly />

`awful.input` is SomeWM's own; AwesomeWM left this to `xinput` and `xset`. A property written on it applies to every connected device, at once, with no restart:

```lua
awful.input.tap_to_click = 1
awful.input.natural_scrolling = 1
awful.input.accel_speed = 0.3
awful.input.xkb_layout = "us"
awful.input.xkb_options = "ctrl:nocaps"
awful.input.keyboard_repeat_rate = 30
awful.input.keyboard_repeat_delay = 300
```

`1` enables, `0` disables, `-1` leaves the device's default. [awful.input reference](/docs/reference/awful/input) lists every property; `somewm-client input` prints them with their current values and sets one for a trial run ([CLI Control](/docs/guides/cli-control)).

## Per device

Rules take the `{ rule, properties }` shape of client rules. A rule overrides the globals for the devices it matches, and a later rule overrides an earlier one:

```lua
awful.input.natural_scrolling = 1               -- everything

awful.input.rules = {
    { rule = { type = "touchpad" },
      properties = { tap_to_click = 1, tap_3fg_drag = 1 } },
    { rule = { type = "pointer" },               -- mice, trackballs, trackpoints
      properties = { natural_scrolling = 0, accel_profile = "flat" } },
    { rule = { name = "Logitech G502" },         -- substring match; libinput list-devices shows names
      properties = { accel_speed = -0.5 } },
}
```

`type` is `touchpad` for any device with tap gestures and `pointer` for the rest.

## Cursor {#cursor-theming}

```lua
root.cursor_theme("Adwaita")     -- no argument reads it
root.cursor_size(32)
root.cursor("left_ptr")          -- the desktop cursor
mywibox.cursor = "hand1"         -- while hovering a wibox
```

```lua
-- theme.lua
theme.cursor_mouse_move = "fleur"
theme.cursor_mouse_resize = "cross"
theme.enable_spawn_cursor = true     -- "watch" while an app starts
```

Names are the X cursor names ([list](https://awesomewm.org/apidoc/documentation/06-appearance.md.html)). To persist a theme and size, set `XCURSOR_THEME` and `XCURSOR_SIZE` in the environment SomeWM starts in. A theme that is not installed falls back to wlroots' built-in cursors. [Theme Variables](/docs/reference/beautiful/theme-variables#cursors) has the cursor variables.
