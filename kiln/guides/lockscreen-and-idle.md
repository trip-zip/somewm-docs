---
title: Lockscreen and Idle
description: Lock the session with kiln's native PAM-backed lockscreen, auto-lock on idle, and respect idle inhibitors.
sidebar_position: 9
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Lockscreen and Idle

<YouWillLearn>

- Locking and unlocking with `some.lock` and PAM authentication
- Styling the native lockscreen with `some.lockscreen.configure`
- Auto-lock after idle with `some.set_idle_timeout`
- Respecting idle inhibitors (a playing video)
- Using an external locker instead

</YouWillLearn>

## 1. The lock model

`some.lock()` engages kiln's built-in session lock. From that instant, input is quarantined by the compositor core: no keybinding, no config code, and no client can see keystrokes until the session unlocks. The native lockscreen draws a clock and a password prompt over an opaque cover; typing your password and pressing Enter authenticates against PAM, and only a PAM success opens the unlock gate. `some.unlock()` exists, but the compositor refuses it unless authentication has already succeeded, so the lock cannot be bypassed from a script.

Bind it like any other action:

```lua
some.key {
	mods = { "mod", "shift" }, key = "Escape",
	desc = "lock screen", group = "system",
	press = some.lock,
}
```

On the lockscreen itself: Enter submits, Backspace deletes, Escape clears the field. A failed attempt shows the failure message and clears the field.

## 2. Style the native lockscreen

`some.lockscreen.configure{}` overrides any of the lockscreen's appearance keys; unset keys keep their defaults:

| Key | Default | Meaning |
|---|---|---|
| `bg` | `"#101014"` | background |
| `fg` | `"#dcdce6"` | text |
| `error` | `"#c05068"` | failure message color |
| `clock_size` | `48` | clock text size |
| `date_size` | `16` | date text size |
| `dots_size` | `22` | password dots size |
| `status_size` | `14` | prompt/status size |
| `clock_format` | `"%H:%M"` | `os.date` format |
| `date_format` | `"%A, %B %d"` | `os.date` format |
| `prompt` | `"Enter password to unlock"` | idle prompt text |
| `fail` | `"Authentication failed"` | failure text |

```lua
some.lockscreen.configure {
	bg = "#1e1e2e",
	clock_format = "%H:%M:%S",
	prompt = "locked",
}
```

## 3. Auto-lock on idle

Idle is a compositor fact with one verb and three events. `some.set_idle_timeout(ms)` arms a timer that fires after that much time with no input; `nil` or `0` disarms it. The events arrive on the global bus:

- `some.on("idle::start", fn)` fires once when the timer elapses.
- `some.on("idle::stop", fn)` fires on the first input afterwards. The two strictly alternate.
- `some.on("idle::inhibit", fn)` fires with a boolean when a client's idle inhibitor becomes visible or stops being visible (a video player holds one while its window is on screen).

The whole of auto-lock is arming the timer and pointing `idle::start` at the lock:

```lua
some.set_idle_timeout(5 * 60 * 1000)   -- five minutes
some.on("idle::start", some.lock)
```

You can point `idle::start` at anything: dim the screen first, check battery state, or skip locking on a desktop. `idle::stop` is the natural place to undo a dim.

## 4. Respect a playing video

The idle timer and the inhibit fact are deliberately separate: the timer fires on wall-clock inactivity even while an inhibitor is up, and whether a video should block locking is your call, made in a few lines:

```lua
local inhibited = false

some.on("idle::inhibit", function(on)
	inhibited = on
end)

some.set_idle_timeout(5 * 60 * 1000)
some.on("idle::start", function()
	if not inhibited then
		some.lock()
	end
end)
```

The inhibit signal is also a handy do-not-disturb trigger while media plays:

```lua
some.on("idle::inhibit", function(on)
	notification.suspended = on
end)
```

`notification.suspended` queues notifications instead of showing them; see [Notifications](/kiln/guides/notifications).

## 5. External lockers

Lockers that speak the ext-session-lock protocol (swaylock and friends) work as-is: they engage the same compositor-side quarantine, draw their own surface, and the native lockscreen stays out of the way. Point `idle::start` at the locker instead:

```lua
some.on("idle::start", function()
	some.spawn("swaylock")
end)
```

Everything else on this page (`set_idle_timeout`, the idle events, the inhibit fact) works identically with an external locker; only the drawing and the authentication move out of kiln.

## Complete example

```lua
local some = require("somewm")

some.lockscreen.configure {
	bg = "#1e1e2e",
	clock_format = "%H:%M",
}

some.key {
	mods = { "mod", "shift" }, key = "Escape",
	desc = "lock screen", group = "system",
	press = some.lock,
}

local inhibited = false
some.on("idle::inhibit", function(on)
	inhibited = on
	notification.suspended = on
end)

some.set_idle_timeout(10 * 60 * 1000)
some.on("idle::start", function()
	if not inhibited then
		some.lock()
	end
end)
```

## See also

- [Notifications](/kiln/guides/notifications)
- [Some module reference](/kiln/reference/some)
- [Signals reference](/kiln/reference/signals)
