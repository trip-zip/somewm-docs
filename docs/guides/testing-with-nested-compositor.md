---
sidebar_position: 4
title: Testing with a Nested Compositor
description: Run a sandboxed somewm inside your current desktop to test rc.lua changes without touching your real session.
---

import SomewmOnly from '@site/src/components/SomewmOnly';
import YouWillLearn from '@site/src/components/YouWillLearn';

# Testing with a Nested Compositor <SomewmOnly />

`somewm-client test` spawns a sandboxed nested somewm under your current Wayland or X11 session. Crashing the nested instance leaves your real desktop untouched, so it's a safe place to iterate on `rc.lua`, try a PR's config, or reproduce a bug report.

<YouWillLearn>
- Start, stop, and list nested test instances by name
- Run clients and evaluate Lua inside a nested instance
- Reload after editing `rc.lua` without restarting your real session
- What the keybind status line in the startup block means on different hosts
</YouWillLearn>

## Quick start

```bash
somewm-client test start --name work --config ~/dev/somewmrc.lua
```

The status block looks like this on a Wayland host that supports the shortcut inhibitor protocol (Sway, KDE, Hyprland, recent niri):

```
test 'work': pid 12345 on wayland-3 (host: wayland), config /home/you/dev/somewmrc.lua
  keybinds: shortcut inhibitor ACTIVE on outer compositor, Mod4 passes through
  log:      /run/user/1000/somewm-test/work/log
  socket:   /run/user/1000/somewm-test/work/ipc.sock
  next:     somewm-client test run  --name work -- alacritty
            somewm-client test eval --name work 'return mouse.coords()'
            somewm-client test stop --name work
```

Each instance gets its own directory at `$XDG_RUNTIME_DIR/somewm-test/<name>/` with an isolated `XDG_RUNTIME_DIR`, IPC socket, pid file, log, and an `info` key-value file you can inspect.

## Drive commands into the nested instance

The other `test` verbs accept the same `--name` flag and route through the named instance's IPC socket.

```bash
# Spawn a terminal inside the nested compositor
somewm-client test run --name work -- alacritty

# Evaluate Lua in the nested compositor's Lua VM
somewm-client test eval --name work 'return mouse.coords()'

# Reload after editing rc.lua
somewm-client test reload --name work

# Tail the log
somewm-client test logs --name work -f
```

## Keybind behavior on each host

The nested somewm sits between your hand and the host compositor. Keys flow into the host first, and the host decides what to forward.

| Host | What happens | What the status block says |
|------|--------------|-----------------------------|
| Sway, KDE, Hyprland, niri (recent) | somewm binds the host's `zwp_keyboard_shortcuts_inhibit_manager_v1` and the host forwards Mod4 combos to the nested window when it has focus. | `shortcut inhibitor ACTIVE on outer compositor` |
| GNOME, host without inhibitor support | Inhibitor unavailable. Bindings are auto-remapped: every `Mod4` becomes `Mod1` for this instance only. | `! outer compositor did not advertise shortcut inhibitor` |
| X11 (Xorg + i3 / awesome / dwm) | Inhibitor doesn't apply on X11. Same `Mod4 -> Mod1` remap as the GNOME case. | `host=x11, no shortcut-inhibitor negotiation needed` |

When the remap kicks in, the bindings your `rc.lua` registered with `Mod4` activate on `Mod1` (Alt). Bindings without `Mod4` are unchanged. You can force or disable the behavior with `--keybinds`:

```bash
# Force remap even on hosts that support the inhibitor
somewm-client test start --name work --keybinds=remap --config ...

# Don't auto-remap; accept that some Mod4 combos won't reach the nested instance
somewm-client test start --name work --keybinds=none --config ...
```

## Replace a running instance

By default `test start` refuses to clobber a running instance with the same name:

```
Error: test instance 'work' already running (pid 12345).
       Use --force to replace it, or pick a different --name.
```

Pass `--force` to stop and replace the existing one in a single command. The new instance gets a fresh state directory.

## Stop and clean up

```bash
somewm-client test stop --name work
```

`test stop` sends `SIGTERM`, waits up to five seconds for the IPC socket to disappear, then escalates to `SIGKILL` if needed. The state directory is removed on the way out.

`somewm-client test list` connects to each instance's IPC socket with a short timeout and reports `(stale)` for entries whose socket is gone. Stop any stale entries by name.

## Compositor compatibility (Wayland host)

The shortcut inhibitor protocol is the only piece that varies between hosts.

- **Sway**, **KDE / KWin**, **Hyprland**: implement `zwp_keyboard_shortcuts_inhibit_manager_v1` and forward shortcuts as expected.
- **niri**: supports the protocol in recent releases.
- **GNOME / Mutter**: does not implement the protocol. The fallback `Mod4 -> Mod1` remap kicks in automatically.
- Any compositor: even with the inhibitor active, a few host-reserved combos (e.g. `Super+L` to lock) may still be intercepted by the host. Pick `Mod4` keybindings that don't collide with your daily-driver's reserved shortcuts.

## Credit

Test mode is inspired by [AWMTT](https://github.com/serialoverflow/awmtt), a bash wrapper around Xephyr that gave AwesomeWM users the same workflow on X11. The somewm version is a native subcommand because wlroots already handles the nesting, and it adds named multi-instance support plus the shortcut inhibitor negotiation.
