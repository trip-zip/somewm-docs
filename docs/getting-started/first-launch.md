---
sidebar_position: 2
title: Launch
description: Start SomeWM from a display manager or a TTY, where it looks for rc.lua, the five keybindings that get you through the first session, and what to read when it does not start.
---

# Launch

After installation, select SomeWM in your display manager. From a TTY, start it with a session bus:

```bash
dbus-run-session somewm
```

To try it inside your current desktop, use [a nested session](../tutorials/try-somewm-without-installing.md).

## Configuration

SomeWM tries these locations in order, using the first configuration that loads successfully:

1. `$XDG_CONFIG_HOME/somewm/rc.lua`, or `~/.config/somewm/rc.lua` when that variable is unset
2. `~/.config/awesome/rc.lua`
3. `<sysconfdir>/xdg/somewm/rc.lua`
4. `./somewmrc.lua`
5. `<datadir>/somewm/somewmrc.lua`

For a default source installation, `sysconfdir` is `/usr/local/etc` and `datadir` is `/usr/local/share`. Distribution packages may use `/etc` and `/usr/share`. Nix installs the default and Lua libraries under the package's store path.

From the source checkout, copy the bundled default to your configuration directory:

```bash
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/somewm"
cp somewmrc.lua "${XDG_CONFIG_HOME:-$HOME/.config}/somewm/rc.lua"
```

With a package installation, copy its installed default instead. `somewm -c /path/to/rc.lua` selects a specific file. `somewm -c NONE` selects the bundled default. An AwesomeWM configuration may need [migration](migrating.md), especially for custom widgets.

## Keybindings

The bundled config uses **Mod4**, usually the Super key, and `foot` as its terminal. Install `foot` or change the config's `terminal` variable.

| Keys | Action |
| --- | --- |
| Mod4 + Return | Open the terminal |
| Mod4 + Shift + c | Close the focused client |
| Mod4 + 1 to 5 | View a tag |
| Mod4 + Ctrl + r | Reload the configuration |
| Mod4 + Shift + q | Quit |

**Mod4 + s** shows bindings. See [Default Keybindings](../reference/default-keybindings.md) for the full list.

## If it does not start

| Symptom | Check |
| --- | --- |
| `FATAL: no working Lua config found!` | Read the preceding errors. Check the configuration path and Lua library installation. From a source checkout, run `./build/somewm` in the repository root. |
| Configuration errors or a crash | Run `somewm -d 2>&1 \| tee somewm.log`. `WLR_DEBUG=1 somewm` adds wlroots diagnostics. |
| A widget is missing | Look for a warning containing `left out of the tree`. Widgets with old drawing or sizing callbacks need [porting](upgrading-from-2.0.md#port-a-custom-widget). |

## Next

[Build a clock widget](../tutorials/widgets.md) to add something to the desktop. For an existing configuration, read [Migrating from AwesomeWM](migrating.md) or [Upgrading from 2.0](upgrading-from-2.0.md). [Basics](../tutorials/basics.md) starts a configuration from scratch.
