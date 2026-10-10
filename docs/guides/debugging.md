---
sidebar_position: 3
title: Debugging Your Config
description: Check a config before loading, read the error notification, the Lua mistakes that account for most failures, log levels, printing from Lua, and inspecting the running compositor with somewm-client.
---

# Debugging Your Config

A config error at load falls back to the bundled config and shows a notification with the message, the file and line, and a stack trace. Read the trace from the bottom: the last line is where it failed. A reload that fails keeps the previous config running.

## Before loading {#check-before-loading}

```bash
somewm --check ~/.config/somewm/rc.lua
```

Reports syntax errors, missing modules and X11-only patterns by severity ([Migrating](../getting-started/migrating.md#check-first) explains the report). A runtime crash reproduces safely in a nested instance:

```bash
somewm-client test start --config ~/.config/somewm/rc.lua
somewm-client test logs -f
```

## The usual mistakes

| Error | Cause | Fix |
| --- | --- | --- |
| `'}' expected (to close '{' at line N) near '"4"'` | a missing comma in a table | `{ "1", "2", "web", "4" }` |
| `module 'beautful' not found` | a misspelled `require` | |
| `attempt to index a nil value (global 'beautiful')` | used before `require` | `local beautiful = require("beautiful")` first |
| `module 'widgets/clock' not found` | a slash in a module path | `require("widgets.clock")`, relative to the config directory |
| `attempt to call a nil value (field 'onse')` | a misspelled function | `awful.spawn.once` |
| no error; a widget ignores the theme | its module was required before `beautiful.init()`, so every theme value it read is nil | move the `require` below `init`; `print(beautiful.bg_normal)` at the module's top confirms it |

## Log levels

| Flag | Shows |
| --- | --- |
| none | errors |
| `--verbose` | plus info |
| `-d` | everything |

```bash
somewm --verbose 2>&1 | tee somewm.log
WLR_DEBUG=1 somewm -d 2>&1 | tee somewm.log     # wlroots too: outputs, input devices, rendering
```

`awesome.log_level = "debug"` sets it from `rc.lua`. Under `somewm-session` the log is `journalctl --user -u somewm.service`.

## From Lua

```lua
naughty.notification { title = "Debug", message = tostring(client.focus and client.focus.class) }
print("Tag count: " .. #root.tags())        -- stdout, so the terminal or the journal
gears.debug.dump(client.focus)              -- pretty-prints a table
awesome.connect_signal("debug::error", function(err)
    naughty.notification { preset = naughty.config.presets.critical, title = "Error", message = tostring(err) }
end)
```

## The running compositor

```bash
somewm-client client info focused     # every property of the focused window
somewm-client tag list
somewm-client screen focused
somewm-client eval "return type(require('beautiful'))"
```

`eval` runs one line and sees only `client`, `screen`, `tag`, `mouse`, `awesome`, `root` and `require`; `awful` and the rest are nil until required ([CLI Control](/docs/guides/cli-control)).

## Narrowing it down

Edit, `somewm --check`, Mod4 + Ctrl + r, watch for the notification. If the error is not obvious, comment out half the config with `--[[ ... --]]`, reload, and halve again until the line is found.

- Your customisations gone after a reload: the config failed and the bundled one loaded. Start with `--verbose` to see why.
- No notification at all: the config failed before `naughty` loaded. Run from a terminal.
- `module not found` for your own file: it must be under the config directory and required with dots.

[Troubleshooting](/docs/troubleshooting) has specific known issues.
