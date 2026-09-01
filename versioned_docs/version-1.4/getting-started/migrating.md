---
sidebar_position: 3
title: Migrating from AwesomeWM
description: Adapting your AwesomeWM config for Wayland
---

# Migrating from AwesomeWM

## Quick Compatibility Check

Before migrating, scan your config for potential issues:

```bash
somewm --check ~/.config/awesome/rc.lua
```

To only fail on issues that would actually hang the compositor (ignoring warnings):

```bash
somewm --check ~/.config/awesome/rc.lua --check-level=critical
```

This checks for:
- **Lua syntax errors** - Caught before execution
- **X11-specific APIs** - Functions like `awesome.get_xproperty()` that don't exist on Wayland
- **Blocking X11 tools** - Calls to `xrandr`, `xdotool`, `xprop` via `io.popen()` that would hang
- **Missing local modules** - `require()` statements for files that can't be found
- **Luacheck issues** - Code quality warnings (if luacheck is installed)

### Severity Levels

Issues are categorized by severity:
- **CRITICAL** - Will fail or hang on Wayland (must fix)
- **WARNING** - Needs a Wayland alternative
- **INFO** - May not work but won't break config

Example output:
```
somewm config compatibility report
====================================
Config: /home/user/.config/awesome/rc.lua

X CRITICAL:
  rc.lua:45 - io.popen with xrandr (blocks)
    → Use screen:geometry() or screen.outputs instead

! WARNING:
  rc.lua:112 - maim screenshot tool
    → Use awful.screenshot or grim instead

Summary: 1 critical, 1 warning
```

### Suppressing False Positives

If `--check` flags a pattern you've already handled (e.g. behind a runtime guard), add `-- somewm:ignore` to that line:

```lua
awful.spawn("flameshot gui") -- somewm:ignore using XDG portal on Wayland
```

The suppression also works at runtime, not just in `--check` mode. SomeWM's startup prescan will skip suppressed lines too.

## X11 Pattern Replacements

### Screen/Display Information

| X11 Pattern | Wayland Alternative |
|-------------|---------------------|
| `io.popen("xrandr")` | `screen:geometry()` or `screen.outputs` |
| `xdpyinfo` | `screen.geometry` properties |

```lua
-- X11 (don't do this)
local handle = io.popen("xrandr | grep ' connected'")

-- Wayland
for s in screen do
    print(s.geometry.width .. "x" .. s.geometry.height)
    for name, output in pairs(s.outputs) do
        print("  Output: " .. name)
    end
end
```

### Window/Client Information

| X11 Pattern | Wayland Alternative |
|-------------|---------------------|
| `io.popen("xdotool")` | `awful.spawn()` or `client:send_key()` |
| `io.popen("xprop")` | `client.class`, `client.instance` |
| `awesome.register_xproperty()` | Not needed on Wayland |

```lua
-- X11 (don't do this)
local handle = io.popen("xprop -id " .. c.window)

-- Wayland
local class = c.class      -- e.g., "firefox"
local instance = c.instance  -- e.g., "Navigator"
```

### Screenshots

| X11 Pattern | Wayland Alternative |
|-------------|---------------------|
| `scrot` | `awful.screenshot` or `grim` |
| `maim` | `awful.screenshot` or `grim` |
| `import` (ImageMagick) | `grim` |

```lua
-- X11 (don't do this)
awful.spawn("scrot ~/screenshot.png")

-- Wayland
awful.screenshot({ directory = "~" })
-- or
awful.spawn("grim ~/screenshot.png")
```

### Input Simulation

| X11 Pattern | Wayland Alternative |
|-------------|---------------------|
| `xdotool key` | Keybindings, or wait for `root.fake_input()` |
| `xdotool mousemove` | Not yet implemented |

:::note
`root.fake_input()` is currently a stub in SomeWM. Virtual input requires wlroots virtual pointer/keyboard protocols which are planned for a future release.
:::

### GTK/GDK via LGI {#gtkgdk-via-lgi}

| Pattern | Severity | Notes |
|---------|----------|-------|
| `lgi.require("Gtk")` | WARNING | Importing it is safe, but anything needing a display returns nil |
| `lgi.require("Gdk")` | CRITICAL | Freezes the compositor the moment the import runs |

Your `rc.lua` runs *inside* the compositor process. GTK and GDK are written to
be Wayland clients: on startup they connect to the display server and wait for
it to answer. That display server is SomeWM, which is busy running your config
and cannot answer until your config returns. It waits for itself, forever.

SomeWM defuses half of this by preloading an empty `lgi.override.Gtk`, so
importing Gtk never calls `gtk_init_check()`. There is no equivalent for Gdk:
`lgi/override/Gdk.lua` calls `Gdk.threads_init()` at import, which connects to
the display and hangs. Recovering means a hard power cycle.

Loading it later does not help. A callback, a signal handler and a timer all
run on the compositor's own thread inside its event loop, so deferring the
import only changes *when* it hangs:

```lua
-- Still freezes: the handler runs inside the compositor
awesome.connect_signal("my::signal", function()
    local Gdk = lgi.require("Gdk", "3.0")
end)
```

What does work is anything that never touches the display. `GdkPixbuf` decodes
images and is safe. Gtk's non-display types are safe. See
[Icon theme lookups](#icon-theme-lookups) for the common case.

### Running a GTK app {#running-a-gtk-app}

| Pattern | Severity |
|---------|----------|
| `Gtk.Application(...)`, `Gtk.Application.new`, `Gtk.main()` | CRITICAL |

A settings window or a preferences dialog written with GTK runs its own main
loop. Started from your config, that loop runs *inside* the compositor and
never returns, so SomeWM stops drawing, stops handling input, and stops
responding to `somewm-client`. There is no keybinding out of it.

```lua
-- Freezes the session the moment the handler runs
local app = Gtk.Application({ application_id = "com.example.settings" })
function app:on_activate() ... end
return app:run()
```

A GTK app has to be its own process, the same as any other Wayland client.
Move the code into a standalone script and spawn it:

```lua
-- settings.lua is a normal Lua script with a #! line, run outside SomeWM
awful.spawn("/usr/share/mywm/settings.lua")
```

The script is usually the file you already have. If it ends in `app:run()` it
is already a complete program; it only needed to stop being `require`d into the
compositor.

### Icon theme lookups {#icon-theme-lookups}

| Pattern | Severity |
|---------|----------|
| `Gtk.IconTheme.get_default()` | WARNING |

`get_default()` returns the icon theme belonging to the default display, so it
needs `gtk_init` to have run. SomeWM skips `gtk_init` on purpose (see
[GTK/GDK via LGI](#gtkgdk-via-lgi)), so `get_default()` returns **nil** and the
next line fails with `attempt to index a nil value`.

Dock, launcher and desktop-icon widgets are the usual casualties, and the error
surfaces far from the cause.

`Gtk.IconTheme.new()` needs no display. It reads the XDG icon directories
directly and works normally:

```lua
local icontheme = Gtk.IconTheme.new()
icontheme:set_custom_theme(beautiful.icons)   -- e.g. "Papirus-Light"

local info = icontheme:lookup_icon("firefox", 64, 0)
local path = info and info:get_filename()
```

`menubar.utils.lookup_icon_uncached(name)` is a pure-Lua fallback when the
theme has no match.

### Client icons {#client-icons}

| Pattern | Severity |
|---------|----------|
| `c.icon`, `awful.widget.clienticon` | INFO |

On X11 a window carries its own icon in the `_NET_WM_ICON` property, so
`c.icon` is almost always set and a tasklist just draws it. Wayland has no
equivalent that SomeWM implements, so `c.icon` is **nil** for native Wayland
clients.

Nothing errors. Every client simply gets whatever fallback your config draws
when the icon is missing, so a dock or tasklist shows the same generic image
for every window.

Resolve the icon from the class instead, which is set for both Wayland and
XWayland clients:

```lua
local icontheme = Gtk.IconTheme.new()
icontheme:set_custom_theme(beautiful.icons)

local function icon_for(class)
    if not class then return nil end
    -- Reverse-DNS classes are common: try "com.mitchellh.ghostty", then "ghostty"
    for _, name in ipairs({ class:lower(), class:lower():match("([^.]+)$") }) do
        local info = icontheme:lookup_icon(name, 64, 0)
        if info and info:get_filename() then return info:get_filename() end
    end
    return menubar.utils.lookup_icon_uncached(class:lower())
end
```

### Xresources and xrdb {#xresources-and-xrdb}

| Pattern | Severity |
|---------|----------|
| `xrdb` | WARNING |

The X resource database belongs to the X server. Without one, `xrdb` has
nothing to write to and nothing reads what it writes. Configs hit this by
generating an `Xresources` file for terminal colours and then calling
`os.execute("xrdb ...")`.

`beautiful.xresources` still works for DPI and for reading values a config
supplies, but there is no live database behind it. Terminal colours belong in
the terminal's own config file, which every Wayland terminal has.


## What Works Unchanged

Most of your config will work without changes:

- **All awful.* modules** - layouts, keybindings, rules, spawn, etc.
- **All gears.* modules** - timers, shapes, filesystem, etc.
- **All wibox.* widgets** - text, image, progressbar, etc.
- **Naughty notifications**
- **Theming** - beautiful.* properties
- **Client rules** - `awful.rules.rules`
- **Signals** - `client.connect_signal()`, `screen.connect_signal()`, etc.

## Automatic Detection

SomeWM will automatically detect and skip configs that contain X11-specific code. If your config is skipped, SomeWM will show a notification explaining which X11 pattern was detected and suggest alternatives.

If you share a config between AwesomeWM and SomeWM, you can detect which compositor is running:

```lua
local is_somewm = awesome.release == "somewm"

if is_somewm then
    awful.spawn("grim ~/screenshot.png")
else
    awful.spawn("scrot ~/screenshot.png")
end
```

## Testing Your Config

1. **Run the compatibility check first:**
   ```bash
   somewm --check ~/.config/awesome/rc.lua
   ```

2. **Fix any CRITICAL issues**

3. **Try loading the config:**
   ```bash
   somewm -c ~/.config/awesome/rc.lua
   ```

4. **Check debug output if needed:**
   ```bash
   somewm -d -c ~/.config/awesome/rc.lua 2>&1 | tee migration.log
   ```

## Common Migration Scenarios

### Autostart Scripts

If you're spawning X11 tools on startup:

```lua
-- X11 (problematic)
awful.spawn.once("xset r rate 200 30")  -- Keyboard repeat

-- Wayland (use awful.input)
awful.input.keyboard_repeat_delay = 200
awful.input.keyboard_repeat_rate = 30
```

### Status Bar with X11 Tools

```lua
-- X11 (won't work)
awful.widget.watch("xbacklight -get", 5, function(widget, stdout)
    widget:set_text(stdout)
end)

-- Wayland (use brightnessctl or similar)
awful.widget.watch("brightnessctl -m | cut -d',' -f4", 5, function(widget, stdout)
    widget:set_text(stdout)
end)
```

## Next Steps

- See [Wayland vs X11](/docs/concepts/wayland-vs-x11) for a deeper understanding of the differences
- Check [AwesomeWM Compatibility](/docs/concepts/awesomewm-compat) for the full compatibility matrix
- Explore [SomeWM-only features](/docs/reference/awful/input) like `awful.input`
