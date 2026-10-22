---
sidebar_position: 3
title: Migrating from AwesomeWM
description: "somewm --check scans an rc.lua for X11 idioms. The replacements for each, why GTK and GDK freeze the compositor, and the deprecated APIs 2.0 removed."
---

# Migrating from AwesomeWM

SomeWM loads `~/.config/awesome/rc.lua`. Check it for X11 tools and properties, GTK imports, and APIs removed in SomeWM 2.0.

## Check first

```bash
somewm --check ~/.config/awesome/rc.lua
somewm --check ~/.config/awesome/rc.lua --check-level=critical   # exit 2 on critical findings
```

It reports Lua syntax errors, X11-only APIs, blocking X11 tools called through `io.popen`, `require`s that cannot be found, and luacheck warnings when luacheck is installed. Three severities: **CRITICAL** fails or hangs on Wayland, **WARNING** needs a Wayland alternative, **INFO** may not work but does not break the config.

```
X CRITICAL:
  rc.lua:45 - io.popen with xrandr (blocks)
    → Use screen:geometry() or screen.outputs instead
! WARNING:
  rc.lua:112 - maim screenshot tool
    → Use awful.screenshot or grim instead
Summary: 1 critical, 1 warnings
```

A line you have already guarded is silenced with `-- somewm:ignore`, at check time and at load time:

```lua
awful.spawn("flameshot gui") -- somewm:ignore using XDG portal on Wayland
```

SomeWM runs the same scan before loading any config and prints the report; it loads the config anyway. A load that hangs is cut by a ten-second alarm, after which the bundled config loads instead.

## X11 tools and their replacements

| X11 | Wayland |
| --- | --- |
| `io.popen("xrandr")`, `xdpyinfo` | `s.geometry`, `s.outputs` |
| `io.popen("xprop")` | `c.class`, `c.instance` |
| `xdotool key`, `xdotool mousemove` | `root.fake_input("key_press", ...)`, `root.fake_input("motion_notify", ...)` |
| `scrot`, `maim`, `import` | `awful.screenshot { directory = "~" }`, or `grim` |
| `xset r rate 200 30` | `awful.input.keyboard_repeat_delay = 200`, `awful.input.keyboard_repeat_rate = 30` |
| `xbacklight` in `awful.widget.watch` | `brightnessctl -m \| cut -d',' -f4` |
| `xrdb` | nothing. There is no resource database; `beautiful.xresources` still gives DPI and values you supply. Terminal colours go in the terminal's own config. |

```lua
for s in screen do
    print(s.geometry.width .. "x" .. s.geometry.height)
    for name in pairs(s.outputs) do print("  " .. name) end
end
```

A config shared with AwesomeWM can branch on `awesome.release == "somewm"`.

## GTK and GDK inside the compositor {#gtkgdk-via-lgi}

`rc.lua` runs inside the compositor process. GTK and GDK are Wayland clients: on init they connect to the display server and wait for its answer. The display server is SomeWM, busy running your config, so they wait forever.

| Pattern | Severity | What happens |
| --- | --- | --- |
| `lgi.require("Gtk")` | WARNING | skips `gtk_init_check()`, but import can still fail in LGI’s Gdk override; use pure-Lua icon lookup |
| `lgi.require("Gdk")` | CRITICAL | `lgi/override/Gdk.lua` calls `Gdk.threads_init()` at import, which connects to the display. The session freezes; recovery is a power cycle. |
| `Gtk.Application(...)`, `Gtk.main()` | CRITICAL | a second main loop inside the compositor never returns: no drawing, no input, no `somewm-client` |
| `Gtk.IconTheme.get_default()` | WARNING | needs `gtk_init`, so it returns nil and the next line fails with `attempt to index a nil value` |

Deferring the import to a handler or a timer only changes when it hangs: those run on the compositor's thread too. `GdkPixbuf` decodes images without a display; `menubar.utils.lookup_icon_uncached(name)` searches icons without GTK:

```lua
local menubar = require("menubar")
local path = menubar.utils.lookup_icon_uncached("firefox")
```

Run GTK settings windows as separate processes with `awful.spawn`. A script ending in `app:run()` should be executed, not loaded with `require`.

### Client icons {#client-icons}

`c.icon` is nil for native Wayland clients. Resolve icons from `c.class`, which both Wayland and XWayland clients provide:

```lua
local menubar = require("menubar")
local function icon_for(class)
    if not class then return nil end
    -- reverse-DNS classes are common: try "com.mitchellh.ghostty", then "ghostty"
    for _, name in ipairs({ class:lower(), class:lower():match("([^.]+)$") }) do
        local path = menubar.utils.lookup_icon_uncached(name)
        if path then return path end
    end
    return menubar.utils.lookup_icon_uncached(class:lower())
end
```

## X11 properties {#x11-properties}

| Call | Severity | What happens |
| --- | --- | --- |
| `awesome.get_xproperty`, `awesome.set_xproperty` | CRITICAL | not defined; the call raises `attempt to call field ... (a nil value)`, the error escapes `rc.lua`, and the bundled config loads instead |
| `awesome.register_xproperty` | WARNING | a stub that accepts its arguments and does nothing |

`awesome.startup` is true while the config loads on both startup and reload; it does not distinguish them.

```lua
if awesome.startup then
    print("Loading config on startup or reload")
end
```

## APIs removed in SomeWM 2.0 {#deprecated-apis-removed-in-somewm-20}

SomeWM 2.0 removes deprecated APIs that AwesomeWM master and SomeWM 1.4 retain. The [1.4 to 2.0 upgrade guide](../../version-2.0/getting-started/upgrading-from-1.4.md#3-update-affected-configuration) gives the replacements, including notification helpers, lifecycle signals, `awful.util`, API levels and aliases. Check third-party modules as well as your own configuration.

For 2.1, also follow [Upgrading from 2.0 to 2.1](upgrading-from-2.0.md), including its custom-widget restrictions.

## Try it

```bash
somewm --check ~/.config/awesome/rc.lua
somewm -c ~/.config/awesome/rc.lua
somewm -d -c ~/.config/awesome/rc.lua 2>&1 | tee migration.log   # with debug output
```

[Wayland vs X11](../concepts/wayland-vs-x11.md) has why each difference exists; [AwesomeWM Compatibility](../concepts/awesomewm-compat.md) the contract; [awful.input](../reference/awful/input.md) the input properties that replace `xset` and `xinput`.
