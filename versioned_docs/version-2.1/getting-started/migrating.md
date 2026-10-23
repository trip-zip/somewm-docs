---
sidebar_position: 3
title: Migrating from AwesomeWM
description: Check an AwesomeWM configuration, replace X11 dependencies and port widgets for SomeWM 2.1.
---

# Migrating from AwesomeWM

Work on a copy of your AwesomeWM configuration. Check X11 dependencies, removed APIs and custom widget implementations, then test it in a nested session.

SomeWM 2.1 keeps Lua widgets, themes, tags, rules and signals. Widgets that implement their own `fit`, `layout` or `draw` callbacks need porting. Custom widgets built from supported components can keep their existing structure. See [Upgrading from 2.0 to 2.1](upgrading-from-2.0.md) before testing third-party widget libraries.

## Check first

```bash
somewm --check ~/.config/awesome/rc.lua
```

The checker parses Lua, scans known compatibility patterns and missing imports, and runs Luacheck if installed. It does not execute the config or prove that callbacks work.

| Severity | Meaning |
| --- | --- |
| CRITICAL | Code that can fail or block the compositor |
| WARNING | Code that may need a Wayland alternative |
| INFO | A possible compatibility difference |

Warnings and critical findings produce a non-zero exit status by default. To fail only on critical findings while still showing the full report:

```bash
somewm --check ~/.config/awesome/rc.lua --check-level=critical
```

A reviewed false positive can be suppressed with `-- somewm:ignore` on that line. Both the checker and startup scan recognise it.

The startup scan is advisory. SomeWM still attempts the config. A ten-second timeout interrupts a config that hangs during loading, after which SomeWM attempts a fallback. The timeout does not protect later signal or timer callbacks.

## X11 tools and their replacements

| X11 dependency | Replacement |
| --- | --- |
| `xrandr`, `xdpyinfo` | `s.geometry`, `s.outputs`, and the [output API](../reference/output.md) |
| `xprop` | Client properties. Native Wayland clients expose their application ID as `c.class`, while XWayland clients can also supply X11 metadata |
| `xdotool` | `root.fake_input()` from Lua, or a tool using an input protocol SomeWM supports |
| `scrot`, `maim`, ImageMagick `import` | [Screenshot APIs](../guides/screenshots.md) or `grim` |
| `xset r rate` | `awful.input.keyboard_repeat_delay` in milliseconds and `keyboard_repeat_rate` in repeats per second |
| `xbacklight` | `brightnessctl` as a separate process |
| `xrdb` | Configure native applications directly. SomeWM's `gears.xresources` reads resource files, not the X server database |

`geometry` is a property. The `outputs` value is an array:

```lua
for s in screen do
    print(s.geometry.width, s.geometry.height)
    for _, o in ipairs(s.outputs) do
        print(o.name)
    end
end
```

## GTK and GDK inside the compositor {#gtkgdk-via-lgi}

Display initialisation inside the compositor can deadlock: GTK or GDK waits for a display-server response while SomeWM is still executing that code. Deferring the call to a timer or signal handler does not help because those callbacks use the same thread.

SomeWM suppresses GTK initialisation, but this does not make display-dependent GTK operations usable. `Gtk.IconTheme.get_default()` needs an initialised display. Importing `Gdk` can still block through LGI overrides. Run settings windows as separate processes instead of calling `Gtk.main()` or `app:run()` inside the config.

`GdkPixbuf` decodes images without a display. For icon lookup without GTK:

```lua
local menubar = require("menubar")
local path = menubar.utils.lookup_icon_uncached("firefox")
```

### Client icons {#client-icons}

Native Wayland clients do not provide the X11 window-icon property. SomeWM attempts desktop-entry lookup when `c.icon` is missing. If that finds nothing, try the application's `c.class` with an icon lookup. XWayland clients can supply their own icons.

## X11 properties {#x11-properties}

| API | SomeWM behaviour |
| --- | --- |
| `awesome.get_xproperty`, `awesome.set_xproperty` | Undefined. Calling either raises a Lua error |
| `awesome.register_xproperty` | Accepts the declaration but does nothing |
| `client:get_xproperty`, `client:set_xproperty` | Return nil and do nothing, respectively |

These properties cannot preserve state across reloads. `awesome.startup` is true while the 2.1 config loads on both initial startup and Lua reload, so it does not distinguish them. Use the [autostart guide](../guides/autostart.md) for startup-only processes.

## APIs removed in SomeWM 2.0 {#deprecated-apis-removed-in-somewm-20}

The [1.4-to-2.0 upgrade guide](/docs/2.0/getting-started/upgrading-from-1.4#3-update-affected-configuration) lists replacements for notification helpers, lifecycle signals, `awful.util`, API levels and other aliases. Check third-party modules as well as your own configuration.

For the additional widget and rendering changes, follow [Upgrading from 2.0 to 2.1](upgrading-from-2.0.md). [Signal timing](../concepts/signals.md#dispatch) also matters if code expects a handler to run immediately after changing a property.

## Try it

Start a named test instance with your copied config:

```bash
somewm-client test start --name migration --config ~/somewm-test/rc.lua
somewm-client test logs --name migration
```

Use `--host x11` on an X11 host. Test shortcuts, widget updates, application rules and reloads. A successful startup ping does not prove your config loaded, because SomeWM may have used a fallback. Read the log.

```bash
somewm-client test stop --name migration
```

See [nested testing](../guides/testing-with-nested-compositor.md) for the full workflow. [Wayland vs X11](../concepts/wayland-vs-x11.md) explains the platform differences behind these changes.
