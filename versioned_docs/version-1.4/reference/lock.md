---
sidebar_position: 5
title: Lock, Idle, and DPMS
description: Session locking, idle timeouts, and display power management
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Lock, Idle, and DPMS <SomewmOnly />

The `awesome` global exposes session locking, idle timeouts, and display power controls. An idle callback can lock the session or turn displays off. User activity wakes displays and resets idle timers.

## Lock API

### Methods

| Method | Arguments | Return | Description |
|--------|-----------|--------|-------------|
| `awesome.lock()` | none | boolean | Lock the session. Returns true on success or if already Lua-locked. Returns false without a registered surface or while ext-session-lock is active |
| `awesome.unlock()` | none | boolean | Unlock the session. Returns true if already unlocked. While Lua-locked, requires a successful `awesome.authenticate()` call since locking |
| `awesome.authenticate(password)` | string | boolean | Synchronously verify the current user’s password via PAM. Return success. On failure, emit `lock::auth_failed` |
| `awesome.set_lock_surface(wibox)` | wibox | none | Register the interactive lock surface (receives keyboard input when locked) |
| `awesome.clear_lock_surface()` | none | none | Unregister the lock surface. Does not unlock the session |
| `awesome.add_lock_cover(wibox)` | wibox | none | Register a cover surface for multi-monitor support (max 16). Idempotent |
| `awesome.remove_lock_cover(wibox)` | wibox | none | Unregister a specific cover surface |
| `awesome.clear_lock_covers()` | none | none | Unregister all cover surfaces |

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `awesome.locked` | boolean (read-only) | True if session is locked via the Lua lock API |
| `awesome.lock_surface` | drawin or nil (read-only) | Registered drawin, when retrievable. In 1.4 this can be nil even after registering a wibox, so retain your own reference |
| `awesome.lock_mechanism` | string or nil (read-only) | `"lua"` for Lua locking, `"ext"` for ext-session-lock, otherwise nil |

### Signals

| Signal | Arguments | Description |
|--------|-----------|-------------|
| `lock::activate` | source (string) | Session locked. Source is `"user"` |
| `lock::deactivate` | none | Session unlocked |
| `lock::auth_failed` | none | Password authentication failed |

### Security Model

`awesome.unlock()` checks an authentication flag set by PAM verification. Starting a new lock resets the flag. While locked, input is restricted to the registered lock surfaces.

Destroying the registered interactive surface or reloading the configuration forces a Lua unlock. `awesome.clear_lock_surface()` only unregisters it, so a custom lock must register a replacement before returning control to the user.

The PAM helper clears its temporary password buffer. This does not erase the caller’s Lua string.

### Example

For password entry and surface setup, see the [lockscreen guide](../guides/lockscreen.md). The bundled [lockscreen module](lockscreen.md) supplies both.

## Idle API

### Methods

| Method | Arguments | Return | Description |
|--------|-----------|--------|-------------|
| `awesome.set_idle_timeout(name, seconds, callback)` | string, positive integer, function | none | Create or update a named idle timeout (max 32). Callback fires once after `seconds` of inactivity, then rearms on user activity |
| `awesome.clear_idle_timeout(name)` | string | none | Remove a named idle timeout. No-op if not found |
| `awesome.clear_all_idle_timeouts()` | none | none | Remove all active idle timeouts |

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `awesome.idle` | boolean (read-only) | True when the user has been idle long enough to fire at least one timeout |
| `awesome.idle_inhibit` | boolean (read/write) | Set to true to suppress idle timeouts from Lua. OR-ed with protocol-level inhibitors |
| `awesome.idle_inhibited` | boolean (read-only) | True if idle is inhibited by any source (protocol inhibitors OR `idle_inhibit`) |
| `awesome.inhibitors` | table (read-only) | Array of `{client = <client or nil>, visible = bool}` for each active Wayland protocol inhibitor |
| `awesome.inhibitor_count` | integer (read-only) | Number of active Wayland protocol idle inhibitors |
| `awesome.idle_timeouts` | table (read-only) | Table of `{name = {seconds = N, fired = bool}, ...}` for all active timeouts |

### Signals

| Signal | Arguments | Description |
|--------|-----------|-------------|
| `idle::start` | none | User became idle (first timeout fired) |
| `idle::stop` | none | User activity detected after being idle |
| `property::idle_inhibited` | none | Combined idle inhibition state changed (read `awesome.idle_inhibited` for new value) |

### Example

```lua
awesome.set_idle_timeout("display-off", 120, function()
    awesome.dpms_off()
end)

awesome.set_idle_timeout("lock", 300, function()
    awesome.lock()
end)
```

The lock callback requires a registered lock surface. Turning displays off does not lock the session.

## DPMS API

### Methods

| Method | Arguments | Return | Description |
|--------|-----------|--------|-------------|
| `awesome.dpms_off()` | none | none | Turn off all displays (sleep mode) |
| `awesome.dpms_on()` | none | none | Wake all displays |

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `awesome.dpms_state` | table (read-only) | Table of `{output_name = "on"/"off", ...}` showing power state per output |

### Signals

| Signal | Arguments | Description |
|--------|-----------|-------------|
| `dpms::off` | none | At least one display entered sleep mode |
| `dpms::on` | none | At least one display woke up |

Displays automatically wake on user activity (keyboard/mouse input).

## See Also

- [Lockscreen Guide](/docs/1.4/guides/lockscreen) - Task-oriented examples
- [Session Locking Concepts](/docs/1.4/concepts/lockscreen) - Architecture and design
- [Default Lockscreen Module](/docs/1.4/reference/lockscreen) - Built-in lockscreen reference
- [Signals Reference](/docs/1.4/reference/signals) - All signals
- [somewm-client Reference](/docs/1.4/reference/somewm-client) - CLI lock command
