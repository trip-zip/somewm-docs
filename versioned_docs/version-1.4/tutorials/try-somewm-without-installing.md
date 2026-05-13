---
sidebar_position: 0
title: Try SomeWM Without Logging Out
description: Run a nested SomeWM in a window from your current desktop. No reboot, no logout.
---

import YouWillLearn from '@site/src/components/YouWillLearn';
import SomewmOnly from '@site/src/components/SomewmOnly';

# Try SomeWM Without Logging Out <SomewmOnly />

If you want to kick the tires on SomeWM without committing your daily-driver desktop to it, run a nested instance in a window. wlroots handles the nesting; `somewm-client` handles the rest. Your real session stays untouched.

<YouWillLearn>

- Launch a nested SomeWM in a window from any Wayland or X11 session
- Spawn a terminal inside it and use a real SomeWM keybinding
- Edit `rc.lua` and reload without restarting the nested instance
- Stop the nested instance cleanly and leave no debris

</YouWillLearn>

## Prerequisites

- SomeWM [installed](/docs/getting-started/installation) (the binary needs to be on `$PATH`, but you don't need to log into it)
- You are in a graphical session right now (any Wayland compositor, or X11)

## Start a nested instance

You don't need to write a config first. SomeWM ships a fallback `rc.lua` that's enough to play with. Open a terminal and run:

```bash
somewm-client test start
```

The status block tells you what happened:

```
test 'test': pid 12345 on wayland-3 (host: wayland), config (default)
  keybinds: shortcut inhibitor ACTIVE on outer compositor, Mod4 passes through
  log:      /run/user/1000/somewm-test/test/log
  socket:   /run/user/1000/somewm-test/test/ipc.sock
  next:     somewm-client test run  --name test -- alacritty
            somewm-client test eval --name test 'return mouse.coords()'
            somewm-client test stop --name test
```

A new window opens with the nested SomeWM rendering inside it. The window title says `somewm:test:test`.

## Try a keybinding

The nested instance is empty until you spawn something into it. Drop a terminal in:

```bash
somewm-client test run -- alacritty
```

(Replace `alacritty` with whatever terminal you have installed.)

Click into the nested window, then press `Mod4 + Return` (Super + Return). The default rc.lua spawns another terminal inside the nested instance. If `Mod4` doesn't work, look at the `keybinds:` line in the start block: on hosts that don't forward shortcuts (GNOME, X11), the nested instance auto-remaps `Mod4` to `Mod1` (Alt). Try `Alt + Return` instead.

## Reload after editing

If you want to try your own `rc.lua`, stop the current instance and start a new one pointed at it:

```bash
somewm-client test stop
somewm-client test start --config ~/dev/somewmrc.lua
```

After editing the file, reload without restarting:

```bash
somewm-client test reload
```

## Clean up

```bash
somewm-client test stop
```

The state directory and log are removed.

## What next?

You've got the loop. From here:

- **Keep iterating.** Point a test instance at your real `rc.lua` and use the [iterative widget development recipe](../guides/testing-with-nested-compositor.md#iterative-dev) for the edit / reload cycle.
- **Understand what just happened.** [Test Mode](../concepts/test-mode.md) covers what nesting is, what it isn't (not a VM, not a sandbox), and how the keybind handoff works.
- **Commit to it.** [Install SomeWM as your daily driver](/docs/getting-started/installation) when you're ready to log in.
- **Learn the desktop.** [Basics tutorial](/docs/tutorials/basics) walks through keybindings, tags, and layouts.
