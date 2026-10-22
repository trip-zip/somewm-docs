---
sidebar_position: 12
title: Test Mode
description: somewm-client test starts a real somewm in a window on your current session, with its own runtime dir and sockets. No VM, no sandbox; a fast loop for trusted rc.lua, with named instances and a headless host for CI.
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Test Mode <SomewmOnly />

`somewm-client test start` runs a second somewm as a window on your current Wayland or X11 session. It is the same binary with four environment variables set:

| Variable | Value |
| --- | --- |
| `XDG_RUNTIME_DIR` | a per-instance directory under `$XDG_RUNTIME_DIR/somewm-test/<name>/` |
| `WLR_BACKENDS` | `wayland` or `x11`, so wlroots opens a window instead of taking a TTY; `headless` with `--host headless` |
| `SOMEWM_SOCKET` | a per-instance IPC socket, so `somewm-client test eval --name <n>` reaches the right one |
| `SOMEWM_TEST_NAME` | the instance name, read by the keybind remap shim |

Test mode shares your files, user account, Lua libraries and D-Bus session. Use it with trusted configs; use a VM or another user for isolation.

| You want to | Use |
| --- | --- |
| catch a syntax error or an X11 idiom without running anything | `somewm --check` ([Debugging](../guides/debugging.md#check-before-loading)) |
| see `rc.lua` behave: widgets, signals, layouts, keybinds | test mode |
| run `rc.lua` assertions in CI with no display | test mode with `--host headless` ([recipe](../guides/testing-with-nested-compositor.md#headless-ci)) |
| isolation from your files | a VM |

## Lifecycle

`test start` validates the flags, creates the state directory, forks and execs somewm, then polls the instance's IPC socket every 50 ms and sends `ping` once it connects. If the socket answers within 30 seconds it prints a status block and exits. If the child exits first, the deadline passes, or a `FATAL:` line appears in the log, it reports the failure and leaves the state directory so the log survives.

`test stop` sends `SIGTERM`, waits up to 5 seconds, then `SIGKILL`, and removes the state directory. `test list` connects to every state directory's socket; one whose process is gone is reported `(stale)`, and `test stop --name <stale>` cleans its directory up.

Any number of instances run at once, each addressed by `--name`. Exit codes distinguish already running, not found and crashed on startup ([table](../reference/somewm-client.md#test-exit-codes)), and `test list --json` is for scripts.

## Keybindings

The outer compositor sees your keys first, so by default `Mod4+Return` fires on the host. Two paths:

1. **Shortcut inhibitor.** When the host supports `zwp_keyboard_shortcuts_inhibit_manager_v1` (Sway, KDE, Hyprland, recent niri), it forwards shortcuts while the test window has focus, and the nested somewm gets `Mod4+Return` as written.
2. **Modifier remap.** Otherwise (GNOME, X11), the instance rewrites every `Mod4` in your config to `Mod1` at load time. `Mod4+Return` becomes `Alt+Return` for the life of the instance; your real `rc.lua` is untouched.

The status block says which path you got.

## Credit

Test mode was inspired by [AWMTT](https://github.com/serialoverflow/awmtt) by serialoverflow, which runs AwesomeWM in Xephyr. See [attribution](https://github.com/trip-zip/somewm-docs/blob/main/ATTRIBUTION.md).

[Testing with a nested compositor](../guides/testing-with-nested-compositor.md) is the how-to; [Try SomeWM without installing](../tutorials/try-somewm-without-installing.md) is the first run.
