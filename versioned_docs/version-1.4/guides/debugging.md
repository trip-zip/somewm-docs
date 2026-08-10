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

## Reproduce a Crash in Isolation

If your config loads but crashes at runtime, a nested test instance is a fast way to reproduce without taking down your real session. See [Testing with a nested compositor](./testing-with-nested-compositor.md):

```bash
somewm-client test start --config ~/.config/somewm/rc.lua
somewm-client test logs -f
```

The nested compositor's log is in its state directory; tailing it shows the same error trace you'd see in your real session, but the crash doesn't affect your desktop.

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

### Theme Variables Silently Nil

Unlike the errors above, this one produces no message at all. A module required before `beautiful.init()` reads `nil` for every theme variable, and values copied at require time stay `nil` after `init()` runs:

```lua
-- widgets/clock.lua, required BEFORE beautiful.init() in rc.lua
local beautiful = require("beautiful")
local bg = beautiful.bg_normal   -- nil, no error; stays nil forever
```

Quick probe: add `print(beautiful.bg_normal)` at the top of the module and check the log. If it prints `nil`, move the module's `require` below `beautiful.init()` in your `rc.lua`.

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

### Print to stdout

`print()` writes to standard output, which appears in your terminal or log file:

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

`somewm-client` queries the running compositor without touching your config. Most of what you want to know has a dedicated command:

```bash
# The focused window: class, title, geometry, every property
somewm-client client info focused

# Tags on the focused screen, with the selected one marked
somewm-client tag list

# Screen geometry and current layout
somewm-client screen focused
```

Fall back to `eval` for state no command exposes:

```bash
# Check if a module loaded correctly
somewm-client eval "return type(require('beautiful'))"
```

`eval` runs one line at a time (use semicolons, not newlines) and sees only the capi globals: `client`, `screen`, `tag`, `mouse`, `awesome`, `root`, and `require`. `awful`, `beautiful`, `gears`, and the rest are `nil` until required, so `type(beautiful)` reports `nil` whether or not the module loaded.

This is invaluable for testing changes before editing your config file. See [CLI Control](/docs/guides/cli-control) for more.

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

- **[Troubleshooting](/docs/troubleshooting)** - Solutions for specific known issues
- **[Migrating from AwesomeWM](/docs/getting-started/migrating)** - X11-specific errors
- **[CLI Control](/docs/guides/cli-control)** - Full `somewm-client` usage for runtime inspection
- **[FAQ](/docs/faq)** - Common questions
