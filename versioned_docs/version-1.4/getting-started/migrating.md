---
sidebar_position: 3
title: Migrating from AwesomeWM
description: Check an AwesomeWM configuration and replace X11-dependent code for SomeWM 1.4.
---

# Migrating from AwesomeWM

SomeWM 1.4 follows AwesomeWM master. Start with your existing configuration, check it for X11 dependencies, then [test it in a nested session](../tutorials/try-somewm-without-installing.md).

## Quick Compatibility Check

```bash
somewm --check ~/.config/awesome/rc.lua
```

This checks Lua syntax, known X11 patterns and missing modules. It also runs Luacheck if installed. It does not execute your config or guarantee that it will work.

### Severity Levels

| Level | Meaning |
| --- | --- |
| CRITICAL | A pattern that can fail or block the compositor |
| WARNING | Code that may need a Wayland alternative |
| INFO | A possible compatibility difference |

By default, warnings and critical issues produce a non-zero exit status. To fail only on critical issues while still displaying the full report:

```bash
somewm --check ~/.config/awesome/rc.lua --check-level=critical
```

### Suppressing False Positives

Add `-- somewm:ignore` to a line only after checking that it is safe in your configuration:

```lua
local awful = require("awful")
awful.spawn("flameshot gui") -- somewm:ignore using XDG portal on Wayland
```

Both `--check` and the startup scan skip that line.

## X11 Pattern Replacements

### Screen/Display Information

Read screen properties instead of parsing `xrandr` or `xdpyinfo` output:

```lua
for s in screen do
    print(s.geometry.width .. "x" .. s.geometry.height)
    for name in pairs(s.outputs) do
        print("  Output: " .. name)
    end
end
```

`geometry` is a property, not a method. Use `s.geometry`, not `screen:geometry()`.

### Window/Client Information

Use client properties instead of calling `xprop`. Native Wayland clients expose their application ID as `c.class`. XWayland clients also provide X11 metadata such as `c.instance`. See [client metadata](../reference/deviations.md#client-metadata-and-state).

### Screenshots

Replace `scrot`, `maim` or ImageMagick's `import` with `grim`, or use [`awful.screenshot`](../guides/screenshots.md) from Lua:

```lua
local awful = require("awful")
awful.spawn({ "grim", os.getenv("HOME") .. "/screenshot.png" })
```

### Input Simulation

Replace `xdotool key` with `root.fake_input()`:

```lua
root.fake_input("key_press", "a")
root.fake_input("key_release", "a")
```

Key events go to the focused client. To move the pointer to absolute coordinates, use `root.fake_input("motion_notify", false, x, y)`. There is no `client:send_key()` method.

### GTK/GDK via LGI {#gtkgdk-via-lgi}

Your configuration runs inside the compositor. Display initialisation in GTK or GDK can wait for a response from SomeWM while SomeWM is still running that code, causing a deadlock.

SomeWM skips GTK initialisation, so importing `Gtk` is safe for operations that need no display. Importing `Gdk` can still hang the compositor. Moving the import into a timer or signal handler does not help because those callbacks run on the same thread.

Use `GdkPixbuf` for image decoding and `Gtk.IconTheme.new()` for [icon lookups](#icon-theme-lookups).

### Running a GTK app {#running-a-gtk-app}

Run GTK applications in a separate process. Calling `Gtk.main()` or a GTK application's `run()` method inside the config blocks SomeWM's event loop.

If your settings application is an executable Lua script with a shebang, spawn it instead of importing it:

```lua
local awful = require("awful")
awful.spawn("/usr/share/mywm/settings.lua")
```

### Icon theme lookups {#icon-theme-lookups}

`Gtk.IconTheme.get_default()` needs an initialised display and returns `nil` inside SomeWM. Create an independent icon theme instead:

```lua
local Gtk = require("lgi").require("Gtk", "3.0")
local beautiful = require("beautiful")
local icontheme = Gtk.IconTheme.new()
icontheme:set_custom_theme(beautiful.icons or "hicolor")

local info = icontheme:lookup_icon("firefox", 64, 0)
local path = info and info:get_filename()
```

`menubar.utils.lookup_icon_uncached(name)` is a pure-Lua fallback when the theme has no match.

### Client icons {#client-icons}

SomeWM 1.4 does not receive icons from native Wayland clients, so `c.icon` is `nil`. Resolve an icon from `c.class` using the `icontheme` above:

```lua
local menubar = require("menubar")

local function icon_for(class)
    if not class then return nil end
    -- Try the full application ID, then its final component.
    for _, name in ipairs({ class:lower(), class:lower():match("([^.]+)$") }) do
        local info = icontheme:lookup_icon(name, 64, 0)
        if info and info:get_filename() then return info:get_filename() end
    end
    return menubar.utils.lookup_icon_uncached(class:lower())
end
```

For example, this tries `com.mitchellh.ghostty` and then `ghostty`. XWayland clients can supply their own icons.

### Xresources and xrdb {#xresources-and-xrdb}

`xrdb` updates an X server's resource database. It does not configure native Wayland applications. Put terminal colours in the terminal's configuration.

SomeWM's `gears.xresources` reads `~/.Xresources`, falling back to `~/.Xdefaults` and built-in values. `beautiful.xresources` uses those values for colours and DPI. See [compatibility differences](../reference/deviations.md#architectural-differences).

### X11 properties {#x11-properties}

| API | SomeWM 1.4 behaviour |
| --- | --- |
| `awesome.get_xproperty`, `awesome.set_xproperty` | Undefined. Calling either raises a Lua error and aborts the config. |
| `awesome.register_xproperty` | Accepts its arguments but does nothing. |
| `client:get_xproperty`, `client:set_xproperty` | Return `nil` and do nothing, respectively. Values do not survive reloads. |

Remove code that relies on these properties. Some AwesomeWM configs use them to track whether autostart has already run. `awesome.startup` does not distinguish a fresh start from a reload in the current 1.4 branch: it is true during both config loads, then false during normal operation. For a TTY session, move commands that must run only at initial startup into a script and pass it to `somewm -s /path/to/autostart.sh`.

## What Works Unchanged

Keep your widget compositions, layouts, keybindings, rules, notifications and themes. Review code that depends on X11 tools, metadata or protocols against the [compatibility reference](../reference/deviations.md).

## Automatic Detection

Before loading, SomeWM scans `rc.lua` and the modules it can resolve for known X11 patterns. Reports are advisory. SomeWM still tries to load the config, with a ten-second timeout before falling back if loading hangs.

To share a config with AwesomeWM, branch on `awesome.release`:

```lua
local awful = require("awful")
local is_somewm = awesome.release == "somewm"

if is_somewm then
    awful.spawn({ "grim", os.getenv("HOME") .. "/screenshot.png" })
else
    awful.spawn({ "scrot", os.getenv("HOME") .. "/screenshot.png" })
end
```

## Testing Your Config

Fix critical findings from `--check`, then [start a nested session](../tutorials/try-somewm-without-installing.md#reload-after-editing) with your config. Test shortcuts, widget updates and application rules.

To select the config when starting SomeWM directly, with debug output:

```bash
somewm -d -c ~/.config/awesome/rc.lua 2>&1 | tee migration.log
```

## Common Migration Scenarios

### Autostart Scripts

Replace `xset r rate 200 30` with compositor settings. The delay is in milliseconds and the rate is in repeats per second:

```lua
local awful = require("awful")
awful.input.keyboard_repeat_delay = 200
awful.input.keyboard_repeat_rate = 30
```

### Status Bar with X11 Tools

Replace `xbacklight` with `brightnessctl`. Pass the command directly and parse its output in Lua:

```lua
local awful = require("awful")
local brightness = awful.widget.watch("brightnessctl -m", 5, function(widget, stdout)
    local percent = stdout:match("(%d+)%%")
    widget:set_text(percent and (percent .. "%") or "N/A")
end)
```

Install `brightnessctl` and add `brightness` to your wibar. The widget shows `N/A` if the command returns no percentage.

## Next Steps

See [Wayland vs X11](../concepts/wayland-vs-x11.md) for platform differences and [Input Device Configuration](../guides/input-devices.md) for SomeWM's keyboard and pointer settings.
