---
sidebar_position: 12
title: Test Mode
description: What `somewm-client test` is, when to reach for it, and what it isn't.
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Test Mode <SomewmOnly />

`somewm-client test` spawns a sandboxed nested somewm under your current Wayland or X11 session. You get a real somewm process in a window, with its own `XDG_RUNTIME_DIR`, its own Wayland socket, and its own IPC socket. Crashing it leaves your real desktop alone. This page is the "why," not the "how"; if you just want to use it, jump to [Testing with a nested compositor](../guides/testing-with-nested-compositor.md) or the [tutorial](../tutorials/try-somewm-without-installing.md).

## What it actually is

A real somewm binary, started by the orchestrator with a few env vars set:

- `XDG_RUNTIME_DIR` points at a per-instance state directory under your real `$XDG_RUNTIME_DIR/somewm-test/<name>/`.
- `WLR_BACKENDS=wayland` or `=x11` so wlroots opens a window on the outer compositor or X server, instead of taking over a TTY.
- `SOMEWM_SOCKET` points at a per-instance IPC socket so `somewm-client test eval --name <n>` reaches the right compositor.
- `SOMEWM_TEST_NAME` so the compositor knows it's running as a test instance (used by the Lua keybind remap shim).

That's the entire mechanism. There is no VM, no chroot, no container. The same `/home`, the same uid, the same Lua libraries, the same fonts. If your real session can read it, the nested instance can too.

## When to reach for it

| You want to ... | Use ... |
|-----------------|---------|
| Catch a syntax error or known-bad X11 idiom before you run the config | [`somewm --check`](../guides/debugging.md#check-before-loading). Doesn't run anything. |
| Actually see your `rc.lua` behave (widgets, signals, layout, keybinds) | Test mode. Real compositor, real outputs, real Lua. |
| Total isolation from your real files and settings | A VM. Test mode shares `/home`. |
| Try somewm before installing it as your daily driver | Test mode. See the [tutorial](../tutorials/try-somewm-without-installing.md). |
| Test that somewm itself (the binary, not your config) works | Just run `somewm` from a TTY. |

The sweet spot is fast iteration. Test mode boots in well under a second, reloads on demand, and dies cleanly when you `test stop`. You can go from "edit rc.lua" to "see the result" without leaving your editor.

## How the nesting works

wlroots ships two relevant backends:

- The **Wayland backend** (`WLR_BACKENDS=wayland`) opens a `wl_surface` on the outer Wayland compositor and renders the nested somewm into it. Input flows from the outer compositor into wlroots, then into somewm.
- The **X11 backend** (`WLR_BACKENDS=x11`) opens an X11 window with an embedded wlroots scene. Useful for users on Xorg + i3 / awesome / dwm who want to try somewm without leaving X11.

The orchestrator (`somewm-client test`) picks the right backend, spins up a sandboxed `XDG_RUNTIME_DIR`, fork/execs the somewm binary, waits for its IPC socket to come up, and prints a status block. From there, the standard `somewm-client` IPC verbs work against the named instance via `--name`.

A third backend, `--host headless`, runs the compositor with no display output at all. That sounds useless if you want to watch your widgets, but it is exactly what you want for CI: the full Lua VM loads, signal handlers register, and `test eval` lets you assert state, without any graphical session under it. See the [headless CI recipe](../guides/testing-with-nested-compositor.md#headless-ci) in the how-to for what that looks like in practice.

## Lifecycle

The orchestrator is a thin process supervisor around the nested somewm.

On startup: `somewm-client test start` validates the flags, creates the state directory, forks, and execs the somewm binary with the test environment variables set. The parent then polls the per-instance IPC socket every 50 ms and sends a `ping` once it can connect. If the socket responds within 30 seconds, the orchestrator prints the status block and exits. If the child exits first, or the deadline elapses, or the orchestrator finds a `FATAL:` line in the log while waiting, it reports the failure and removes the state directory (unless `SOMEWM_TEST_KEEP_FAILED` is set).

On shutdown: `test stop` sends `SIGTERM`, waits up to 5 seconds for the process to exit, and escalates to `SIGKILL` if it does not. Either way, the state directory is removed at the end.

`test list` does its own check: it connects to every state directory's IPC socket with a short timeout. If the socket is gone but the state directory is still on disk (compositor crashed, was killed externally, host rebooted with the dir on a persistent tmpfs), the entry is reported with `(stale)`. Calling `test stop --name <stale>` will not find a process to kill, but will still clean up the state directory.

## The keybind problem

The outer compositor sees your keystrokes before the nested somewm does. By default, `Mod4+Return` (or whatever your real session has bound) fires on the host, not in the test instance.

There are two paths through this:

1. **Shortcut inhibitor protocol** (`zwp_keyboard_shortcuts_inhibit_manager_v1`). When the test window has focus, the outer compositor stops grabbing shortcuts and forwards them. The nested somewm gets `Mod4+Return` natively. Supported by Sway, KDE, Hyprland, recent niri.
2. **Modifier remap.** When the outer compositor doesn't support the protocol (GNOME today), or when you're on X11, the test instance rewrites every `Mod4` in your config to `Mod1` at load time. Your `Mod4+Return` binding becomes `Alt+Return` for the duration of the test instance. Your real session and your real `rc.lua` are untouched.

The status block printed by `test start` always tells you which path you got. There's no silent fallback.

## What test mode is not

It is not a security boundary. The nested somewm runs as your user, with full access to your home directory, your D-Bus session, your dconf, and anything else your real session can reach. If your test `rc.lua` runs `os.execute("rm -rf ~")`, the directory is gone. If a spawned process inside the test instance writes to `~/.config/somewm/rc.lua`, your real config is overwritten.

If you need isolation, use a VM or a separate user account. Test mode is a fast feedback loop for trusted Lua, not a sandbox for hostile code.

## Credit

The idea of a nested-compositor test mode for a Lua-configured window manager comes from [AWMTT](https://github.com/serialoverflow/awmtt) by serialoverflow, which gave AwesomeWM users this workflow via Xephyr. Full attribution lives in [`ATTRIBUTION.md`](https://github.com/trip-zip/somewm-docs/blob/main/ATTRIBUTION.md).

Because somewm is a Wayland compositor, the nesting is native: wlroots opens a `wl_surface` on the outer compositor instead of running an X server inside an X server. That made room for a few features beyond what the Xephyr-based original could offer:

- **Named multi-instance.** Any number of nested compositors at once, addressed by `--name`. Side-by-side comparisons and per-PR review instances are one command each.
- **Shortcut inhibitor negotiation with an explicit fallback.** When the host advertises `zwp_keyboard_shortcuts_inhibit_manager_v1`, `Mod4` passes through to the nested compositor. When it does not, the Lua shim rewrites every `Mod4` to `Mod1` for the duration of the instance. The status block always reports which path you got.
- **Headless host for CI.** `--host headless` runs the full compositor and Lua VM without any graphical session under it, so `rc.lua` test suites can run in GitHub Actions.
- **`test eval` against the nested Lua VM.** Drive assertions or inspect state directly from your shell or CI script, without leaving the test instance.
- **Structured exit codes and `test list --json`.** Distinguish "already running" from "not found" from "compositor crashed on startup" without parsing stderr. See the [exit-code table](../reference/somewm-client.md#test-exit-codes) for the script-facing contract.
