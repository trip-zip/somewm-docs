---
sidebar_position: 2
title: Control SomeWM from the command line
description: Control SomeWM from the command line with somewm-client
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Control SomeWM from the command line <SomewmOnly />

Run `somewm-client` inside your SomeWM session to inspect or change compositor state. To keep experiments separate from your desktop, use a [nested instance](testing-with-nested-compositor.md).

## Basic Usage

```bash
somewm-client ping
somewm-client --help
somewm-client commands
```

`ping` returns `PONG`. `commands` lists the commands registered by the running compositor. There is no per-group help command. See the [command reference](../reference/somewm-client.md) for arguments.

## Window (Client) Management

```bash
somewm-client client list
somewm-client client info focused
somewm-client client focus 1
```

Replace `1` with an ID from `client list`. IDs are unique within a compositor session and exposed in Lua as `c.id`. Do not use `c.window`, which is an X11 ID and is zero for native Wayland clients.

To request that the focused application close:

```bash
somewm-client client close focused
```

### Window Properties

A target alone reads a property. Add `true`/`1` or `false`/`0` to set it:

```bash
somewm-client client floating focused
somewm-client client floating focused true
somewm-client client fullscreen focused false
somewm-client client maximized focused true
somewm-client client minimized focused false
somewm-client client ontop focused true
```

The same form applies to properties such as `sticky`, `hidden`, `urgent`, `above` and `below`. There is no `toggle` value. Use Lua for a toggle:

```bash
somewm-client eval "local c = client.focus if c then c.floating = not c.floating end"
```

## Tag Management

```bash
somewm-client tag list
somewm-client tag view 3
somewm-client tag toggle 2
somewm-client client movetotag 2
```

Tag commands take indices on the focused screen, not names. Use `tag list` to find the index. `client movetotag` moves the focused client unless given a client ID.

## Screen Management

```bash
somewm-client screen list
somewm-client screen scale
somewm-client screen scale 1 1.5
```

The last command sets screen 1 to scale `1.5`. Use two arguments when setting scale to avoid ambiguity. See [fractional scaling](fractional-scaling.md).

## Input Configuration <SomewmOnly />

```bash
somewm-client input tap_to_click 1
somewm-client input natural_scrolling 1
somewm-client input accel_speed 0.5
somewm-client input left_handed 0
somewm-client input scroll_method two_finger
somewm-client input keyboard_repeat_rate 30
somewm-client input keyboard_repeat_delay 300
somewm-client input xkb_layout us
somewm-client input xkb_variant dvorak
somewm-client input xkb_options ctrl:nocaps
```

Omit the value to query a setting. Changes apply at runtime but are not written to `rc.lua`. `scroll_button`, `scroll_button_lock`, `dwtp` and `clickfinger_button_map` must be set through `awful.input` in Lua because the IPC commands do not expose them.

## Screenshots

Create the destination directory, then provide an absolute path:

```bash
somewm-client screenshot save ~/Pictures/shot.png
somewm-client screenshot save ~/Pictures/alpha.png --transparent
somewm-client screenshot screen ~/Pictures/screen.png 1
somewm-client screenshot client ~/Pictures/window.png
somewm-client screenshot interactive ~/Pictures/region.png
```

See [Screenshots](screenshots.md) for capture behaviour and bindings.

## Session Locking <SomewmOnly />

```bash
somewm-client lock
```

This calls `awesome.lock()`. Initialise the [lockscreen](lockscreen.md) in `rc.lua` first.

## Lua Evaluation

<span id="eval" />

Use `eval` for state or operations without a dedicated command:

```bash
somewm-client eval "return 1 + 1"
somewm-client eval "return awesome.startup_errors"
somewm-client eval "return require('awful').screen.focused().index"
```

`eval` accepts one line. Newlines split protocol commands, so keep the Lua argument on one line or use `dofile()` with an absolute script path. Lua does not require statement separators in the examples above.

C API globals such as `client`, `screen`, `awesome` and `root` are available. Locals from `rc.lua`, including its library imports, are not. Require modules explicitly.

### Eval for Scripting

Replies start with an `OK` line and end with a blank line. Extract the payload before comparing it:

```bash
#!/bin/sh
current=$(somewm-client input xkb_layout | sed -n '2p')
if [ "$current" = us ]; then
    somewm-client input xkb_layout de
else
    somewm-client input xkb_layout us
fi
```

This switches the configured layout between `us` and `de`. For cycling within a configured group list, use [Keyboard Layout Switching](keyboard-layouts.md).

## Exit Codes

| Code | Meaning |
| --- | --- |
| `0` | Successful command |
| `1` | Invalid arguments or an `ERROR` reply |
| `2` | Could not connect to the compositor socket |

Use `assert()` to fail an evaluation. Returning `false` is still success.

## Scripting Examples

<span id="scripts" />

### Rofi Window Switcher

With a working Rofi installation:

```bash
#!/bin/sh
windows=$(somewm-client client list | grep '^id=')
selected=$(printf '%s\n' "$windows" | rofi -dmenu -p Window)
if [ -n "$selected" ]; then
    id=$(printf '%s\n' "$selected" | sed 's/^id=\([0-9]*\).*/\1/')
    somewm-client client focus "$id"
fi
```

### Focus or Launch

Save this as an executable `focus-or-launch.sh`. Pass the exact class from `client list`, followed by the executable and its arguments:

```bash
#!/bin/sh
class=$1
shift
window_id=$(somewm-client client list \
    | grep -F "class=\"$class\"" \
    | sed -n '1s/^id=\([0-9]*\).*/\1/p')
if [ -n "$window_id" ]; then
    somewm-client client focus "$window_id"
else
    "$@" &
fi
```

Example: `./focus-or-launch.sh firefox firefox`. The list format is intended for inspection and simple scripts. A title containing text that resembles a class field can confuse this text filter. For more complex matching, use a Lua client matcher.

## Troubleshooting

<span id="errors" />

### Connection Failed

Check that SomeWM is running and you are the same user. `SOMEWM_SOCKET` must be unset or point to the intended instance. Test mode uses its own socket, so use `test eval --name NAME` for a named test instance.

### Command Not Found

Run `somewm-client commands` to check the name. Two-word commands appear with dots, such as `client.list`.

### Eval Syntax Errors

Check that the Lua argument is one line and that shell quoting preserves it. For errors about a nil focused client, guard the lookup:

```bash
somewm-client eval "return client.focus and client.focus.name or 'none'"
```

## See Also

- [Command Reference](../reference/somewm-client.md)
- [Input Reference](../reference/awful/input.md)
- [Fractional Scaling](fractional-scaling.md)
