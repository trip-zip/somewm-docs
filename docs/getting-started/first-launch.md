---
sidebar_position: 2
title: First Launch
description: Running SomeWM and essential configuration
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# First Launch

<YouWillLearn>

- How to start SomeWM from a display manager or TTY
- Where configuration files are located
- Essential keybindings to navigate

</YouWillLearn>

## Starting SomeWM

### From a Display Manager

If you ran `make install-session`, select **"SomeWM"** from your display manager's session list (GDM, SDDM, etc.).

### From a TTY

```bash
dbus-run-session somewm
```

With a startup command (e.g., to launch a terminal):
```bash
dbus-run-session somewm -s 'alacritty'
```

:::tip D-Bus Session
`dbus-run-session` ensures D-Bus services (notifications, media keys, etc.) work correctly. If you're already in a D-Bus session (e.g., from a display manager), you can run `somewm` directly.
:::

## Configuration Locations

SomeWM searches for configuration files in this order:

1. `~/.config/somewm/rc.lua` - Your personal config
2. `~/.config/awesome/rc.lua` - AwesomeWM compatibility (use your existing config!)
3. System fallback - Default config installed with SomeWM

### First Time Setup

If you don't have a config yet, SomeWM will use the default configuration. To customize:

```bash
# Create config directory
mkdir -p ~/.config/somewm

# Copy default config to customize
cp /etc/xdg/somewm/rc.lua ~/.config/somewm/rc.lua
# Or for local install:
# cp ~/.local/etc/xdg/somewm/rc.lua ~/.config/somewm/rc.lua
```

## Essential Keybindings

The default configuration uses these keybindings (where **Mod4** is usually the Super/Windows key):

| Keybinding | Action |
|------------|--------|
| `Mod4 + Return` | Open terminal |
| `Mod4 + r` | Run prompt |
| `Mod4 + j/k` | Focus next/previous client |
| `Mod4 + Shift + j/k` | Swap client with next/previous |
| `Mod4 + 1-9` | View tag 1-9 |
| `Mod4 + Shift + 1-9` | Move client to tag 1-9 |
| `Mod4 + Space` | Toggle layout |
| `Mod4 + Shift + c` | Close focused client |
| `Mod4 + Ctrl + r` | Reload configuration |
| `Mod4 + Shift + q` | Quit SomeWM |

:::info Full Keybinding Reference
See [Default Keybindings](/reference/default-keybindings) for the complete list.
:::

## Troubleshooting First Launch

### "No config found" error

Make sure you ran `make install` (or `make install-local`). Running SomeWM directly from the build directory won't work because Lua libraries aren't in the expected paths.

### Config loads but crashes immediately

Enable debug logging to see what's happening:

```bash
somewm -d 2>&1 | tee somewm.log
```

Or with full wlroots debug output:
```bash
WLR_DEBUG=1 somewm 2>&1 | tee somewm.log
```

Look for lines containing `error loading` or `error executing` in the log.

### Widgets not rendering

This usually means LGI isn't found or is the wrong version. See [Installation - LGI Troubleshooting](/getting-started/installation#lgi-troubleshooting).

## Next Steps

- **Have an existing AwesomeWM config?** See [Migrating from AwesomeWM](/getting-started/migrating)
- **Starting fresh?** Try the [My First SomeWM](/tutorials/my-first-somewm) tutorial
- **Want to customize input?** See [Input Device Configuration](/guides/input-devices)
