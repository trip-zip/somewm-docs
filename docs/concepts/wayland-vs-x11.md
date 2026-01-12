---
sidebar_position: 2
title: Wayland vs X11
description: Why some things work differently on Wayland
---

# Wayland vs X11

<!-- TODO: Adapt content from ideas/DEVIATIONS.md -->

This page explains why some AwesomeWM features work differently (or don't work) on Wayland.

## Fundamental Differences

| Aspect | X11 | Wayland |
|--------|-----|---------|
| Window management | Client-side hints, WM interprets | Compositor controls everything |
| Drawing | Server-side or client-side | Client-side only (EGL/Vulkan) |
| Input | Global access | Per-surface, security-focused |
| Screenshots | Any app can capture | Requires compositor support |
| Tray icons | X11 embed (`_NET_SYSTEMTRAY`) | D-Bus (StatusNotifierItem) |

## What This Means for SomeWM

### No WM Restart

**X11**: AwesomeWM can restart itself, re-reading config and reconnecting to windows.

**Wayland**: The compositor *is* the display server. Restarting it would disconnect all clients.

**Workaround**: Use `Mod4 + Ctrl + r` to reload your Lua configuration without restarting.

### Different Systray

**X11**: Tray icons are embedded X11 windows inside the wibox.

**Wayland**: Tray icons use the StatusNotifierItem (SNI) D-Bus protocol.

**Impact**: Most modern apps (NetworkManager, Discord, Bluetooth) support SNI. Legacy XEmbed-only apps won't show tray icons.

### No Global Input Injection

**X11**: `xdotool` and similar tools can inject input anywhere.

**Wayland**: Security model prevents apps from injecting input into other apps.

**Impact**: `root.fake_input()` is a stub. Automation tools need compositor support.

### No X Properties

**X11**: Windows can store arbitrary properties that persist across sessions.

**Wayland**: No equivalent mechanism exists.

**Impact**: `awesome.register_xproperty()` and related APIs are stubs.

### Titlebar Border Positioning

**X11**: Borders drawn OUTSIDE the window frame by X server.

**Wayland**: Borders are scene graph elements at geometry edges.

**Impact**: Titlebars start INSIDE the border area (inset by `border_width`).

## Partially Working Features

### Strut Aggregation

Single panel struts work correctly. Multiple panels on the same screen edge may not reserve space properly.

### XKB Layout Toggle

**X11**: Toggle options like `grp:alt_shift_toggle` work because the X server intercepts the key combination and executes the layout switch.

**Wayland**: No X server exists to execute toggle logic. The key combination is just a regular key press that does nothing.

**Impact**: Sway, Hyprland, and other Wayland compositors have the same limitation.

**Workaround**: Use explicit keybindings to switch layouts programmatically. See [Keyboard Layout Switching](/guides/keyboard-layouts) for complete examples.

```lua
awful.key({ "Mod1", "Shift" }, "space", function()
    local current = awesome.xkb_get_layout_group()
    awesome.xkb_set_layout_group((current + 1) % 2)
end)
```

**Note**: Static XKB options like `ctrl:nocaps` and `compose:ralt` work normally - only `grp:*` toggle options are affected.

## See Also

- [AwesomeWM Compatibility](/concepts/awesomewm-compat) - Full compatibility matrix
- [DEVIATIONS.md](https://github.com/trip-zip/somewm/blob/main/ideas/DEVIATIONS.md) - Source file
