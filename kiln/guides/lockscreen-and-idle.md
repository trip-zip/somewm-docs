---
title: Lockscreen and Idle
description: Lock the session with kiln's native PAM-backed lockscreen, auto-lock on idle, and respect idle inhibitors.
sidebar_position: 10
---

# Lockscreen and Idle

kiln has a built-in lockscreen that authenticates through PAM, and it
implements ext-session-lock-v1 for external lockers. See
[Limitations](/kiln/concepts/limitations) for what is untested. Keep an SSH
session open the first time you test locking.

## 1. The lock model

`kiln.lock()` engages kiln's built-in session lock. From that instant, the compositor stops delivering keys and pointer events to bindings, config code and clients until unlock. The native lockscreen draws a clock and a password prompt over an opaque cover; typing your password and pressing Enter authenticates against PAM, and only a PAM success opens the unlock gate. `kiln.unlock()` exists, but the compositor refuses it unless authentication has already succeeded, so the lock cannot be bypassed from a script.

Bind it like any other action:

```lua
kiln.key {
	mods = { "mod", "shift" }, key = "Escape",
	desc = "lock screen", group = "system",
	press = kiln.lock,
}
```

On the lockscreen itself: Enter submits, Backspace deletes, Escape clears the field. A failed attempt shows the failure message and clears the field.

## 2. Style the native lockscreen

`kiln.lockscreen.configure{}` overrides any of the lockscreen's appearance keys (colors, text sizes, clock and date formats, prompt strings); unset keys keep their defaults. The [kiln.lockscreen reference](/kiln/reference/kiln#kilnlockscreen) lists every key.

```lua
kiln.lockscreen.configure {
	bg = "#1e1e2e",
	clock_format = "%H:%M:%S",
	prompt = "locked",
}
```

## 3. Auto-lock on idle

kiln has one idle call and three idle events. `kiln.set_idle_timeout(ms)` arms a timer that fires after that much time with no input; `nil` or `0` disarms it. The events arrive on the global bus:

- `kiln.on("idle::start", fn)` fires once when the timer elapses.
- `kiln.on("idle::stop", fn)` fires on the first input afterwards. The two strictly alternate.
- `kiln.on("idle::inhibit", fn)` fires with a boolean when a client's idle inhibitor becomes visible or stops being visible (a video player holds one while its window is on screen).

Auto-lock:

```lua
kiln.set_idle_timeout(5 * 60 * 1000)   -- five minutes
kiln.on("idle::start", kiln.lock)
```

You can point `idle::start` at anything: dim the screen first, check battery state, or skip locking on a desktop. Undo a dim in `idle::stop`.

## 4. Respect a playing video

The idle timer and the inhibit event are deliberately separate: the timer fires on wall-clock inactivity even while an inhibitor is up, and whether a video should block locking is your call, made in a few lines:

```lua
local inhibited = false

kiln.on("idle::inhibit", function(on)
	inhibited = on
end)

kiln.set_idle_timeout(5 * 60 * 1000)
kiln.on("idle::start", function()
	if not inhibited then
		kiln.lock()
	end
end)
```

The inhibit signal is also a handy do-not-disturb trigger while media plays:

```lua
kiln.on("idle::inhibit", function(on)
	notification.suspended = on
end)
```

`notification.suspended` queues notifications instead of showing them; see [Notifications](/kiln/guides/notifications).

## 5. External lockers

An ext-session-lock client such as swaylock locks the session and handles
its own drawing and authentication. kiln withholds input from everything else
until it unlocks. Point `idle::start` at the locker instead:

```lua
kiln.on("idle::start", function()
	kiln.spawn("swaylock")
end)
```

`set_idle_timeout`, the idle events and the inhibit event work identically with an external locker; only the drawing and the authentication move out of kiln.

## Complete example

```lua
local kiln = require("kiln")

kiln.lockscreen.configure {
	bg = "#1e1e2e",
	clock_format = "%H:%M",
}

kiln.key {
	mods = { "mod", "shift" }, key = "Escape",
	desc = "lock screen", group = "system",
	press = kiln.lock,
}

local inhibited = false
kiln.on("idle::inhibit", function(on)
	inhibited = on
	notification.suspended = on
end)

kiln.set_idle_timeout(10 * 60 * 1000)
kiln.on("idle::start", function()
	if not inhibited then
		kiln.lock()
	end
end)
```

## See also

- [Notifications](/kiln/guides/notifications)
- [kiln module reference](/kiln/reference/kiln)
- [Signals reference](/kiln/reference/signals)
