---
sidebar_position: 6
title: Session Locking
description: Locking is a compositor feature on Wayland. SomeWM has a Lua lock API whose authentication and input isolation are enforced in C, and accepts ext-session-lock-v1 clients; the two are mutually exclusive.
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Session Locking <SomewmOnly />

On Wayland a client cannot grab input or cover the screen on its own, so a locker cannot be an application trick as it is on X11. Locking is a compositor feature, and SomeWM offers it two ways.

| Mechanism | Who draws the lock screen | Who enforces |
| --- | --- | --- |
| the Lua lock API: `awesome.lock()`, `awesome.unlock()`, `awesome.authenticate()` | Lua widgets in the compositor; the bundled `lockscreen` module draws a clock, password dots and a status line, themed from `beautiful` | C: input routing, PAM, the authenticated flag |
| `ext-session-lock-v1` | an external client such as swaylock | C: the compositor routes input only to the lock surfaces once they cover every output |

They are mutually exclusive. While an ext-session-lock client is active, `awesome.lock()` is refused, and the reverse.

## What C guarantees

- `awesome.unlock()` checks a flag that only a successful `pam_authenticate_user()` sets. Lua cannot set it. It resets on every `awesome.lock()`.
- While locked, only lock surfaces receive keyboard and pointer events, keybindings are skipped, and VT switching is blocked.
- If the lock surface is destroyed while locked, for example by a Lua error, the compositor force-unlocks rather than leaving a session that accepts no input.
- The password is copied to a heap buffer, handed to PAM, then zeroed through a volatile pointer.

## Idle and DPMS

`awesome.set_idle_timeout(name, seconds, callback)` registers a named timeout. Several coexist, for example `dim` at 2 minutes and `lock` at 5. Any input resets all of them and emits `idle::stop`; `awesome.dpms_off()` and `awesome.dpms_on()` sleep and wake the outputs, and `dpms::on` fires on wake. A client holding an idle inhibitor through the idle-inhibit protocol, as video players do, stops the timeouts. Timeouts live in memory and do not survive a compositor restart.

[Lock, Idle, and DPMS](../reference/lock.md) is the API; [Lockscreen module](../reference/lockscreen.md) is the bundled UI; [Lockscreen guide](../guides/lockscreen.md) has the recipes.
