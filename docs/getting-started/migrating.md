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
awful.input.repeat_delay = 200
awful.input.repeat_rate = 30
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

- See [Wayland vs X11](/concepts/wayland-vs-x11) for a deeper understanding of the differences
- Check [AwesomeWM Compatibility](/concepts/awesomewm-compat) for the full compatibility matrix
- Explore [SomeWM-only features](/reference/awful/input) like `awful.input`
