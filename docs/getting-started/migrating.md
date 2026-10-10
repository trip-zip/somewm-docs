---
sidebar_position: 3
title: Migrating from AwesomeWM
description: "somewm --check scans an rc.lua for X11 idioms. The replacements for each, why GTK and GDK freeze the compositor, and the deprecated APIs 2.0 removed."
---

# Migrating from AwesomeWM

An AwesomeWM `rc.lua` at `~/.config/awesome/rc.lua` is loaded as is. What breaks is X11: tools run through `io.popen`, X properties, GTK inside the compositor, and the deprecated APIs AwesomeWM still ships and SomeWM 2.0 removed.

## Check first

```bash
somewm --check ~/.config/awesome/rc.lua
somewm --check ~/.config/awesome/rc.lua --check-level=critical   # exit non-zero only on hangs
```

It reports Lua syntax errors, X11-only APIs, blocking X11 tools called through `io.popen`, `require`s that cannot be found, and luacheck warnings when luacheck is installed. Three severities: **CRITICAL** fails or hangs on Wayland, **WARNING** needs a Wayland alternative, **INFO** may not work but does not break the config.

```
X CRITICAL:
  rc.lua:45 - io.popen with xrandr (blocks)
    → Use screen:geometry() or screen.outputs instead
! WARNING:
  rc.lua:112 - maim screenshot tool
    → Use awful.screenshot or grim instead
Summary: 1 critical, 1 warning
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
| `lgi.require("Gtk")` | WARNING | safe to import: SomeWM preloads an empty `lgi.override.Gtk` so `gtk_init_check()` never runs; anything that needs a display returns nil |
| `lgi.require("Gdk")` | CRITICAL | `lgi/override/Gdk.lua` calls `Gdk.threads_init()` at import, which connects to the display. The session freezes; recovery is a power cycle. |
| `Gtk.Application(...)`, `Gtk.main()` | CRITICAL | a second main loop inside the compositor never returns: no drawing, no input, no `somewm-client` |
| `Gtk.IconTheme.get_default()` | WARNING | needs `gtk_init`, so it returns nil and the next line fails with `attempt to index a nil value` |

Deferring the import to a handler or a timer only changes when it hangs: those run on the compositor's thread too. What works is anything that never touches a display: `GdkPixbuf` decodes images, Gtk's non-display types are fine, and `Gtk.IconTheme.new()` reads the XDG icon directories directly:

```lua
local icontheme = Gtk.IconTheme.new()
icontheme:set_custom_theme(beautiful.icons)   -- e.g. "Papirus-Light"
local info = icontheme:lookup_icon("firefox", 64, 0)
local path = info and info:get_filename()
```

`menubar.utils.lookup_icon_uncached(name)` is a pure-Lua fallback.

A GTK settings window is its own process, like any Wayland client. Put it in a standalone script with a `#!` line and `awful.spawn` it; a file that ends in `app:run()` is already a complete program and only needed to stop being `require`d.

### Client icons {#client-icons}

`c.icon` is nil for native Wayland clients: there is no `_NET_WM_ICON`. A tasklist or dock then draws its fallback for every window. Resolve the icon from `c.class`, which both Wayland and XWayland clients set:

```lua
local function icon_for(class)
    if not class then return nil end
    -- reverse-DNS classes are common: try "com.mitchellh.ghostty", then "ghostty"
    for _, name in ipairs({ class:lower(), class:lower():match("([^.]+)$") }) do
        local info = icontheme:lookup_icon(name, 64, 0)
        if info and info:get_filename() then return info:get_filename() end
    end
    return menubar.utils.lookup_icon_uncached(class:lower())
end
```

## X11 properties {#x11-properties}

| Call | Severity | What happens |
| --- | --- | --- |
| `awesome.get_xproperty`, `awesome.set_xproperty` | CRITICAL | not defined; the call raises `attempt to call field ... (a nil value)`, the error escapes `rc.lua`, and the bundled config loads instead |
| `awesome.register_xproperty` | WARNING | a stub that accepts its arguments and does nothing |

The usual use is telling a fresh start from a restart. `awesome.startup` answers that with no property: it is true only while a fresh start's config loads, and false during a reload and from any handler or timer.

```lua
if awesome.startup then
    -- autostart
end
```

## APIs removed in SomeWM 2.0 {#deprecated-apis-removed-in-somewm-20}

AwesomeWM still ships these for backward compatibility. SomeWM 2.0 deleted them, so a call fails with `attempt to call field '...' (a nil value)` or a `require` error. SomeWM 1.4 keeps all of them. Third-party widget libraries are where they hide. 2.1 removed more, inside the widget libraries; [Upgrading from 2.0 to 2.1](./upgrading-from-2.0.md) lists those.

| Removed | Use |
| --- | --- |
| `naughty.notify(args)` | `naughty.notification(args)` |
| `naughty.suspend()`, `resume()`, `toggle()`, `is_suspended()` | `naughty.suspended = true`, `false`, `not naughty.suspended`; read `naughty.suspended` |
| `naughty.destroy(n, reason)`, `naughty.reset_timeout(n, t)`, `naughty.replace_text(n, title, text)` | `n:destroy(reason)`, `n:reset_timeout(t)`, `n.title = title; n.message = text` |
| `naughty.getById(id)` | `naughty.get_by_id(id)` |
| the bare `manage` and `unmanage` signals; handlers never fire and SomeWM warns at startup | `request::manage` and `request::unmanage`, with `(c, context, hints)` ([React to client lifecycle](../guides/react-to-client-lifecycle.md)) |
| `awful.rules` | `ruled.client` |
| `awful.util` | `gears.filesystem`, `gears.table`, `gears.string`, `gears.math`, `gears.color`, `gears.debug`, `gears.geometry` |
| `awful.wibox` | `awful.wibar` |
| `awful.ewmh` | `awful.permissions` |
| `awful.widget.graph`, `progressbar`, `textclock` | `wibox.widget.*` |
| `wibox.widget.background` | `wibox.container.background` |
| `wibox.layout.margin`, `constraint`, `scroll`, `mirror`, `rotate` | `wibox.container.*` |
| 26 `awful.tag.*` wrappers (`setmwfact`, `getgap`, `viewonly`, ...) and 5 `awful.client.*` wrappers (`getmaster`, `setmaster`, `setslave`, `getmarked`, `floating.toggle`) | the properties and methods AwesomeWM 4.0 introduced: `t.master_width_factor`, `t.gap`, `t:view_only()` |

## Try it

```bash
somewm --check ~/.config/awesome/rc.lua
somewm -c ~/.config/awesome/rc.lua
somewm -d -c ~/.config/awesome/rc.lua 2>&1 | tee migration.log   # with debug output
```

[Wayland vs X11](/docs/concepts/wayland-vs-x11) has why each difference exists; [AwesomeWM Compatibility](/docs/concepts/awesomewm-compat) the contract; [awful.input](/docs/reference/awful/input) the input properties that replace `xset` and `xinput`.
