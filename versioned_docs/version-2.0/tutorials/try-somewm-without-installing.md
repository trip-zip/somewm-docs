---
sidebar_position: 0
title: Try SomeWM Without Logging Out
description: Run a nested SomeWM in a window from your current desktop. No reboot, no logout.
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Try SomeWM Without Logging Out <SomewmOnly />

<span id="prerequisites" />

Run SomeWM in a window, open a terminal inside it, and stop the nested session. You need SomeWM 2.0 and `somewm-client` on your `PATH`, a graphical session, and a terminal emulator such as Alacritty.

The nested compositor has its own windows and configuration. It still runs as your user and shares your files and services, so it is not a sandbox.

## Start a nested instance

<span id="try-a-keybinding" />

From a terminal in a Wayland session, run:

```bash
somewm-client test start
```

On an X11 desktop, use `somewm-client test start --host x11` instead.

A window titled `somewm:test:test` opens. Without `--config`, it uses the normal config search path, including your existing user config. The steps below assume the shipped default. The command prints the instance's PID, socket and log paths, and shortcut handling. Read its `keybinds:` line. If the host cannot forward Super shortcuts, the nested session remaps Mod4 to Mod1 (Alt).

## Open a terminal

Run this from your outer terminal, substituting a terminal you have installed:

```bash
somewm-client test run -- alacritty
```

Click inside the nested window, then press **Mod4+Return**, or **Alt+Return** if remapped. The default config starts `foot`, so install it if you want that shortcut to open a second terminal.

Press **Mod4+Space** to change the layout. The default starts tiled. The next layout puts the master area on the right.

## Try a configuration change {#reload-after-editing}

<span id="clean-up" />
<span id="what-next" />

Make a separate copy of your `rc.lua`, for example `~/somewm-test/rc.lua`. If you do not have one, copy the shipped default using the paths in [First Launch](../getting-started/first-launch.md).

Stop the default instance and start one with your copy:

```bash
somewm-client test stop
somewm-client test start --config ~/somewm-test/rc.lua
```

Add `--host x11` to the start command on X11. In the copied file, change `local terminal = "foot"` to an installed terminal, save, then run:

```bash
somewm-client test reload
```

Press the terminal shortcut inside the nested window. It should launch your chosen terminal. If loading fails, inspect the log with `somewm-client test logs`.

## Stop the instance

```bash
somewm-client test stop
```

The nested window closes and its state directory and log are removed. Copy the log first if you need it for troubleshooting.

Continue with [Basics](basics.md), or use the [nested testing guide](../guides/testing-with-nested-compositor.md) for named instances, headless tests, and command-line inspection.
