---
sidebar_position: 2
title: CLI Control
description: "somewm-client talks to the compositor over a Unix socket: dedicated commands for clients, tags, screens, input and screenshots, eval for anything else, exit codes for scripts, and the two eval constraints that bite."
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# CLI Control <SomewmOnly />

`somewm-client` sends one command per line to the compositor's socket and prints the reply. It is not `awesome-client`; the protocol is SomeWM's. Against a nested instance, every command takes `test ... --name` ([Testing with a nested compositor](./testing-with-nested-compositor.md)).

```bash
somewm-client ping                          # PONG
somewm-client commands                      # every command this build registers
somewm-client client list                   # windows with ids
somewm-client client info focused           # every property of the focused window
somewm-client client focus 3
somewm-client client movetotag 2
somewm-client client floating focused true  # get or set, not a toggle
somewm-client tag view 2                    # by index, not name
somewm-client screen scale 1.5
somewm-client screenshot save ~/shot.png
somewm-client input tap_to_click 1          # set; no argument queries
somewm-client input                         # every input property with its value
somewm-client lock                          # needs require("lockscreen").init() in rc.lua
```

[somewm-client reference](../reference/somewm-client.md) has every command and argument. Prefer a command to `eval`: its output is parseable and survives API changes.

## eval

```bash
somewm-client eval "return 1 + 1"
somewm-client eval "local c = client.focus; if c then c.floating = not c.floating end"   # a toggle, which no command does
somewm-client eval "return awesome.startup_errors"
```

Two constraints:

- **One line.** Only the first line of a multi-line string runs; a string starting with a newline fails with `Missing Lua code to evaluate`. Join with semicolons.
- **Global scope.** `eval` sees the config’s globals; local variables stay private. Use `require` for libraries kept local by the config.

```bash
somewm-client eval "local awful = require('awful'); return awful.screen.focused().index"
somewm-client eval "local r = {}; for _, c in ipairs(client.get()) do if c.floating then table.insert(r, c.id .. ' ' .. (c.name or '')) end end; return table.concat(r, '\n')"
```

Use `c.id`, which `client list` prints and every `client` command accepts; `c.window` is an X11 id and 0 for Wayland clients. Replies start with an `OK` line and end with a blank one, so filter on the payload (`grep '^id='`) rather than capturing the whole reply.

## Scripts

Exit codes separate not running (2) from a bad command (1) ([table](../reference/somewm-client.md#exit-codes)).

```bash
#!/bin/bash
# focus-or-launch.sh <class> <command>
id=$(somewm-client client list | grep "class=\"$1\"" | head -1 | sed 's/^id=\([0-9]*\).*/\1/')
if [ -n "$id" ]; then somewm-client client focus "$id"; else $2 & fi
```

```bash
#!/bin/bash
# window-switcher.sh
selected=$(somewm-client client list | grep '^id=' | rofi -dmenu -p "Window")
[ -n "$selected" ] && somewm-client client focus "$(echo "$selected" | sed 's/id=\([0-9]*\).*/\1/')"
```

```bash
#!/bin/bash
# toggle-layout.sh
[ "$(somewm-client input xkb_layout | tail -n +2)" = "us" ] && somewm-client input xkb_layout de || somewm-client input xkb_layout us
```

```ini
# polybar
[module/layout]
type = custom/script
exec = somewm-client input xkb_layout | tail -n +2
interval = 1
```

```bash
# tags for a status bar: *selected, +occupied
somewm-client eval "local awful = require('awful'); local t = {}; for _, tag in ipairs(awful.screen.focused().tags) do table.insert(t, (tag.selected and '*' or '') .. tag.name .. (#tag:clients() > 0 and '+' or '')) end; return table.concat(t, ' ')" | tail -n +2
```

## Errors

| Output | Meaning |
| --- | --- |
| `Failed to connect to /run/user/1000/somewm-socket`, exit 2 | not running, a different user, or `SOMEWM_SOCKET` points elsewhere; `ls /run/user/$(id -u)/somewm-*` |
| `ERROR Unknown command: foobar`, exit 1 | the compositor rejected the name; `somewm-client commands` lists them, with `client foo` reported as `client.foo` |
| `ERROR ...: attempt to index a nil value` from `eval "return client.focus.name"` | nothing focused; `client.focus and client.focus.name or 'none'`, or `client info focused`, which reports `No focused client` |
