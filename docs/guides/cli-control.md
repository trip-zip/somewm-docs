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
# Returns "pong" if SomeWM is running
somewm-client ping
```

### Help

```bash
# Show all commands
somewm-client help

# Help for specific command group
somewm-client client help
somewm-client input help
```

## Everyday Control

The [somewm-client reference](/docs/reference/somewm-client) documents the full command surface (clients, tags, screens, input, screenshots, session). A taste of what one-liners cover:

```bash
somewm-client client list              # windows with IDs
somewm-client client focus 3           # focus by ID
somewm-client tag view "web"           # switch workspace
somewm-client screen scale 1.5         # set focused screen scale
somewm-client screenshot ~/shot.png    # capture to file
somewm-client lock                     # lock the session
```

`lock` requires a lock surface to be registered (i.e., `require("lockscreen").init()` in rc.lua).

## Tune Input Devices at Runtime <SomewmOnly />

Try input settings live, then persist the keepers in rc.lua:

```bash
somewm-client input tap_to_click 1     # set
somewm-client input accel_speed        # query (no argument)
```

All 24 properties (pointer and keyboard) are listed in the [input commands reference](/docs/reference/somewm-client#input-commands).

## Lua Evaluation

Run arbitrary Lua code in SomeWM's context:

```bash
# Simple expression
somewm-client eval "return 1 + 1"
# Output: 2

# Get focused client name
somewm-client eval "return client.focus and client.focus.name or 'none'"

# Count clients
somewm-client eval "return #client.get()"

# Get awesome version
somewm-client eval "return awesome.version"

# Complex operations
somewm-client eval "client.focus:move_to_tag(awful.screen.focused().tags[2])"

# Multi-statement (use semicolons)
somewm-client eval "local c = client.focus; if c then c.floating = not c.floating end"
```

### Eval for Scripting

```bash
# Get client list as JSON-ish format
somewm-client eval "
local result = {}
for _, c in ipairs(client.get()) do
    table.insert(result, c.window .. ' ' .. c.name)
end
return table.concat(result, '\n')
"
```

## Exit Codes in Scripts

Exit codes distinguish "not running" from "bad command" ([full table](/docs/reference/somewm-client#exit-codes)):

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

# Get window list
windows=$(somewm-client client list)

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

# Check if window with class exists, return its ID
window_id=$(somewm-client eval "
for _, c in ipairs(client.get()) do
    if c.class == '$class' then
        return c.id
    end
end
return nil
")

if [ "$window_id" != "nil" ] && [ -n "$window_id" ]; then
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

somewm-client eval "
local s = awful.screen.focused()
local tags = {}
for _, t in ipairs(s.tags) do
    local prefix = t.selected and '*' or ''
    local suffix = #t:clients() > 0 and '+' or ''
    table.insert(tags, prefix .. t.name .. suffix)
end
return table.concat(tags, ' ')
"
```

## Troubleshooting

### Connection Failed

```bash
somewm-client ping
# Error: Connection failed
```

Check that:
1. SomeWM is actually running
2. The socket exists: `ls /run/user/$(id -u)/somewm-*`
3. You're running as the same user as SomeWM

### Command Not Found

```bash
somewm-client foobar
# Error: Unknown command
```

Check available commands:

```bash
somewm-client help
```

### Eval Syntax Errors

```bash
somewm-client eval "return client.focus.name"
# Error: attempt to index a nil value
```

Always check for nil:

```bash
somewm-client eval "return client.focus and client.focus.name or 'none'"
```

## See Also

- **[somewm-client Reference](/docs/reference/somewm-client)** - Complete command reference
- **[awful.input Reference](/docs/reference/awful/input)** - All input properties
- **[Fractional Scaling](/docs/guides/fractional-scaling)** - Using screen scale commands
