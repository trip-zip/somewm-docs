---
sidebar_position: 2
title: CLI Control
description: Control SomeWM from the command line with somewm-client
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# CLI Control <SomewmOnly />

`somewm-client` is SomeWM's IPC tool for controlling the compositor from scripts and the command line. It communicates with SomeWM via a Unix socket.

:::note
AwesomeWM has its own CLI tool (`awesome-client`), but it uses a different protocol. This guide covers `somewm-client`, which is specific to SomeWM.
:::

:::tip
To try commands without affecting your real session, run them against a nested instance via [Testing with a nested compositor](./testing-with-nested-compositor.md).
:::

## Basic Usage

### Check If Running

```bash
# Prints PONG if SomeWM is running
somewm-client ping
```

### Help

```bash
# Usage and the flag list
somewm-client --help

# Every command registered in this build
somewm-client commands
```

There is no per-group help verb. `somewm-client commands` prints the authoritative list, and the [reference](/docs/reference/somewm-client) documents the arguments.

## Window (Client) Management

### List Windows

```bash
# List all windows with IDs
somewm-client client list
```

Output format:
```
id=1 title="Firefox" class="firefox" tags=1 floating=false
id=2 title="Alacritty" class="Alacritty" tags=1 floating=false
id=3 title="Code - project" class="code" tags=2 floating=false
```

Client IDs are simple integers assigned when windows open. They increment but don't reuse within a session, and reset when the compositor restarts. The `id` property is read-only in Lua (`c.id`).

### Focus Window

```bash
# Focus window by ID
somewm-client client focus 1
```

### Close Window

```bash
# Close window by ID
somewm-client client close 1

# Close focused window
somewm-client client close
```

### Window Properties

These are get-or-set, not toggles. Called with a target alone they report the current value; called with `true`/`1` or `false`/`0` they set it. There is no `toggle` keyword.

```bash
# Read the current value
somewm-client client floating focused

# Set it
somewm-client client floating focused true
somewm-client client fullscreen focused true
somewm-client client maximized 3 false
somewm-client client minimized focused true
somewm-client client ontop focused true
```

The same shape covers `sticky`, `hidden`, `modal`, `focusable`, `urgent`, `above`, `below`, `skip_taskbar`, and the `maximized_horizontal` / `maximized_vertical` pair. To actually toggle, read then write, or use `eval`:

```bash
somewm-client eval "local c = client.focus; if c then c.floating = not c.floating end"
```

## Tag Management

```bash
# View tag by index (1-9)
somewm-client tag view 3

# List all tags
somewm-client tag list

# Toggle tag visibility
somewm-client tag toggle 2
```

`tag view` takes an index, not a name. `somewm-client tag view "web"` fails with `Invalid tag number: web`. Use `tag list` to map names to indices:

```
1: dev [active]
2: web
3: chat
```

## Screen Management

```bash
# List screens
somewm-client screen list

# Get/set scale
somewm-client screen scale           # Get current scale
somewm-client screen scale 1.5       # Set focused screen to 1.5
somewm-client screen scale 1 1.5     # Set screen 1 to 1.5
```

## Input Configuration <SomewmOnly />

Change input settings at runtime without editing rc.lua:

### Pointer Settings

```bash
# Tap to click (0 = off, 1 = on)
somewm-client input tap_to_click 1

# Natural scrolling
somewm-client input natural_scrolling 1

# Pointer speed (-1.0 to 1.0)
somewm-client input accel_speed 0.5

# Left-handed mode
somewm-client input left_handed 1

# Scroll method ("two_finger", "edge", "button", or nil for default)
somewm-client input scroll_method two_finger
```

:::caution
`scroll_button`, `scroll_button_lock`, `dwtp`, and `clickfinger_button_map` exist on the `awful.input` module but are **not** reachable over IPC. `somewm-client input scroll_button 274` fails with `Unknown setting: scroll_button`. Set those in `rc.lua`.
:::

### Keyboard Settings

```bash
# Repeat rate (keys per second)
somewm-client input keyboard_repeat_rate 30

# Repeat delay (milliseconds)
somewm-client input keyboard_repeat_delay 300

# Keyboard layout
somewm-client input xkb_layout "us"

# Layout variant
somewm-client input xkb_variant "dvorak"

# XKB options
somewm-client input xkb_options "ctrl:nocaps"
```

### Query Current Values

```bash
# Get current value (no argument)
somewm-client input tap_to_click
somewm-client input accel_speed
somewm-client input xkb_layout
```

## Screenshots

The path is required; there is no bare `screenshot` command.

```bash
# Whole desktop
somewm-client screenshot save ~/Pictures/shot.png

# Preserve alpha
somewm-client screenshot save ~/Pictures/shot.png --transparent

# One window, or one screen
somewm-client screenshot client ~/Pictures/window.png 3
somewm-client screenshot screen ~/Pictures/screen.png 1

# Pick a region interactively
somewm-client screenshot interactive ~/Pictures/region.png
```

## Session Locking <SomewmOnly />

```bash
somewm-client lock
```

This triggers `awesome.lock()` via IPC. Requires a lock surface to be registered (i.e., `require("lockscreen").init()` must have been called in rc.lua).

## Lua Evaluation

Run arbitrary Lua code in SomeWM's context:

Reach for `eval` only when no dedicated command covers the job. Command output is parseable and survives API changes; `eval` output does neither:

```bash
# Version, focused window, client count: use the commands
somewm-client version
somewm-client client info focused
somewm-client client list | grep -c '^id='

# Move the focused window to tag 2
somewm-client client movetotag 2
```

What `eval` is actually for:

```bash
# Simple expression
somewm-client eval "return 1 + 1"
# Output: 2

# Toggle rather than set, which no command does
somewm-client eval "local c = client.focus; if c then c.floating = not c.floating end"

# Reach state no command exposes
somewm-client eval "return awesome.startup_errors"
```

### Eval for Scripting

Two constraints decide how these get written, and neither announces itself:

- **One line only.** The protocol is one command per line. In a multi-line string only the first line runs and the rest is silently dropped; a string starting with a newline fails with `Missing Lua code to evaluate`. Use semicolons.
- **Only capi globals are in scope.** `client`, `screen`, `tag`, `mouse`, `awesome`, `root`, and `require`. `awful`, `gears`, `beautiful`, `naughty`, `wibox`, and `ruled` are `nil` until you require them.

```bash
# Windows that are floating right now, one per line
somewm-client eval "local r = {}; for _, c in ipairs(client.get()) do if c.floating then table.insert(r, c.id .. ' ' .. (c.name or '')) end end; return table.concat(r, '\n')"

# Anything from the Lua libraries needs a require first
somewm-client eval "local awful = require('awful'); return awful.screen.focused().index"
```

Two more things that bite in scripts:

- Use `c.id`, not `c.window`. `c.window` is an X11 window ID, so it is `0` for native Wayland clients and only meaningful for XWayland ones. `c.id` is what `client list` prints and what every `somewm-client client ...` command accepts.
- Replies begin with an `OK` line and end with a blank line. Filter on the payload (`grep '^id='`) rather than capturing the reply whole.

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | The compositor replied `ERROR`, or the arguments were unusable |
| 2 | Could not connect to the compositor socket (SomeWM not running) |

Use in scripts:

```bash
if somewm-client ping > /dev/null 2>&1; then
    echo "SomeWM is running"
else
    echo "SomeWM is not running"
fi
```

## Scripting Examples

### Rofi Window Switcher

```bash
#!/bin/bash
# window-switcher.sh

# Get window list, dropping the OK line and the trailing blank
windows=$(somewm-client client list | grep '^id=')

# Show in rofi (display full line, return selected)
selected=$(echo "$windows" | rofi -dmenu -p "Window")

if [ -n "$selected" ]; then
    # Extract numeric ID from "id=N ..."
    id=$(echo "$selected" | sed 's/id=\([0-9]*\).*/\1/')
    somewm-client client focus "$id"
fi
```

### Toggle Layout Script

```bash
#!/bin/bash
# toggle-layout.sh

current=$(somewm-client input xkb_layout)

if [ "$current" = "us" ]; then
    somewm-client input xkb_layout "de"
else
    somewm-client input xkb_layout "us"
fi
```

### Polybar Integration

```bash
# In polybar config
[module/layout]
type = custom/script
exec = somewm-client input xkb_layout
interval = 1
click-left = somewm-client input xkb_layout "$([ $(somewm-client input xkb_layout) = 'us' ] && echo 'de' || echo 'us')"
```

### Focus or Launch

```bash
#!/bin/bash
# focus-or-launch.sh <class> <command>

class="$1"
command="$2"

# Check if a window with this class exists, return its ID
window_id=$(somewm-client client list \
    | grep "class=\"$class\"" \
    | head -1 \
    | sed 's/^id=\([0-9]*\).*/\1/')

if [ -n "$window_id" ]; then
    somewm-client client focus "$window_id"
else
    $command &
fi
```

Usage:

```bash
./focus-or-launch.sh Firefox firefox
./focus-or-launch.sh Alacritty alacritty
```

### Workspace Indicator for Status Bars

```bash
#!/bin/bash
# Get current tag info for status bar

somewm-client eval "local awful = require('awful'); local s = awful.screen.focused(); local t = {}; for _, tag in ipairs(s.tags) do table.insert(t, (tag.selected and '*' or '') .. tag.name .. (#tag:clients() > 0 and '+' or '')) end; return table.concat(t, ' ')" | tail -n +2
```

## Troubleshooting

### Connection Failed

```bash
somewm-client ping
# Error: Failed to connect to /run/user/1000/somewm-socket
# Is somewm running?
# connect: No such file or directory
```

Exit code 2. Check that:
1. SomeWM is actually running
2. The socket exists: `ls /run/user/$(id -u)/somewm-*`
3. You're running as the same user as SomeWM
4. `SOMEWM_SOCKET` is unset, or points at the instance you meant

### Command Not Found

```bash
somewm-client foobar
# ERROR Unknown command: foobar
```

Exit code 1. The compositor validates command names, not the binary, so a typo reaches the socket before it is rejected. Check the list:

```bash
somewm-client commands
```

Two-word commands map to one name, so `client foo` is reported as `client.foo`.

### Eval Syntax Errors

```bash
somewm-client eval "return client.focus.name"
# ERROR ./lua/awful/ipc.lua:1845: [string "return client.focus.name"]:1: attempt to index a nil value
```

Nothing was focused, so `client.focus` was nil. Guard it:

```bash
somewm-client eval "return client.focus and client.focus.name or 'none'"
```

Or skip the guard entirely and let the command report it: `client info focused` errors with `No focused client`.

## See Also

- **[somewm-client Reference](/docs/reference/somewm-client)** - Complete command reference
- **[awful.input Reference](/docs/reference/awful/input)** - All input properties
- **[Fractional Scaling](/docs/guides/fractional-scaling)** - Using screen scale commands
