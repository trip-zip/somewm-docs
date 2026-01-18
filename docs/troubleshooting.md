---
sidebar_position: 101
title: Troubleshooting
description: Common issues and solutions
---

# Troubleshooting

## Startup Issues

### "No config found" error

Make sure you ran `make install` (or `make install-local`). Running SomeWM directly from the build directory won't work because Lua libraries aren't in the expected paths.

After installation, SomeWM searches for configs in this order:
1. `~/.config/somewm/rc.lua`
2. `~/.config/awesome/rc.lua`
3. `/etc/xdg/somewm/rc.lua` (system install) or `~/.local/etc/xdg/somewm/rc.lua` (local install)

### Config loads but crashes immediately

Enable logging to see what's happening. SomeWM has three log levels:

| Flag | Level | Shows |
|------|-------|-------|
| (none) | error | Errors only (default) |
| `--verbose` | info | Errors + info messages |
| `-d` | debug | Everything |

```bash
# Info level (recommended starting point)
somewm --verbose 2>&1 | tee somewm.log

# Debug level (verbose)
somewm -d 2>&1 | tee somewm.log
```

You can also set the log level at runtime from your `rc.lua`:

```lua
awesome.log_level = "debug"  -- or "info", "error"
```

For full wlroots debug output, add the environment variable:
```bash
WLR_DEBUG=1 somewm -d 2>&1 | tee somewm.log
```

Look for lines containing `error loading` or `error executing`.

### "X11 pattern detected" notification

Your config contains code that won't work on Wayland. Edit your `rc.lua` to remove or replace X11-specific patterns. See [Migrating from AwesomeWM](/getting-started/migrating).

## Widget Issues

### Widgets not rendering / LGI not found

SomeWM requires LGI for widget rendering. The package must match your Lua version:

| Lua Version | Arch Linux | Debian/Ubuntu | Fedora |
|-------------|------------|---------------|--------|
| LuaJIT (default) | `lua51-lgi` | `lua-lgi` | `lua-lgi` |
| Lua 5.4 | `lua-lgi` | `lua-lgi` | `lua-lgi` |

For custom LGI locations:
```bash
somewm -L /usr/lib/lua/5.1
```

### Systray icons not showing

SomeWM uses the SNI D-Bus protocol. Legacy apps that only support X11 `_NET_SYSTEMTRAY` won't show icons.

Most modern apps (NetworkManager, Discord, Bluetooth applets) support SNI.

## Input Issues

### Keyboard layout not switching

XKB toggle options like `grp:alt_shift_toggle` don't work automatically on Wayland. Use explicit keybindings:

```lua
awful.key({ "Mod1", "Shift" }, "space", function()
    local current = awesome.xkb_get_layout_group()
    awesome.xkb_set_layout_group((current + 1) % 2)
end)
```

### Touch input not working

Make sure libinput is properly configured. Check `awful.input` settings:

```lua
awful.input.tap_to_click = 1
```

## Display Issues

### Black screen after login

Check logs for errors:
```bash
journalctl --user -xe | grep somewm
```

Try running from TTY with debug output:
```bash
dbus-run-session somewm -d
```

### Wrong resolution

SomeWM uses wlroots for output configuration. You can use `wlr-randr` to configure outputs:
```bash
wlr-randr --output DP-1 --mode 1920x1080@60
```

## Current Limitations {#current-limitations}

These features are not yet implemented:

| Feature | Status | Notes |
|---------|--------|-------|
| Systray (XEmbed apps) | Partial | SNI works, XEmbed doesn't |
| `root.fake_input()` | Stub | Virtual input not implemented |
| X property APIs | Stub | X11 doesn't exist on Wayland |
| Keybinding removal | Stub | `root._remove_key()` is no-op |
| WM restart | N/A | Wayland architecture limitation |

### Partially Implemented

| Feature | Status |
|---------|--------|
| XKB toggle options | Use keybindings instead |

## Getting Help

1. Check [GitHub issues](https://github.com/trip-zip/somewm/issues)
2. Join [GitHub Discussions](https://github.com/trip-zip/somewm/discussions)
3. Visit [AwesomeWM community](https://awesomewm.org/community/) (for Lua API questions)

When reporting issues, include:
- SomeWM version (`somewm --version`)
- Your `rc.lua` (or relevant snippets)
- Debug log output (`somewm -d`)
- Steps to reproduce
