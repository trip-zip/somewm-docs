---
title: Lockscreen and Idle
description: Lock the session with kiln's native PAM-backed lockscreen, auto-lock on idle, and respect idle inhibitors.
sidebar_position: 10
---

# Lockscreen and Idle

Kiln implements a native compositor lock and the external session-lock
protocol. The Odin implementation uses asynchronous PAM authentication for the
native lock. The operator reported successful physical lock/unlock after being
instructed to check coverage, rejected credentials, normal login-password
unlock and restored input. Those individual substeps and every output were not
independently instrumented. External physical locking remains pending; automated
authentication uses a separate compile-time fixture. See
[Limitations](/kiln/concepts/limitations).

Keep an independent recovery connection for physical trials. Protocol and
software tests are not a security guarantee for every hardware configuration.

## 1. The lock model

`kiln.lock()` engages kiln's built-in session lock. From that instant, input is quarantined by the compositor core: no keybinding, no config code, and no client can see keystrokes until the session unlocks. The native lockscreen draws a clock and a password prompt over an opaque cover; typing your password and pressing Enter authenticates against PAM, and only a PAM success opens the unlock gate. `kiln.unlock()` exists, but the compositor refuses it unless authentication has already succeeded, so the lock cannot be bypassed from a script.

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

`kiln.lockscreen.configure{}` overrides any of the lockscreen's appearance keys (colors, text sizes, clock and date formats, prompt strings); unset keys keep their defaults. The [kiln.lockscreen reference](/kiln/reference/kiln#kilnlockscreen) lists all 11 keys.

```lua
kiln.lockscreen.configure {
	bg = "#1e1e2e",
	clock_format = "%H:%M:%S",
	prompt = "locked",
}
```

## 3. Auto-lock on idle

Idle is a compositor fact with one verb and three events. `kiln.set_idle_timeout(ms)` arms a timer that fires after that much time with no input; `nil` or `0` disarms it. The events arrive on the global bus:

- `kiln.on("idle::start", fn)` fires once when the timer elapses.
- `kiln.on("idle::stop", fn)` fires on the first input afterwards. The two strictly alternate.
- `kiln.on("idle::inhibit", fn)` fires with a boolean when a client's idle inhibitor becomes visible or stops being visible (a video player holds one while its window is on screen).

The whole of auto-lock is arming the timer and pointing `idle::start` at the lock:

```lua
kiln.set_idle_timeout(5 * 60 * 1000)   -- five minutes
kiln.on("idle::start", kiln.lock)
```

You can point `idle::start` at anything: dim the screen first, check battery state, or skip locking on a desktop. `idle::stop` is the natural place to undo a dim.

## 4. Respect a playing video

The idle timer and the inhibit fact are deliberately separate: the timer fires on wall-clock inactivity even while an inhibitor is up, and whether a video should block locking is your call, made in a few lines:

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

The ext-session-lock protocol has isolated software coverage. A compatible
external locker engages compositor-side quarantine and supplies its own surface
and authentication; physical deployment must still be tested with recovery
available. Point `idle::start` at the locker instead:

```lua
kiln.on("idle::start", function()
	kiln.spawn("swaylock")
end)
```

Everything else on this page (`set_idle_timeout`, the idle events, the inhibit fact) works identically with an external locker; only the drawing and the authentication move out of kiln.

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
