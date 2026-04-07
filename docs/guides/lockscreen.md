---
sidebar_position: 9
title: Lockscreen
description: Set up and customize session locking, idle timeouts, and DPMS
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Lockscreen <SomewmOnly />

This guide covers setting up and customizing session locking, from basic usage to building a fully custom lockscreen.

## Using the Default Lockscreen

The default configuration includes a lockscreen out of the box. In `rc.lua`:

```lua
-- After beautiful.init()
require("lockscreen").init()
```

Press `Mod4 + Shift + Escape` to lock. Enter your password and press Return to unlock.

## Customizing Colors and Fonts

### Via theme.lua

Add `lockscreen_*` variables to your theme:

```lua
theme.lockscreen_bg_color = "#000000"
theme.lockscreen_fg_color = "#ffffff"
theme.lockscreen_input_bg = "#1a1a1a"
theme.lockscreen_border_color = "#333333"
theme.lockscreen_error_color = "#ff4444"
theme.lockscreen_font = "monospace 14"
theme.lockscreen_font_large = "monospace bold 64"
```

### Via the opts table

Pass options directly to override theme values:

```lua
require("lockscreen").init({
    bg_color = "#1e1e2e",
    fg_color = "#cdd6f4",
    error_color = "#f38ba8",
    clock_format = "%I:%M %p",
    date_format = "%a, %b %d",
})
```

## Choosing the Lock Screen

By default, the interactive UI appears on `screen.primary`. Use `lock_screen` to change this:

```lua
-- Always use screen 1
require("lockscreen").init({
    lock_screen = screen[1],
})

-- Dynamic: use the currently focused screen
require("lockscreen").init({
    lock_screen = function()
        return awful.screen.focused()
    end,
})
```

## Setting Up Idle Timeouts

Use `awesome.set_idle_timeout()` to trigger actions after periods of inactivity:

```lua
-- Dim displays after 2 minutes
awesome.set_idle_timeout("dim", 120, function()
    awesome.dpms_off()
end)

-- Lock after 5 minutes
awesome.set_idle_timeout("lock", 300, function()
    awesome.lock()
end)
```

Multiple timeouts run independently. Each fires once per idle period and resets on activity.

To remove a timeout:

```lua
awesome.clear_idle_timeout("dim")

-- Or remove all
awesome.clear_all_idle_timeouts()
```

## Inhibiting Idle

Set `awesome.idle_inhibit = true` to suppress idle timeouts from Lua. This is OR-ed with Wayland protocol inhibitors (e.g., from media players), so both sources must be inactive for idle to resume.

### Inhibit while fullscreen

```lua
client.connect_signal("property::fullscreen", function()
    local dominated = false
    for _, c in ipairs(client.get()) do
        if c.fullscreen then dominated = true; break end
    end
    awesome.idle_inhibit = dominated
end)
```

### Inhibit for specific apps

```lua
client.connect_signal("property::fullscreen", function()
    local dominated = false
    for _, c in ipairs(client.get()) do
        if c.fullscreen and (c.class == "firefox" or c.class == "okular") then
            dominated = true
            break
        end
    end
    awesome.idle_inhibit = dominated
end)
```

### Keybinding toggle

```lua
awful.key({ modkey }, "F8", function()
    awesome.idle_inhibit = not awesome.idle_inhibit
end, {description = "toggle idle inhibition", group = "screen"})
```

## DPMS Control

### Keybinding

```lua
awful.key({ modkey }, "F7", function()
    awesome.dpms_off()
end, {description = "turn off displays", group = "screen"})
```

### Combining with Idle

```lua
-- Turn off displays after 3 minutes, lock after 5
awesome.set_idle_timeout("dpms", 180, function()
    awesome.dpms_off()
end)

awesome.set_idle_timeout("lock", 300, function()
    awesome.lock()
end)
```

Displays automatically wake on user activity.

## Locking from the Command Line

```bash
somewm-client lock
```

This triggers `awesome.lock()` via IPC. Requires a lock surface to be registered (i.e., `lockscreen.init()` must have been called).

## Locking on Suspend

Connect to the `logind::prepare_sleep` signal to lock before the system suspends:

```lua
awesome.connect_signal("logind::prepare_sleep", function(going_to_sleep)
    if going_to_sleep then
        awesome.lock()
    end
end)
```

## Building a Custom Lockscreen

For full control over the lock UI, use the raw Lock API instead of the default module:

```lua
local wibox = require("wibox")
local awful = require("awful")

-- Create lock surfaces
local lock_wb = wibox({
    visible = false,
    ontop = true,
    type = "desktop",
})

-- Register as lock surface
awesome.set_lock_surface(lock_wb)

-- Handle multi-monitor: add covers for other screens
for s in screen do
    if s ~= screen.primary then
        local cover = wibox({
            screen = s,
            visible = false,
            ontop = true,
            bg = "#000000",
            x = s.geometry.x,
            y = s.geometry.y,
            width = s.geometry.width,
            height = s.geometry.height,
        })
        awesome.add_lock_cover(cover)
    end
end

-- React to lock activation
awesome.connect_signal("lock::activate", function()
    -- Show your surfaces, start keygrabber
    lock_wb.visible = true
    local password = ""

    awful.keygrabber {
        autostart = true,
        keypressed_callback = function(_, _, key)
            if key == "Return" then
                awesome.authenticate(password)
                awesome.unlock()
                password = ""
            elseif key == "BackSpace" then
                password = password:sub(1, -2)
            elseif #key == 1 then
                password = password .. key
            end
        end,
    }
end)

awesome.connect_signal("lock::deactivate", function()
    lock_wb.visible = false
end)
```

## Using an External Lock Client

SomeWM supports the ext-session-lock-v1 Wayland protocol, which lets external lockers like swaylock manage the lock session:

```bash
swaylock -c 000000
```

When an ext-session-lock client is active, `awesome.lock()` is blocked to prevent conflicts. Only one lock mechanism can be active at a time.

## Troubleshooting

### Lock fails silently

`awesome.lock()` returns false if:
- No lock surface is registered (call `lockscreen.init()` first)
- Already locked
- An ext-session-lock client is active

Check with: `somewm-client eval "return awesome.locked, awesome.lock_mechanism"`

### Wrong password accepted or rejected

Authentication uses PAM with the `"login"` service. Verify your PAM configuration:

```bash
# Test PAM outside SomeWM
su - $USER
```

### Displays won't wake

Activity should auto-wake displays. If not:
- Check DPMS state: `somewm-client eval "return awesome.dpms_state"`
- Force wake: `somewm-client eval "awesome.dpms_on()"`

### Idle timeouts not firing

- Check Lua inhibition: `somewm-client eval "return awesome.idle_inhibit"`
- Check overall state: `somewm-client eval "return awesome.idle_inhibited"`
- Fullscreen clients with protocol inhibitors also suppress idle
- List active timeouts: `somewm-client eval "return awesome.idle_timeouts"`

## See Also

- [Lock, Idle, and DPMS Reference](/reference/lock) - Complete API
- [Default Lockscreen Module](/reference/lockscreen) - Module configuration
- [Session Locking Concepts](/concepts/lockscreen) - Architecture and design
