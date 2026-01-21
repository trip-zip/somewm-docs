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

```bash
# Toggle floating
somewm-client client floating toggle

# Toggle fullscreen
somewm-client client fullscreen toggle

# Toggle maximized
somewm-client client maximized toggle

# Toggle minimized
somewm-client client minimized toggle

# Toggle ontop
somewm-client client ontop toggle
```

## Tag Management

```bash
# View tag by index (1-9)
somewm-client tag view 3

# View tag by name
somewm-client tag view "web"

# List all tags
somewm-client tag list

# Toggle tag visibility
somewm-client tag toggle 2
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
somewm-client input pointer_speed 0.5

# Left-handed mode
somewm-client input left_handed 1

# Scroll method (0 = none, 1 = two-finger, 2 = edge, 3 = button)
somewm-client input scroll_method 1

# Scroll button (for button scroll)
somewm-client input scroll_button 274
```

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
somewm-client input pointer_speed
somewm-client input xkb_layout
```

## Screenshots

```bash
# Take screenshot of focused screen
somewm-client screenshot

# Save to specific path
somewm-client screenshot ~/Pictures/shot.png
```

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

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Connection failed (SomeWM not running) |
| 2 | Command not found |
| 3 | Invalid arguments |
| 4 | Command execution failed |

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

- **[somewm-client Reference](/reference/somewm-client)** - Complete command reference
- **[awful.input Reference](/reference/awful/input)** - All input properties
- **[Fractional Scaling](/guides/fractional-scaling)** - Using screen scale commands
