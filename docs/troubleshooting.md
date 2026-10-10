---
sidebar_position: 101
title: Troubleshooting
description: Known failures and their fixes, grouped by startup, widgets, test mode, input and display, plus the current limitations and what to include in a bug report.
---

# Troubleshooting

## Startup

| Symptom | Cause and fix |
| --- | --- |
| `No config found` | the Lua libraries are not installed; `sudo make install`. The search order is `~/.config/somewm/rc.lua`, `~/.config/awesome/rc.lua`, then `/etc/xdg/somewm/rc.lua` or `~/.local/etc/xdg/somewm/rc.lua`. |
| the config loads and it crashes | `somewm --verbose 2>&1 \| tee somewm.log`, `-d` for everything, `WLR_DEBUG=1` for wlroots; look for `error loading` or `error executing` ([Debugging](guides/debugging.md)) |
| an "X11 pattern detected" notification | the config calls an X11 tool or API; [Migrating](getting-started/migrating.md) has the replacement for each |
| black screen after login | `journalctl --user -xe \| grep somewm`, or `dbus-run-session somewm -d` from a TTY |
| wrong resolution | `wlr-randr --output DP-1 --mode 1920x1080@60`, or `output.mode` from Lua ([Multi-Monitor](guides/multi-monitor.md#configure-by-output)) |

## Widgets

### A widget is not showing

A widget with its own `draw`, `fit` or `layout` method, or a class with no describer, is left out of the tree with everything inside it, once per class in the log:

```
W: awesome: wibox.clay: badge draws itself (:draw, :fit) and is left out of the tree
```

`somewm-client clay tree` prints what was drawn and `screen.primary.inspector = true` shows it over the desktop; a left-out widget is absent from both. A property the tree cannot hold warns the same way and names what happened instead. [Upgrading from 2.0 to 2.1](getting-started/upgrading-from-2.0.md#what-you-will-see) has the cases; [Reading the tree](concepts/reading-the-tree.md) the output.

### A widget is unstyled, wrong font, no colours {#widget-shows-no-theming-unstyled-wrong-font}

Its module was required before `beautiful.init()`, so every theme value it read at require time was nil, silently, and it renders in `sans 8`. Move the `require` below `init` ([Widgets](tutorials/widgets.md#2-put-it-in-the-bar)).

**`module 'lgi' not found`.** The LGI package must match the Lua version: `lua51-lgi` for LuaJIT on Arch, `lua-lgi` elsewhere ([Installation](getting-started/installation.md)). `somewm -L /usr/lib/lua/5.1` points at one installed elsewhere.

**No systray icons.** The tray is StatusNotifierItem over D-Bus; an XEmbed-only app has no icon.

## Test mode

| Symptom | Cause and fix |
| --- | --- |
| Mod4 keys do nothing in the nested window | the host does not forward shortcuts, and the status block says `! outer compositor did not advertise shortcut inhibitor`; every `Mod4` is remapped to `Mod1`, so press Alt ([per host](guides/testing-with-nested-compositor.md#keybindings-per-host)) |
| `nested compositor exited before IPC was ready` | `somewm-client test logs --name <n>` shows the traceback. Usual causes: a `require` not on the Lua path (`--config` sets only the `rc.lua`), a nested backend that needs `WLR_RENDERER=pixman`, or an API missing from the installed version. |
| `test stop` hangs or the state directory stays | SIGTERM, five seconds, SIGKILL. If the pid is already gone, `rm -rf "$XDG_RUNTIME_DIR/somewm-test/<n>"` is safe. |
| `test list` shows `stale` | the compositor died without cleanup; `test stop --name <n>` removes the entry, or the `rm -rf` above |

## Input

### Keyboard layout does not switch

`grp:*` XKB options need an X server. Bind it:

```lua
awful.key({ "Mod1", "Shift" }, "space", function()
    awesome.xkb_set_layout_group((awesome.xkb_get_layout_group() + 1) % 2)
end)
```

### A key does not repeat when held {#a-key-doesnt-repeat-when-held}

If no key repeats, the rate is zero: `awful.input.keyboard_repeat_rate = 25`, `keyboard_repeat_delay = 600`. If only some keys are affected, often arrows or remapped keys, the keymap has repeat off for them. A custom `~/.config/xkb` is read before the system layouts, so a symbols file X11 ignored is active here. Compile and look:

```bash
xkbcli compile-keymap --layout us | grep -A4 'key <UP>'
```

```
key <UP> {
    repeat= No,
    symbols[1]= [ Up ],
    actions[1]= [ SetMods(modifiers=none) ]
};
```

A key that defines an action skips compat interpretation and stops repeating. Add `repeat= yes` to that key in the symbols file, re-run the command to confirm `repeat= Yes`, and reload.

**Touchpad does nothing.** `awful.input.tap_to_click = 1` and the rest of [Input Device Configuration](guides/input-devices.md).

## Current limitations {#current-limitations}

[Deviations](reference/deviations.md) is the full list.

| Feature | Status |
| --- | --- |
| XEmbed tray apps | no icon; SNI works |
| X property APIs | stubs |
| `root._remove_key()` | no-op |
| a widget that paints itself | left out; compose from stock widgets |
| a wibox tree above 4096 nodes | shows nothing, with one warning; split it |
| text under `rotate` or `mirror` | one line; a multi-line textbox is left out |
| `grp:*` XKB toggle options | bind the switch yourself |

## Reporting

[Issues](https://github.com/trip-zip/somewm/issues) and [Discussions](https://github.com/trip-zip/somewm/discussions) on GitHub; the [AwesomeWM community](https://awesomewm.org/community/) for Lua API questions. Include `somewm --version`, the relevant part of `rc.lua`, the `somewm -d` log, and the steps.
