---
sidebar_position: 5
title: Lock, Idle, and DPMS
description: Session locking, idle timeouts, and display power management
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Lock, Idle, and DPMS <SomewmOnly />

Session locking, idle detection, and display power management APIs. These live on the `awesome` global and are unique to SomeWM (AwesomeWM has no lock API).

Lock, Idle, and DPMS are tightly coupled: idle timeouts can trigger DPMS and lock, and user activity wakes DPMS and resets idle state. They are documented together to show how they interact.

## Lock API

### Methods

| Method | Arguments | Return | Description |
|--------|-----------|--------|-------------|
| `awesome.lock()` | none | boolean | Lock the session. Returns true on success, false if already locked, no lock surface registered, or ext-session-lock is active |
| `awesome.unlock()` | none | boolean | Unlock the session. Returns true on success. Only succeeds if `awesome.authenticate()` was called with a correct password first |
| `awesome.authenticate(password)` | string | none | Verify password via PAM. On success, marks session as authenticated. On failure, emits `lock::auth_failed` |
| `awesome.set_lock_surface(wibox)` | wibox | none | Register the interactive lock surface (receives keyboard input when locked) |
| `awesome.clear_lock_surface()` | none | none | Unregister the lock surface. If called while locked, forces unlock |
| `awesome.add_lock_cover(wibox)` | wibox | none | Register a cover surface for multi-monitor support (max 16). Idempotent |
| `awesome.remove_lock_cover(wibox)` | wibox | none | Unregister a specific cover surface |
| `awesome.clear_lock_covers()` | none | none | Unregister all cover surfaces |

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `awesome.locked` | boolean (read-only) | True if session is locked via the Lua lock API |
| `awesome.lock_surface` | drawin or nil (read-only) | Currently registered interactive lock surface |
| `awesome.lock_mechanism` | string or nil (read-only) | `"lua"` if locked via Lua API, nil if not locked |

### Signals

| Signal | Arguments | Description |
|--------|-----------|-------------|
| `lock::activate` | source (string) | Session locked. Source is `"user"` |
| `lock::deactivate` | none | Session unlocked |
| `lock::auth_failed` | none | Password authentication failed |

### Security Model

Authentication is enforced at the C level, not in Lua. This means:

- **C-enforced auth:** `awesome.unlock()` checks an internal C flag set only by a successful `awesome.authenticate()` call. Lua code cannot bypass this.
- **Input routing:** When locked, only the registered lock surface and covers receive input. All other surfaces are blocked.
- **Force-unlock safety:** If the lock surface is destroyed while locked, the compositor automatically unlocks to prevent a deadlocked session.
- **PAM memory clearing:** Passwords are copied to a local buffer, verified via PAM, then securely zeroed using a volatile pointer to prevent compiler optimization.
- **Auth reset:** The authenticated flag is reset on every new `awesome.lock()` call.

### Example

```lua
-- Minimal lock flow
awesome.lock()

-- In your keygrabber callback:
awesome.authenticate(password)
awesome.unlock()
```

## Idle API

### Methods

| Method | Arguments | Return | Description |
|--------|-----------|--------|-------------|
| `awesome.set_idle_timeout(name, seconds, callback)` | string, number, function | none | Create or update a named idle timeout (max 32). Callback fires after `seconds` of inactivity |
| `awesome.clear_idle_timeout(name)` | string | none | Remove a named idle timeout. No-op if not found |
| `awesome.clear_all_idle_timeouts()` | none | none | Remove all active idle timeouts |

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `awesome.idle` | boolean (read-only) | True when the user has been idle long enough to fire at least one timeout |
| `awesome.idle_inhibited` | boolean (read-only) | True if idle detection is currently inhibited (e.g., by a fullscreen client) |
| `awesome.idle_timeouts` | table (read-only) | Table of `{name = seconds, ...}` for all active timeouts |

### Signals

| Signal | Arguments | Description |
|--------|-----------|-------------|
| `idle::start` | none | User became idle (first timeout fired) |
| `idle::stop` | none | User activity detected after being idle |

### Example

```lua
-- Dim after 2 minutes, lock after 5 minutes
awesome.set_idle_timeout("dim", 120, function()
    -- dim your screens
    awesome.dpms_off()
end)

awesome.set_idle_timeout("lock", 300, function()
    awesome.lock()
end)

-- Remove a specific timeout
awesome.clear_idle_timeout("dim")
```

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

- [Lockscreen Guide](/guides/lockscreen) - Task-oriented examples
- [Session Locking Concepts](/concepts/lockscreen) - Architecture and design
- [Default Lockscreen Module](/reference/lockscreen) - Built-in lockscreen reference
- [Signals Reference](/reference/signals) - All signals
- [somewm-client Reference](/reference/somewm-client) - CLI lock command
