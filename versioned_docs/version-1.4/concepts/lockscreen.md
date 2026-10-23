---
sidebar_position: 6
title: Session Locking
description: Built-in and external session locks, input routing and failure behaviour.
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Session Locking <SomewmOnly />

SomeWM supports a built-in Lua lockscreen and external lockers using `ext-session-lock-v1`. The compositor controls which surfaces are visible and receive input while locked.

## The Problem: Locking on Wayland

A fullscreen application window alone is not a session lock. The compositor must keep ordinary applications from receiving input or appearing over the lock surfaces.

## Two Lock Mechanisms

### Lua Lock API

The `lockscreen` module builds widgets for the clock, password entry and status. It registers an interactive lock surface and cover surfaces for other outputs. `awesome.lock()` activates them, and C moves them into the Block scene layer.

`awesome.authenticate()` checks the password through PAM. A successful check sets the flag required by `awesome.unlock()`. Starting a new lock resets that flag.

A lock surface must be registered before locking. The Lua UI and configuration remain trusted code inside the compositor process.

### ext-session-lock-v1

An external locker creates protocol lock surfaces and performs its own authentication. SomeWM routes input to those surfaces and hides ordinary desktop content. If the locker disconnects without unlocking, the session remains locked.

Lua locking and an external session lock cannot be active together.

## Lock Enforcement {#security-guarantees}

| Mechanism | Behaviour |
| --- | --- |
| Authentication | `awesome.unlock()` requires successful authentication since the latest Lua lock |
| Input routing | Ordinary client input and compositor shortcuts are blocked while locked |
| VT switching | SomeWM's VT-switch shortcut handling is disabled while locked |
| Password buffer | The C copy passed to PAM is cleared after use. This does not describe every copy held by Lua or PAM. |
| Lock surface destruction | Destroying the registered Lua lock surface forces an unlock |
| Lua reload | Reloading while Lua-locked forces an unlock before rebuilding the UI |

The last two behaviours are recovery paths, not guarantees that the session stays locked after UI failure. They differ from an external lock client's disconnect behaviour.

## Idle and DPMS Integration

Named idle timers run callbacks after their configured inactivity period. The configuration chooses whether a callback locks, dims or turns off displays. Locking and DPMS are separate actions, so switching displays off does not by itself lock the session.

User activity resets timers and wakes displays. `idle::start`, `idle::stop` and DPMS signals let configuration react. Timers can be inhibited by `awesome.idle_inhibit` or an active client idle inhibitor. Fullscreen alone is not an automatic inhibitor.

## AwesomeWM vs SomeWM

SomeWM's lock, idle and DPMS APIs run in the compositor. AwesomeWM configurations generally launch external X11 tools for these functions. See the [compatibility reference](../reference/deviations.md) when porting those commands.

## Limitations

The built-in UI can be replaced with custom lockscreen widgets, but the registered surfaces must cover the outputs correctly. The compositor does not treat arbitrary Lua configuration as untrusted code. Idle timers are held in memory and must be configured again after the compositor process restarts.

## See Also

- [Lock, Idle and DPMS Reference](../reference/lock.md)
- [Default Lockscreen Module](../reference/lockscreen.md)
- [Lockscreen Guide](../guides/lockscreen.md)
