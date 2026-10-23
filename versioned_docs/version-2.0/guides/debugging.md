---
sidebar_position: 3
title: Debugging Your Config
description: Find and fix errors in your Lua configuration
---

# Debugging Your Config

Check the config, reproduce the error in a nested compositor, then inspect its log and runtime state.

## Check Before Loading

```bash
somewm --check ~/.config/somewm/rc.lua
```

The checker parses Lua and scans for recognised compatibility problems and missing imports. It does not execute the config, so a successful check does not prove that widgets, callbacks or application commands work.

The default exit threshold is `warning`. To return a nonzero status only for critical findings:

```bash
somewm --check ~/.config/somewm/rc.lua --check-level=critical
```

Treat severity as the checker's classification, not a guarantee that every reported line will fail or that unreported code is safe.

## Reproduce a Crash in Isolation

```bash
somewm-client test start --name debug --config ~/.config/somewm/rc.lua
somewm-client test logs --name debug -f
```

Use [test mode](testing-with-nested-compositor.md) to keep a compositor crash separate from your desktop. The test config still runs as your user and can modify your files.

## Read Error Notifications

The default config uses `naughty` to display errors. Read the error message and its file and line number first, then the traceback for the callers. If configuration fails before notifications are available, inspect the compositor's terminal output or test log.

## Common Lua Mistakes

<span id="missing-comma" />
<span id="typo-in-module-name" />
<span id="attempt-to-index-a-nil-value" />
<span id="wrong-require-path" />
<span id="theme-variables-silently-nil" />
<span id="calling-a-nil-function" />

| Error or symptom | Check |
| --- | --- |
| `'}' expected` near a table entry | Missing comma or closing brace |
| `module '…' not found` | Module spelling, file location and Lua search path |
| `attempt to index a nil value` | The object exists and the module was required |
| `attempt to call a nil value` | Function spelling and availability in 2.0 |
| Theme values unexpectedly `nil` | `beautiful.init()` ran before the widget module copied those values |

For a file at `~/.config/somewm/widgets/clock.lua`, use:

```lua
local clock = require("widgets.clock")
```

Use dot-separated module names consistently. Check `client.focus` before reading a focused window's properties because focus can be `nil`.

## Use Log Levels

Start a separate instance from a terminal, or use test mode, when changing startup flags:

```bash
somewm --verbose 2>&1 | tee somewm.log
somewm -d 2>&1 | tee somewm-debug.log
```

No flag uses error logging. `--verbose` adds informational messages, and `-d` enables debug logging, including wlroots output. To change the level in a running instance:

```lua
awesome.log_level = "debug"
```

Other accepted values are `"error"` and `"info"`.

## Debug from Lua

<span id="notifications" />
<span id="print-to-stdout" />
<span id="signal-debugging" />

Print values to the compositor log:

```lua
local gears = require("gears")
print("Tag count: " .. #root.tags())
gears.debug.dump({ focused = client.focus and client.focus.name })
```

For a temporary error logger:

```lua
awesome.connect_signal("debug::error", function(err)
    print("Lua error: " .. tostring(err))
end)
```

Remove temporary handlers when finished. Adding another notification handler alongside the default one can produce duplicate alerts.

## Inspect at Runtime

```bash
somewm-client client info focused
somewm-client tag list
somewm-client screen focused
somewm-client eval "return type(require('beautiful'))"
somewm-client eval "return client.focus and client.focus.name or 'none'"
```

`eval` accepts one line. Library locals from `rc.lua` are not in scope, so require modules explicitly. See [CLI Control](cli-control.md) for reply formatting and scripting.

## Safe Reload Workflow

1. Edit the config and run `somewm --check`.
2. Load it in the test instance with `somewm-client test reload --name debug`.
3. Exercise the changed widget, rule or binding and read the log.
4. Reload your desktop with **Mod4+Ctrl+r** after the test succeeds.

Reload rebuilds the Lua state. Do not rely on it to keep the old configuration if the new one fails. The config loader may try fallback configurations, so a changed wallpaper or missing custom bindings can indicate fallback.

### Bisecting Errors

<span id="troubleshooting" />
<span id="config-loads-but-nothing-works" />
<span id="no-error-notification-appears" />
<span id="module-not-found-for-your-own-files" />

Temporarily disable half the relevant code, reload the test instance and repeat with the half containing the failure. Keep required imports and initialisation in place. If the config is version-controlled, use the [test-mode bisect workflow](testing-with-nested-compositor.md#bisect).

## See Also

- [Troubleshooting](../troubleshooting.md)
- [Migrating from AwesomeWM](../getting-started/migrating.md)
- [CLI Control](cli-control.md)
- [FAQ](../faq.md)
