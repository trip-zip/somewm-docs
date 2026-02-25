---
sidebar_position: 3
title: Debugging Your Config
description: Find and fix errors in your Lua configuration
---

# Debugging Your Config

When your config breaks, SomeWM gives you several tools to find and fix the problem. This guide walks through the debugging workflow from quick checks to runtime inspection.

## Check Before Loading

`somewm --check` validates your config without starting the compositor. It catches syntax errors, missing modules, and X11-specific patterns:

```bash
somewm --check ~/.config/somewm/rc.lua
```

Example output:

```
somewm config compatibility report
====================================
Config: /home/user/.config/somewm/rc.lua

X CRITICAL:
  rc.lua:45 - io.popen with xrandr (blocks)
    → Use screen:geometry() or screen.outputs instead

! WARNING:
  rc.lua:112 - maim screenshot tool
    → Use awful.screenshot or grim instead

Summary: 1 critical, 1 warning
```

Issues are categorized by severity:
- **CRITICAL** - Will fail or hang. Must fix before loading.
- **WARNING** - Needs a Wayland alternative but won't crash.
- **INFO** - May not work but won't break anything.

To only fail on critical issues:

```bash
somewm --check ~/.config/somewm/rc.lua --check-level=critical
```

## Read Error Notifications

When SomeWM loads a config with runtime errors, it falls back to the default config and shows an error notification. The notification contains:

- The **error message** (e.g., `attempt to index a nil value`)
- The **file and line number** where it happened
- A **stack trace** showing the call chain

Read the error from the bottom up. The last line in the trace is where the error occurred. The lines above show how the code got there.

## Common Lua Mistakes

Most config errors fall into a few categories:

### Missing Comma

The most frequent mistake. Lua table entries need commas between them:

```lua
-- Broken: missing comma after "web"
awful.tag({ "1", "2", "web" "4" }, s, awful.layout.suit.tile)

-- Fixed
awful.tag({ "1", "2", "web", "4" }, s, awful.layout.suit.tile)
```

The error message for this is often cryptic: `'}' expected (to close '{' at line X) near '"4"'`.

### Typo in Module Name

A misspelled `require` or module path gives `module 'X' not found`:

```lua
-- Broken
local beautful = require("beautful")  -- typo: missing 'i'

-- Fixed
local beautiful = require("beautiful")
```

### Attempt to Index a Nil Value

This means you're trying to use a table or object that doesn't exist:

```lua
-- Broken: 'beautiful' was never required
beautiful.font = "monospace 12"
-- Error: attempt to index a nil value (global 'beautiful')

-- Fixed: require it first
local beautiful = require("beautiful")
beautiful.font = "monospace 12"
```

### Wrong Require Path

Custom modules need the right path relative to your config directory:

```lua
-- If your file is at ~/.config/somewm/widgets/clock.lua
local clock = require("widgets.clock")   -- Correct
local clock = require("widgets/clock")   -- Wrong: use dots, not slashes
local clock = require("clock")           -- Wrong: missing directory
```

### Calling a Nil Function

Happens when a function name is misspelled or the module doesn't export it:

```lua
-- Broken
awful.spawn.onse("nm-applet")  -- typo: "onse" not "once"

-- Fixed
awful.spawn.once("nm-applet")
```

The error: `attempt to call a nil value (field 'onse')`.

## Use Log Levels

SomeWM has three log levels for progressively more detail:

| Flag | Level | When to use |
|------|-------|-------------|
| (none) | error | Normal use. Shows only errors. |
| `--verbose` | info | First debugging step. Adds informational messages. |
| `-d` | debug | Deep debugging. Shows everything. |

```bash
# Start with verbose
somewm --verbose 2>&1 | tee somewm.log

# If you need more detail
somewm -d 2>&1 | tee somewm.log
```

You can also set the log level at runtime in your `rc.lua`:

```lua
awesome.log_level = "debug"  -- "error", "info", or "debug"
```

For wlroots-level issues (display detection, input devices, rendering), add:

```bash
WLR_DEBUG=1 somewm -d 2>&1 | tee somewm.log
```

## Debug from Lua

### Notifications

The quickest way to inspect values at runtime:

```lua
local naughty = require("naughty")

naughty.notify {
    title = "Debug",
    text = tostring(client.focus and client.focus.class or "no focus"),
}
```

### Print to stderr

`print()` writes to standard error, which appears in your terminal or log file:

```lua
print("Tag count: " .. tostring(#root.tags()))

-- For tables, use gears.debug
local gears = require("gears")
gears.debug.dump(client.focus)  -- Pretty-prints a table
```

### Signal Debugging

Listen for error signals to catch issues as they happen:

```lua
awesome.connect_signal("debug::error", function(err)
    naughty.notify {
        preset = naughty.config.presets.critical,
        title = "Error",
        text = tostring(err),
    }
end)
```

## Inspect at Runtime

Use `somewm-client` to evaluate Lua expressions against the running compositor:

```bash
# Check the focused window
somewm-client eval 'return client.focus and client.focus.class'

# List all tags on the current screen
somewm-client eval 'local t = {}; for _, tag in ipairs(awful.screen.focused().tags) do table.insert(t, tag.name) end; return table.concat(t, ", ")'

# Check if a module loaded correctly
somewm-client eval 'return type(beautiful)'

# Get screen geometry
somewm-client eval 'local s = awful.screen.focused(); return s.geometry.width .. "x" .. s.geometry.height'
```

This is invaluable for testing changes before editing your config file. See [CLI Control](/guides/cli-control) for more.

## Safe Reload Workflow

The recommended cycle for making config changes:

1. **Edit** your config in a terminal editor
2. **Check** for syntax errors: `somewm --check ~/.config/somewm/rc.lua`
3. **Reload** with `Mod4 + Ctrl + r`
4. **Watch** for error notifications

If the reload fails, SomeWM keeps the previous working config. You won't lose your session. Fix the error and reload again.

### Bisecting Errors

If you can't find the error, narrow it down by commenting out sections:

```lua
-- Comment out half your rules
--[[
ruled.client.append_rule {
    ...
}
--]]
```

Reload after each change. When the error disappears, the problem is in the section you just commented out. Uncomment half of that section and repeat until you find the exact line.

## Troubleshooting

### Config Loads but Nothing Works

Check if SomeWM fell back to the default config. The default config has a different wallpaper and default keybindings. If your customizations are gone, your config failed to load. Check the error notification or start with `--verbose` to see what happened.

### No Error Notification Appears

If the config fails very early (before naughty loads), you won't see a notification. Run from a terminal to see the error:

```bash
somewm --verbose 2>&1 | tee somewm.log
```

### "Module not found" for Your Own Files

Make sure your module files are in the config directory and use dot-separated paths:

```
~/.config/somewm/
    rc.lua
    theme.lua
    widgets/
        clock.lua
        battery.lua
```

```lua
-- In rc.lua
local clock = require("widgets.clock")
local battery = require("widgets.battery")
```

## See Also

- **[Troubleshooting](/troubleshooting)** - Solutions for specific known issues
- **[Migrating from AwesomeWM](/getting-started/migrating)** - X11-specific errors
- **[CLI Control](/guides/cli-control)** - Full `somewm-client` usage for runtime inspection
- **[FAQ](/faq)** - Common questions
