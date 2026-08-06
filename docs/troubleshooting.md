---
sidebar_position: 101
title: Troubleshooting
description: Common issues and solutions
---

# Troubleshooting

## Startup Issues

### "No config found" error

Make sure you ran `sudo make install`. Running SomeWM directly from the build directory won't work because Lua libraries aren't in the expected paths.

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

Your config contains code that won't work on Wayland. Edit your `rc.lua` to remove or replace X11-specific patterns. See [Migrating from AwesomeWM](/docs/getting-started/migrating).

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

### Widget shows no theming (unstyled, wrong font)

The widget module was required before `beautiful.init()` ran. Theme variables read at require time were `nil`, silently: no error is raised, the widget just renders with no colors and the default `sans 8` font. Move the widget `require` below `beautiful.init()` in your `rc.lua`. See [the widgets tutorial](/docs/tutorials/widgets#step-3-use-it-in-your-config).

### Systray icons not showing

SomeWM uses the SNI D-Bus protocol. Legacy apps that only support X11 `_NET_SYSTEMTRAY` won't show icons.

Most modern apps (NetworkManager, Discord, Bluetooth applets) support SNI.

## Test Mode

### `Mod4` keybindings don't work in a nested test instance

When `somewm-client test start` is running, the nested somewm sits inside another compositor and the host decides whether to forward `Mod4`. If your host (e.g. GNOME) doesn't implement the shortcut inhibitor protocol, the orchestrator auto-remaps your `Mod4` bindings to `Mod1` (Alt) for that instance only. Check the start block:

```
test 'work': pid 12345 on wayland-3 (host: wayland), config ...
  keybinds: ! outer compositor did not advertise shortcut inhibitor
            ! Mod4 combos will be intercepted by the host
```

When you see this, hit `Alt + <key>` instead of `Mod4 + <key>` for the duration of the test instance. See [Testing with a nested compositor](./guides/testing-with-nested-compositor.md#keybind-behavior-on-each-host) for the per-host compatibility table.

### My test instance crashes immediately on start

The orchestrator reports `nested compositor exited before IPC was ready`. The crash log is in the state directory:

```bash
somewm-client test logs --name <n>
```

Look near the end for a Lua traceback or a wlroots error. Common causes:

- `rc.lua` requires a module that isn't on the test instance's `LUA_PATH`. The orchestrator's `--config FILE` only sets the rc.lua path, not the Lua search path. If your config does `require("my-widgets.foo")`, that module needs to be where Lua already looks (the rc.lua's directory, or `~/.config/somewm/`).
- The test instance's nested-Wayland backend can't initialize. Some hosts need `WLR_RENDERER=pixman` instead of GLES2. Try `WLR_RENDERER=pixman somewm-client test start ...`.
- A widget calls a SomeWM API that doesn't exist in your installed version. The log shows the unknown function name.

### `test stop` hangs or the state dir won't go away

The orchestrator sends `SIGTERM` and waits up to five seconds for the IPC socket to disappear, then escalates to `SIGKILL`. If you see the pid file in `$XDG_RUNTIME_DIR/somewm-test/<n>/` but `kill -0 $(cat .../pid)` says the process is gone, the compositor died ungracefully and left its state behind. Manual cleanup is safe at that point:

```bash
rm -rf "$XDG_RUNTIME_DIR/somewm-test/<n>"
```

### `test list` shows a stale entry

The orchestrator's `test list` connects to each instance's IPC socket with a short timeout. If it can't connect, the entry is reported as stale. That usually means the compositor crashed and the cleanup didn't run.

```bash
somewm-client test list
# NAME      HOST    PID    STATE
# work      wayland 12345  stale

# Drop it
somewm-client test stop --name work
```

If `test stop` itself errors out (the pid file is unreadable, the dir is partially gone), fall back to `rm -rf "$XDG_RUNTIME_DIR/somewm-test/<n>"`.

## Input Issues

### Keyboard layout not switching

XKB toggle options like `grp:alt_shift_toggle` don't work automatically on Wayland. Use explicit keybindings:

```lua
awful.key({ "Mod1", "Shift" }, "space", function()
    local current = awesome.xkb_get_layout_group()
    awesome.xkb_set_layout_group((current + 1) % 2)
end)
```

### A key doesn't repeat when held

If **no** key repeats, check that the rate is not zero:

```lua
awful.input.keyboard_repeat_rate = 25   -- repeats per second
awful.input.keyboard_repeat_delay = 600 -- ms before the first repeat
```

If only **some** keys are affected (often arrows or remapped keys), the keymap has repeat turned off for them. Check for a custom XKB directory:

```bash
ls ~/.config/xkb
```

libxkbcommon reads that directory before the system layouts, so a symbols file written for X11 is active under SomeWM even though X11 ignored it.

Compile your keymap and look at the key that misbehaves:

```bash
xkbcli compile-keymap --layout us | grep -A4 'key <UP>'
```

A key that has lost repeat looks like this:

```
key <UP> {
    repeat= No,
    symbols[1]= [ Up ],
    actions[1]= [ SetMods(modifiers=none) ]
};
```

The `actions[1]=` line is the cause and `repeat= No` is the result. Any key defining an action skips compat interpretation and falls back to not repeating.

Add `repeat= yes` to those definitions in your symbols file:

```
key <UP> { symbols[Group1]=[ Up ], actions[Group1]=[ ... ], repeat= yes };
```

Re-run the `xkbcli` command to confirm `repeat= Yes`, then reload your config.

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

The [Deviations reference](/docs/reference/deviations) is the canonical status list. Highlights:

| Feature | Status | Notes |
|---------|--------|-------|
| Systray (XEmbed apps) | Partial | SNI works, XEmbed doesn't |
| X property APIs | Stub | X11 doesn't exist on Wayland |
| Keybinding removal | Stub | `root._remove_key()` is no-op |

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
