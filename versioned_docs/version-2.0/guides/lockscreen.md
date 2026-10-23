---
sidebar_position: 9
title: Lockscreen
description: Set up and customize session locking, idle timeouts, and DPMS
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Lockscreen <SomewmOnly />

<span id="using-the-default-lockscreen" />

Initialise the bundled lockscreen after `beautiful.init()` in `rc.lua`. The default config already does this:

```lua
require("lockscreen").init()
```

With the default bindings, **Mod4+Shift+Escape** locks the session. Enter your password and press Return to unlock.

## Customizing Colors and Fonts

<span id="via-themelua" />
<span id="via-the-opts-table" />
<span id="choosing-the-lock-screen" />

Add settings to your theme before initialisation:

```lua
theme.lockscreen_bg_color = "#000000"
theme.lockscreen_fg_color = "#ffffff"
theme.lockscreen_input_bg = "#1a1a1a"
theme.lockscreen_border_color = "#333333"
theme.lockscreen_error_color = "#ff4444"
theme.lockscreen_font = "monospace 14"
theme.lockscreen_font_large = "monospace bold 64"
```

Alternatively, replace the `init()` call with an options table. Options take priority over theme values:

```lua
require("lockscreen").init {
    bg_color = "#1e1e2e",
    fg_color = "#cdd6f4",
    clock_format = "%I:%M %p",
    date_format = "%a, %b %d",
    lock_screen = function()
        return awful.screen.focused()
    end,
}
```

Without `lock_screen`, the interactive UI uses `screen.primary`. The option also accepts a screen object.

## Setting Up Idle Timeouts

Lock after five minutes of inactivity and turn off displays after six:

```lua
awesome.set_idle_timeout("lock", 300, function()
    awesome.lock()
end)
awesome.set_idle_timeout("dpms", 360, function()
    awesome.dpms_off()
end)
```

Each named timeout fires once per idle period and resets on activity. DPMS turns displays off, rather than dimming them, and does not itself lock the session. Displays wake on activity.

Remove a timeout, or all configured timeouts:

```lua
awesome.clear_idle_timeout("dpms")
awesome.clear_all_idle_timeouts()
```

## Inhibiting Idle

<span id="inhibit-while-fullscreen" />
<span id="inhibit-for-specific-apps" />
<span id="keybinding-toggle" />

`awesome.idle_inhibit` suppresses idle timeouts requested through Lua. Active Wayland protocol inhibitors can also suppress them. `awesome.idle_inhibited` reports their combined effect.

```lua
awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, "F8", function()
        awesome.idle_inhibit = not awesome.idle_inhibit
    end, { description = "toggle idle inhibition", group = "screen" }),
    awful.key({ modkey }, "F7", function()
        awesome.dpms_off()
    end, { description = "turn off displays", group = "screen" }),
})
```

A fullscreen window alone does not inhibit idle. If you add a fullscreen-based policy, update it on client removal and visibility changes too, so it cannot leave inhibition enabled after the window closes or becomes hidden.

### Wibar idle status widget

<span id="dpms-control" />
<span id="keybinding" />
<span id="combining-with-idle" />

```lua
local wibox = require("wibox")
local idle_widget = wibox.widget.textbox()
local function update_idle_widget()
    idle_widget.text = awesome.idle_inhibited and "Idle paused" or ""
end
update_idle_widget()
awesome.connect_signal("property::idle_inhibited", update_idle_widget)
```

Add `idle_widget` to the existing bar. Inspect `awesome.inhibitors` for protocol-inhibitor details.

## Locking from the Command Line

```bash
somewm-client lock
```

The bundled lockscreen must already be initialised. `awesome.lock()` returns false if no lock surface is registered, the session is already locked or an external lock client is active.

## Locking on Suspend

```lua
awesome.connect_signal("logind::prepare_sleep", function(going_to_sleep)
    if going_to_sleep then awesome.lock() end
end)
```

Test suspend and resume on your machine after configuring this handler.

## Building a Custom Lockscreen

Use the bundled `lockscreen` module as the implementation example. A complete replacement must register a lock surface and covers, size them for outputs, handle hotplug, collect input with a keygrabber and stop that keygrabber on deactivation. Call `awesome.unlock()` only after `awesome.authenticate(password)` succeeds.

The [lock API](../reference/lock.md) documents those operations. Lua lock surfaces are part of the trusted configuration. Destroying them or rebuilding the Lua state during reload releases the built-in lock, so do not reload while relying on it to secure the session.

## Using an External Lock Client

SomeWM also supports `ext-session-lock-v1` clients:

```bash
swaylock -c 000000
```

Only one locking mechanism can be active at a time. An active external locker blocks `awesome.lock()`.

## Troubleshooting

<span id="lock-fails-silently" />
<span id="wrong-password-accepted-or-rejected" />
<span id="displays-wont-wake" />
<span id="idle-timeouts-not-firing" />

- **Lock does not activate:** initialise the module once and inspect `awesome.locked` and `awesome.lock_mechanism`.
- **Authentication fails:** the built-in lock uses PAM's `login` service. Inspect its authentication log and configuration.
- **Displays remain off:** inspect `awesome.dpms_state` and try `somewm-client eval "awesome.dpms_on()"`.
- **Idle timeouts do not fire:** inspect `awesome.idle_inhibit`, `awesome.idle_inhibited` and `awesome.idle_timeouts`.

## See Also

- [Lock, Idle and DPMS API](../reference/lock.md)
- [Default Lockscreen Module](../reference/lockscreen.md)
- [Session Locking](../concepts/lockscreen.md)
