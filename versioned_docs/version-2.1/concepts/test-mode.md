---
sidebar_position: 12
title: Test Mode
description: What nested and headless test instances isolate, and how their lifecycle works.
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Test Mode <SomewmOnly />

`somewm-client test` runs another SomeWM process in a window or with a headless backend. It gives that process separate runtime and IPC sockets so you can test a configuration without replacing your desktop session.

## What it actually is

The test instance runs as your user with access to the same files, libraries and services. It is not a VM or a filesystem sandbox. Configuration and spawned applications can still change your real files.

The orchestrator sets:

| Variable | Purpose |
| --- | --- |
| `XDG_RUNTIME_DIR` | Per-instance runtime directory under `$XDG_RUNTIME_DIR/somewm-test/<name>/` |
| `WLR_BACKENDS` | Wayland, X11 or headless backend |
| `SOMEWM_SOCKET` | Per-instance IPC socket |
| `SOMEWM_TEST_NAME` | Instance identity used by test-specific behaviour |

## When to reach for it

| Task | Tool |
| --- | --- |
| Check syntax and known compatibility patterns without loading the config | `somewm --check path/to/rc.lua` |
| Exercise widgets, layouts, signals and shortcuts | A nested test instance |
| Run Lua assertions without a graphical display | `--host headless` |
| Isolate configuration from personal files | A VM or separate user account |
| Check physical display modes, input hardware or direct-session behaviour | A session on the relevant hardware |

See [Testing with a nested compositor](../guides/testing-with-nested-compositor.md) for commands, or [Try SomeWM](../tutorials/try-somewm-without-installing.md) for a walkthrough.

## How the nesting works

The Wayland backend creates a surface on the host compositor. The X11 backend creates an X window and requires `--host x11`. Host input is forwarded into the nested compositor, which runs its own clients, layouts and widget rendering.

The headless backend creates virtual outputs without host windows. It still runs the compositor and Lua environment, but does not exercise physical display hardware.

## Lifecycle

<span id="keybindings" />

`test start` creates the state directory and starts the compositor. It polls for the IPC socket every 50 milliseconds, for up to 30 seconds. A successful connection and ping confirm that IPC is available. They do not prove that the requested configuration loaded, since SomeWM may have fallen back to another config. Read the log for load errors. If the child exits, reports a fatal error or misses the deadline, the log is retained.

`test stop` sends SIGTERM and waits up to five seconds before using SIGKILL. It then removes the instance state directory, including the log.

`test list` probes instance sockets and marks unreachable entries as stale. `test stop --name <name>` also removes stale state. Named instances have separate sockets, so several can run at once.

## The keybind problem

The host sees keyboard input first and may consume shortcuts such as **Mod4 + Return**.

If the host supports shortcut inhibition, the focused test window requests that shortcuts be forwarded. Otherwise, the test shim remaps Mod4 bindings to Mod1, so the nested shortcut becomes **Alt + Return**. The config file is not rewritten.

The startup status reports which mode is active. Availability depends on the host and its policy, so use that status rather than assuming a particular desktop forwards shortcuts.

## Credit

The workflow was inspired by [AWMTT](https://github.com/serialoverflow/awmtt), which uses Xephyr for AwesomeWM. SomeWM uses wlroots backends and adds named instances, headless operation and IPC evaluation. See [attribution](https://github.com/trip-zip/somewm-docs/blob/main/ATTRIBUTION.md) and the [test command reference](../reference/somewm-client.md#test-exit-codes).
