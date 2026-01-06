---
sidebar_position: 2
title: somewm-client Reference
description: Complete command reference for the somewm-client IPC tool
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# somewm-client Reference <SomewmOnly />

IPC command-line tool for controlling SomeWM. This is SomeWM's equivalent to AwesomeWM's `awesome-client`, but uses a different protocol and command set.

## Usage

```bash
somewm-client <command> [arguments...]
```

## General Commands

| Command | Description |
|---------|-------------|
| `ping` | Check if SomeWM is running |
| `version` | Show SomeWM version |
| `eval <code>` | Evaluate Lua code and return result |

## Client Commands {#client-commands}

Commands for window management.

| Command | Description |
|---------|-------------|
| `client list` | List all clients (windows) |
| `client focus <id>` | Focus client by ID |
| `client close <id>` | Close client by ID |
| `client minimize <id>` | Minimize client |
| `client maximize <id>` | Maximize client |
| `client fullscreen <id>` | Toggle fullscreen |
| `client floating <id>` | Toggle floating |
| `client ontop <id>` | Toggle always-on-top |
| `client sticky <id>` | Toggle sticky (visible on all tags) |

## Tag Commands

| Command | Description |
|---------|-------------|
| `tag list` | List all tags |
| `tag view <name>` | View tag by name |
| `tag viewidx <n>` | View tag by index (1-based) |

## Screen Commands

| Command | Description |
|---------|-------------|
| `screen list` | List all screens |
| `screen focus <n>` | Focus screen by index |

## Input Commands {#input-commands}

Commands for input device configuration.

| Command | Description |
|---------|-------------|
| `input <property>` | Get input property value |
| `input <property> <value>` | Set input property value |

Available properties: `tap_to_click`, `natural_scrolling`, `pointer_speed`, `scroll_button`, `left_handed`, `repeat_rate`, `repeat_delay`, `xkb_layout`, `xkb_variant`, `xkb_options`

## Screenshot Commands

| Command | Description |
|---------|-------------|
| `screenshot` | Take full screenshot |
| `screenshot <filename>` | Save screenshot to file |

## Examples

```bash
# Check connection
somewm-client ping

# List windows
somewm-client client list

# Enable tap-to-click
somewm-client input tap_to_click 1

# Evaluate Lua
somewm-client eval "return client.focus and client.focus.name"

# View tag 3
somewm-client tag viewidx 3
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Connection failed |
| 2 | Command failed |
| 3 | Invalid arguments |

## See Also

- [CLI Control Guide](/guides/cli-control)
