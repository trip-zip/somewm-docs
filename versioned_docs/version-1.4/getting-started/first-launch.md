---
sidebar_position: 2
title: Launch
description: Start SomeWM 1.4, create a configuration and check startup errors.
---

# Launch

After [installing SomeWM 1.4](installation.md), select **SomeWM** in your display manager or start it from a TTY.

## Starting SomeWM

### From a Display Manager

`make install` installs the session entry. Select **SomeWM** from the session list in GDM, SDDM or another display manager.

### From a TTY

```bash
dbus-run-session somewm
```

To launch a terminal after startup:

```bash
dbus-run-session somewm -s 'alacritty'
```

Replace `alacritty` with an installed terminal. `dbus-run-session` provides the D-Bus session used by desktop services. If you already have one, run `somewm` directly.

## Configuration Locations

Unless you pass `-c`, SomeWM tries these files in order:

1. `$XDG_CONFIG_HOME/somewm/rc.lua`, or `~/.config/somewm/rc.lua` when that variable is unset
2. `~/.config/awesome/rc.lua`
3. The installed `etc/xdg/somewm/rc.lua`
4. `./somewmrc.lua`, when running from the source directory
5. The installed `share/somewm/somewmrc.lua` fallback

The installed paths depend on the build prefix. A default source build uses `/usr/local`.

### First Time Setup

SomeWM uses the default configuration if you have no personal config. To customise it, run these commands from the 1.4 source directory:

```bash
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/somewm"
cp somewmrc.lua "${XDG_CONFIG_HOME:-$HOME/.config}/somewm/rc.lua"
```

For a package installation, copy the installed `etc/xdg/somewm/rc.lua` instead. The default terminal is `xterm`, which needs XWayland. Change `terminal = "xterm"` in your copy to an installed terminal, such as `alacritty`.

## Essential Keybindings

**Mod4** is usually the Super/Windows key.

| Keybinding | Action |
| --- | --- |
| `Mod4 + Return` | Open terminal |
| `Mod4 + r` | Run prompt |
| `Mod4 + j/k` | Focus next/previous client |
| `Mod4 + Shift + j/k` | Swap client with next/previous |
| `Mod4 + 1-9` | View tag 1-9 |
| `Mod4 + Shift + 1-9` | Move client to tag 1-9 |
| `Mod4 + Space` | Next layout |
| `Mod4 + Shift + c` | Close focused client |
| `Mod4 + Ctrl + r` | Reload configuration |
| `Mod4 + Shift + q` | Quit SomeWM |

Press `Mod4 + s` for shortcut help, or see [Default Keybindings](../reference/default-keybindings.md).

## Troubleshooting

### "No config found" error

Run `sudo make install` from your source directory. To test without installing, run `./build/somewm` from that directory so it can find `lua/` and `somewmrc.lua`.

### Config loads but crashes immediately

Start with debug logging and look for `error loading` or `error executing`:

```bash
somewm -d 2>&1 | tee somewm.log
```

### Widgets not rendering

Check the log for LGI loading errors. The LGI package must match your Lua version. See [LGI Troubleshooting](installation.md#lgi-troubleshooting).

## Next Steps

Follow [Basics](../tutorials/basics.md) to use the default desktop, or [Migrating from AwesomeWM](migrating.md) to adapt an existing config. For keyboard and pointer settings, see [Input Device Configuration](../guides/input-devices.md).
