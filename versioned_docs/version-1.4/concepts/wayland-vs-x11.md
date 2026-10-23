---
sidebar_position: 2
title: Wayland vs X11
description: Display-server differences that affect an AwesomeWM configuration on SomeWM 1.4.
---

# Wayland vs X11

On X11, AwesomeWM manages windows served by a separate X server. SomeWM is both the window manager and the Wayland compositor, so it owns display connections, input routing and scene composition.

## Fundamental Differences

| Area | X11 | Wayland |
| --- | --- | --- |
| Application drawing | Clients can submit buffers or use X drawing operations | Clients submit buffers for the compositor to display |
| Window placement | Window manager interprets X properties and requests | Compositor applies placement policy |
| Input and capture | X clients have broad access through the X server | Access depends on compositor-supported protocols and policy |
| Traditional tray icons | XEmbed windows | Usually StatusNotifierItem over D-Bus |

Wayland clients can use shared-memory buffers as well as GPU rendering. EGL or Vulkan is not required for every application.

## What This Means for SomeWM

### No WM Restart

Restarting the compositor process disconnects Wayland applications. SomeWM's `awesome.restart()` instead rebuilds Lua configuration inside the running compositor. **Mod4 + Ctrl + r** invokes that reload in the default config. It does not load a newly installed compositor binary.

### Different Systray

SomeWM's tray uses StatusNotifierItem over D-Bus. Applications that only provide XEmbed tray windows do not appear. XWayland support for application windows does not add XEmbed tray support.

### No Global Input Injection

Native Wayland clients cannot use X11 tools to control other native clients. Input injection needs a supported compositor interface. Inside SomeWM configuration, `root.fake_input()` provides synthetic key, pointer and button events.

### No X Properties

X properties belong to X server objects. They can survive a window-manager restart while the X server and windows remain alive. Native Wayland clients have no equivalent general X-property store.

SomeWM 1.4 leaves some compatibility methods as stubs and omits others. Check the [X-property reference](../reference/deviations.md#stubbed-apis) before calling them.

### Titlebar Border Positioning

`c:geometry()` excludes the border. A border of width `b` adds `b` to each side of the client's visible footprint. Compositor-drawn titlebars occupy space inside the decorated client geometry. Application-drawn decorations belong to the application's own buffer.

## Partially Working Features

### XKB Layout Toggle

In SomeWM 1.4, `grp:*` options do not reliably switch the compositor's active keyboard group. This is an implementation limitation, not a rule of the Wayland protocol. Static options such as `ctrl:nocaps` and `compose:ralt` work.

Use an explicit binding that calls `awesome.xkb_set_layout_group()`. The [keyboard layout guide](../guides/keyboard-layouts.md) shows configuration and cycling between groups.

## See Also

- [Migrating from AwesomeWM](../getting-started/migrating.md)
- [AwesomeWM Compatibility](awesomewm-compat.md)
- [Tag Persistence](tag-persistence.md)
