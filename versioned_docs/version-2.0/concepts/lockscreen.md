---
sidebar_position: 6
title: Session Locking
description: How session locking works on Wayland and SomeWM's architecture
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Session Locking <SomewmOnly />

This page explains how session locking works in SomeWM, why it differs from X11, and the security guarantees the architecture provides.

## The Problem: Locking on Wayland

On X11, a screen locker works by creating a fullscreen window and grabbing all input. Any application can do this. The problem is that it relies on cooperation: a bug or crash in the locker can leave the session exposed, and any X client can snoop on input events.

On Wayland, clients cannot grab input or position themselves arbitrarily. The compositor controls all input routing and surface placement. This means locking must be a compositor-level feature, not an application trick.

## Two Lock Mechanisms

SomeWM supports two ways to lock the session:

### Lua Lock API

The primary mechanism. The lock UI runs inside the compositor as Lua widgets, while security enforcement happens in C:

```
┌─────────────────────────────────────────────┐
│  Lua Layer (lockscreen module)              │
│  - Widgets: clock, password dots, status    │
│  - Keygrabber: captures keyboard input      │
│  - Multi-monitor: covers + interactive      │
│  - Theme integration: beautiful variables   │
├─────────────────────────────────────────────┤
│  C Layer (luaa.c, pam_auth.c)              │
│  - awesome.lock() / unlock()               │
│  - awesome.authenticate() via PAM          │
│  - Input routing: only lock surfaces       │
│  - Auth flag: cannot be set from Lua       │
│  - Force-unlock on surface destruction     │
└─────────────────────────────────────────────┘
```

Lua handles the UI and user experience. C handles security. Lua code cannot bypass the C-level authentication check.

### ext-session-lock-v1

The Wayland protocol for external screen lockers (e.g., swaylock). The external client creates lock surfaces through the protocol, and the compositor ensures they cover all outputs before routing input.

The two mechanisms are mutually exclusive. When an ext-session-lock client is active, `awesome.lock()` is blocked, and vice versa.

## Security Guarantees

| Guarantee | How |
|-----------|-----|
| **C-enforced authentication** | `awesome.unlock()` checks a C-level flag that only `pam_authenticate_user()` can set. Lua cannot forge this. |
| **Input isolation** | When locked, only registered lock surfaces receive keyboard and pointer events. All other surfaces are blocked at the compositor level. |
| **VT switch blocking** | Virtual terminal switching is disabled while locked, preventing access to other TTYs. |
| **Crash recovery** | If the lock surface is destroyed while locked (e.g., Lua error), the compositor force-unlocks rather than leaving the session in a state where no input is possible. |
| **Memory safety** | Passwords are copied to a heap buffer, passed to PAM, then zeroed with a volatile pointer (prevents compiler from optimizing away the clear). |
| **Auth reset** | The authenticated flag resets on every new `awesome.lock()` call, so a previous unlock does not carry over. |

## Idle and DPMS Integration

Idle detection, DPMS, and locking form a chain that responds to user activity:

```
User active
    │
    ▼
Idle timeout fires  ──►  awesome.dpms_off()  (displays sleep)
    │
    ▼
Longer timeout fires  ──►  awesome.lock()  (session locks)
    │
    ▼
User activity detected
    │
    ├──►  idle::stop signal  (idle state resets)
    ├──►  dpms::on signal  (displays wake)
    └──►  Lock screen shown  (password required)
```

Each idle timeout is independent and named. Multiple timeouts can coexist (e.g., "dim" at 2 minutes, "lock" at 5 minutes). All timeouts reset on any user input.

Fullscreen clients (e.g., video players) inhibit idle detection automatically.

## AwesomeWM vs SomeWM

| Feature | AwesomeWM (X11) | SomeWM (Wayland) |
|---------|-----------------|------------------|
| Lock mechanism | External locker (i3lock, slock) grabs X input | Built-in Lua API or ext-session-lock protocol |
| Input isolation | X11 grab (can be bypassed) | Compositor-level routing (cannot be bypassed) |
| DPMS control | `xset dpms` (X11 DPMS extension) | `awesome.dpms_off()` / `awesome.dpms_on()` |
| Idle detection | External (xidlehook, xautolock) | Built-in `awesome.set_idle_timeout()` |
| Multi-monitor | Locker must handle outputs | Compositor manages covers per-output |
| VT switch | Cannot prevent | Blocked while locked |
| Authentication | Locker handles PAM | Compositor handles PAM (C level) |

## Limitations

- **Simple default UI:** The built-in lockscreen is intentionally minimal (clock, password, status). For richer UIs, build a custom lockscreen using the Lock API or use an ext-session-lock client.
- **In-memory timeouts:** Idle timeouts are stored in memory and do not persist across compositor restarts.
- **Mutual exclusion:** Only one lock mechanism (Lua or ext-session-lock) can be active at a time. Attempting to use both simultaneously is blocked.

## See Also

- [Lock, Idle, and DPMS Reference](/docs/reference/lock) - Complete API
- [Default Lockscreen Module](/docs/reference/lockscreen) - Built-in module reference
- [Lockscreen Guide](/docs/guides/lockscreen) - Task-oriented examples
- [Wayland vs X11](/docs/concepts/wayland-vs-x11) - Broader comparison
