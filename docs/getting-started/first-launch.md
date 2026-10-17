---
sidebar_position: 2
title: Launch
description: Start SomeWM from a display manager or a TTY, where it looks for rc.lua, the five keybindings that get you through the first session, and what to read when it does not start.
---

# Launch

`sudo make install` adds a Wayland session, so SomeWM appears in GDM, SDDM and the like. From a TTY:

```bash
dbus-run-session somewm
dbus-run-session somewm -s 'alacritty'   # with a startup command
```

`dbus-run-session` gives notifications and media keys a session bus; inside a display manager's session, plain `somewm` is enough.

## Configuration

SomeWM loads the first of:

1. `~/.config/somewm/rc.lua`
2. `~/.config/awesome/rc.lua`, so an existing AwesomeWM config is used as is
3. the bundled default

To start from the default:

```bash
mkdir -p ~/.config/somewm
cp /etc/xdg/somewm/rc.lua ~/.config/somewm/rc.lua    # ~/.local/etc/xdg/somewm/rc.lua for a local install
```

On NixOS `nix-build` installs only binaries; take the default from [the repository](https://github.com/trip-zip/somewm/blob/main/somewmrc.lua).

## Keybindings

Mod4 is the Super key.

| Keys | Action |
| --- | --- |
| Mod4 + Return | terminal |
| Mod4 + Shift + c | close the focused client |
| Mod4 + 1 to 5 | view a tag; the default config makes five |
| Mod4 + Ctrl + r | reload the config |
| Mod4 + Shift + q | quit |

Mod4 + s shows every binding; [Default Keybindings](../reference/default-keybindings.md) lists them.

## If it does not start

| Symptom | Cause and fix |
| --- | --- |
| `FATAL: no working Lua config found!` | the Lua libraries are not installed; run `sudo make install`, the build directory alone does not work |
| the config loads and it crashes | `somewm -d 2>&1 \| tee somewm.log`, or `WLR_DEBUG=1 somewm` for wlroots output; look for `error loading` or `error executing` |
| a widget is missing | a widget with its own `draw` or `fit` method is left out of the tree; the log has `wibox.clay: <class> draws itself (...) and is left out of the tree`, `somewm-client clay tree` prints what was drawn, and [Upgrading from 2.0 to 2.1](./upgrading-from-2.0.md#what-you-will-see) has the cases |

## Next

- an AwesomeWM config: [Migrating from AwesomeWM](migrating.md)
- a SomeWM 2.0 config: [Upgrading from 2.0 to 2.1](./upgrading-from-2.0.md)
- from scratch: [Basics](../tutorials/basics.md)
