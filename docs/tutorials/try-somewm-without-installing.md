---
sidebar_position: 0
title: Try SomeWM Without Logging Out
description: Start a nested SomeWM in a window on your current desktop with somewm-client test, spawn a terminal into it, reload a config, and stop it cleanly.
---

import YouWillLearn from '@site/src/components/YouWillLearn';
import SomewmOnly from '@site/src/components/SomewmOnly';

# Try SomeWM Without Logging Out <SomewmOnly />

<YouWillLearn>

- Starting a nested SomeWM in a window from any Wayland or X11 session
- Spawning a terminal into it and using a keybinding
- Reloading an `rc.lua` and stopping the instance

</YouWillLearn>

You need the SomeWM binary [installed](../getting-started/installation.md) and a graphical session of any kind. You do not need to log into SomeWM.

## Start

```bash
somewm-client test start
```

A window opens with SomeWM running the bundled config inside it, titled `somewm:test:test`, and the terminal prints:

```
test 'test': pid 12345 on wayland-3 (host: wayland), config (default)
  keybinds: shortcut inhibitor ACTIVE on outer compositor, Mod4 passes through
  log:      /run/user/1000/somewm-test/test/log
  socket:   /run/user/1000/somewm-test/test/ipc.sock
  next:     somewm-client test run  --name test -- alacritty
            somewm-client test eval --name test 'return mouse.coords()'
            somewm-client test stop --name test
```

## Use it

```bash
somewm-client test run -- alacritty      # any terminal you have
```

Click into the window and press Mod4 + Return: the bundled config spawns another terminal inside. If nothing happens, read the `keybinds:` line. A host that does not forward shortcuts (GNOME, X11) gets `Mod4` remapped to `Mod1`, so press Alt + Return.

## Your own config

```bash
somewm-client test stop
somewm-client test start --config ~/dev/somewmrc.lua
somewm-client test reload                # after editing, without restarting
```

## Stop

```bash
somewm-client test stop
```

The state directory and log are removed.

## Next

- [Testing with a nested compositor](../guides/testing-with-nested-compositor.md#iterative-dev): the edit and reload loop against your real `rc.lua`
- [Test Mode](../concepts/test-mode.md): what nesting is and is not, and the keybind handoff
- [Installation](../getting-started/installation.md) when you want it as your session
- [Basics](basics.md): the desktop, tags and layouts
