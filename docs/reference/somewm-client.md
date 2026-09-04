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
somewm-client [--json] <command> [arguments...]
```

`somewm-client` is a thin passthrough. It joins its arguments into one line, writes that to the compositor's Unix socket, and prints the reply. Command names are validated by the compositor, not the binary, so an unknown command comes back as `ERROR Unknown command: ...` rather than a usage error.

More than 100 commands are registered. This page documents them by family. Run `somewm-client commands` for the authoritative list in your build. Last synced against the SomeWM source: `07feca28f`.

### Global flags

| Flag | Description |
|------|-------------|
| `--help`, `-h` | Print usage and exit. |
| `--json` | Wrap the reply in a JSON envelope. Must come before the command. |
| `--subscribe [types...]` | Hold the connection open and stream events. See [Event Subscription](#events). |
| `--completions <shell>` | Print shell completions for `bash`, `zsh`, or `fish`. |

### Socket

The compositor listens on `$XDG_RUNTIME_DIR/somewm-socket`. Set `SOMEWM_SOCKET` to target a different instance, which is what [test mode](#test-mode) does for nested compositors.

### Response format

Replies are line-oriented text terminated by a blank line:

```
OK
id=1 title="tmux a" class="com.mitchellh.ghostty" tags=1 floating=false
```

Failures replace `OK` with `ERROR` and a message:

```
ERROR Unknown command: client.minimize
```

With `--json`, the reply becomes a single object. Note that `result` is the same text blob as the plain-mode output, escaped into one string. Handlers do not return structured data, so `--json` gives you a wrapper to test `status` against, not per-object fields to index:

```bash
somewm-client --json client visible
```

```json
{"result":"id=1 title=\"tmux a\" class=\"com.mitchellh.ghostty\"","status":"ok"}
```

## General Commands

| Command | Description |
|---------|-------------|
| `ping` | Check if SomeWM is running |
| `version` | Show compositor version information |
| `commands` | List every registered command name in this build |
| `exec <command...>` | Spawn a process |
| `notify <message> [opts]` | Send a notification. Options: `--title T`, `--timeout N` (seconds, default 5), `--urgency U` (default `normal`) |
| `hotkeys` | Show the hotkeys popup |
| `menubar`, `launcher` | Show the menubar application launcher (`launcher` is an alias) |
| `eval <code>` | Evaluate Lua code and return the result |

Reach for `eval` only when no dedicated command covers what you need. The commands below return parseable output and survive API changes; `eval` does neither.

### `eval` constraints

Two limits catch people out, and neither produces an obvious error.

**One line only.** The protocol is one command per line, so a multi-line argument does not do what it looks like. Only the first line runs; the rest is discarded. A string that opens with a newline fails outright with `Missing Lua code to evaluate`. Separate statements with semicolons:

```bash
somewm-client eval "local x = 1; return x + 1"   # 2
```

**Only capi globals are in scope.** `client`, `screen`, `tag`, `mouse`, `awesome`, `root`, and `require` are available. The Lua libraries are not: `awful`, `gears`, `beautiful`, `naughty`, `wibox`, and `ruled` are all `nil` unless you require them.

```bash
somewm-client eval "return type(beautiful)"            # nil, always
somewm-client eval "return type(require('beautiful'))" # table
```

This makes `type(<module>)` useless as a did-it-load check unless the name is required first.

## Client Commands {#client-commands}

Client IDs are simple integers (1, 2, 3...) assigned when windows open. IDs increment but don't reuse within a session, and reset when the compositor restarts.

Most client commands take a target of either a numeric ID or the literal `focused`, and default to `focused` when the argument is omitted. The exception is `client focus`, which is a setter and rejects `focused`.

### Queries

| Command | Description |
|---------|-------------|
| `client list` | List all clients on all screens |
| `client info [<id>\|focused]` | Full detail for one client: title, class, instance, role, type, PID, geometry, tags, and every boolean property |
| `client visible` | List clients visible on the focused screen's tags |
| `client tiled` | List non-floating clients on the focused screen |
| `client master` | The master client on the focused screen |

`client list` prints one line per window:

```
id=1 title="tmux a" class="com.mitchellh.ghostty" tags=1 floating=false
id=2 title="Hacker News — Mozilla Firefox" class="firefox" tags=1 floating=false
```

`client visible` and `client tiled` use the same shape without `tags=` and `floating=`. `client info` prints one `Key: value` per line:

```
ID: 2
Title: Hacker News — Mozilla Firefox
Class: firefox
Instance:
Role:
Type: normal
PID: 3335459
Geometry: x=4040 y=40 width=1708 height=2108
Screen: 2
Tags: 1
Floating: false
...
```

`Class` is the Wayland app_id, which is what a `ruled.client` rule's `class` matcher compares against.

### Focus and lifecycle

| Command | Description |
|---------|-------------|
| `client focus <id\|next\|prev\|up\|down\|left\|right>` | Focus by ID, by stack order, or by direction. Required argument; `focused` is rejected |
| `client close [<id>\|focused]` | Close gracefully |
| `client kill [<id>\|focused] [--force]` | Kill the client |

### Boolean properties

Each of these gets the current value when called with no value, and sets it when passed `true`/`1` or `false`/`0`. They are not toggles.

```bash
somewm-client client floating focused        # get
somewm-client client floating focused true   # set
```

`floating`, `fullscreen`, `sticky`, `ontop`, `minimized`, `maximized`, `maximized_horizontal`, `maximized_vertical`, `hidden`, `modal`, `focusable`, `urgent`, `above`, `below`, `skip_taskbar`

`client opacity [<id>\|focused] [0.0-1.0]` follows the same get-or-set shape.

### Geometry and placement

| Command | Description |
|---------|-------------|
| `client geometry [<id>\|focused] [x y w h]` | Get or set geometry |
| `client move [<id>\|focused] <x> <y>` | Move to an absolute position |
| `client resize [<id>\|focused] <w> <h>` | Resize |
| `client moveresize [<id>\|focused] <dx> <dy> <dw> <dh>` | Move and resize relatively |
| `client center [<id>\|focused]` | Center on its screen |
| `client placement <func> [<id>\|focused]` | Apply a placement function: `no_offscreen`, `no_overlap`, `under_mouse`, `next_to_mouse`, `maximize`, `stretch`, `centered`, `top_left`, `top_right`, `bottom_left`, `bottom_right` |

### Stacking, tags, and screens

| Command | Description |
|---------|-------------|
| `client raise [<id>\|focused]` | Raise to the top of the stack |
| `client lower [<id>\|focused]` | Lower to the bottom |
| `client swap <id1> <id2>` | Swap two clients in the stack |
| `client swapidx <±n> [<id>\|focused]` | Swap with the nth client in the stack |
| `client zoom [<id>\|focused]` | Swap with the master client |
| `client movetotag <n> [<id>]` | Move to exactly one tag, clearing the others |
| `client toggletag <n> [<id>]` | Toggle one tag on the client |
| `client movetoscreen <screen> [<id>]` | Move to another screen |

## Tag Commands

| Command | Description |
|---------|-------------|
| `tag list` | List the focused screen's tags |
| `tag current` | Comma-separated indices of the selected tags |
| `tag view <n>` | Switch to tag *n*. Takes an index, not a name |
| `tag toggle <n>` | Toggle tag *n*'s visibility |
| `tag add <name> [screen]` | Create a tag |
| `tag delete <name\|index>` | Delete a tag |
| `tag rename <old> <new>` | Rename a tag |
| `tag screen <name> [screen]` | Get or move a tag's screen |
| `tag swap <tag1> <tag2>` | Swap two tags |
| `tag layout <name\|index> [layout]` | Get or set a tag's layout |
| `tag gap <name\|index> [pixels]` | Get or set a tag's useless gap |
| `tag mwfact <name\|index> [factor]` | Get or set the master width factor |

`tag list` marks the selected tag:

```
1: dev [active]
2: web
3: chat
```

## Layout Commands

| Command | Description |
|---------|-------------|
| `layout list` | List the layouts available to the current tag |
| `layout get` | Current layout name |
| `layout set <name\|index>` | Set the layout |
| `layout next` | Cycle to the next layout |
| `layout prev` | Cycle to the previous layout |

## Screen and Output Commands

| Command | Description |
|---------|-------------|
| `screen list` | List all screens |
| `screen focused` | Info for the focused screen |
| `screen count` | Number of screens |
| `screen focus <id\|next\|prev>` | Focus a screen |
| `screen clients <id>` | List clients on a screen |
| `screen scale [screen] [value]` | Get or set fractional scale |
| `output list` | List outputs and their enabled state |

```
screen=1 geometry=1920x1280+0+0 tags=2 layout="tile" focused=false
screen=2 geometry=3840x2160+1920+0 tags=1 layout="tile" focused=true
```

See [Fractional Scaling](../guides/fractional-scaling.md) for `screen scale` in context.

## Clay Tree

| Command | Description |
|---------|-------------|
| `clay tree [screen]` | Dump the last solved Clay tree for every output, or only the numbered screen |

Every output has a desktop band, and a second one while the session is locked. Each band starts with its last command, mutation, retained-node, raster-byte, and buffer counters, followed by the declare, solve, and reconcile durations. Nodes follow in draw order with their solved and realized boxes and the client, border, drawin, layer-shell namespace, widget class, or raster leaf they represent. `[solved!=realized]` marks clipping. `[tree!=scene]` reports that a retained scene node disagrees with its realized box.

After the nodes, each band lists the drawins it draws. A drawin whose widget tree was converted prints that tree, one line per widget, indented by depth: the element id, the class, the size the tree asked for on each axis, and the box Clay solved. A container that paints no color is in this tree and in none of the node lines above, because a solved element only becomes a render command when it has something to draw. That is why the tree is printed separately from the commands.

A drawin that paints all of its own pixels with cairo instead says `whole:` and names why. The reasons are `shape_bounding`, `shape_clip` and `shape_input` for the three shape masks, `opacity` for a translucent drawin, `systray` for the host of the legacy tray, `nothing converted` when no widget in the tree could be expressed, and `over the output's element budget` for a tree too large to declare.

```bash
somewm-client clay tree
somewm-client clay tree 2
```

```
output DP-1 band desktop scale 1.00
  commands 6 mutations 0 nodes 6 raster_bytes 122880 buffers 0 declare 42us solve 14us reconcile 3us
  4bf820d0 BORDER        z=-    box 0,0 208x208 rbox 0,0 208x208 client kitty
  360c5f60 CUSTOM        z=-    box 0,0 208x208 rbox 0,0 208x208 client kitty
  c802045e RECTANGLE     z=100  box 0,0 1280x24 rbox 0,0 1280x24 drawin screen 1 1280x24+0+0
  a53fd76b IMAGE         z=-    box 0,0 16x24 rbox 0,0 16x24 widget wibox.widget.textbox raster raster=1536
  drawin screen 1 1280x24+0+0 converted: 4 nodes, 1 raster
    c802045e drawable w=1280 h=24 box 0,0 1280x24
    2a357d36   wibox.layout.align w=grow h=grow box 0,0 1280x24
    5158c523     wibox.layout.fixed w=16 h=grow box 0,0 16x24
    a53fd76b       wibox.widget.textbox raster w=16 h=grow box 0,0 16x24
  drawin screen 1 400x32+0+100 whole: shape_bounding shape_clip
```

Only `RECTANGLE` commands carry a z, so every other line reads `z=-`. Draw order is the line order.

In the tree, `raster` marks a widget that draws itself with cairo into a surface of its own, and `spacer` marks an element that stands for no widget, which a layout asked for to hold space. A size reads as a number when the tree fixed it, `grow` when the element takes what its parent gives it, and `grow<=N` when it grows up to a ceiling.

## Input Commands {#input-commands}

Commands for input device configuration.

| Command | Description |
|---------|-------------|
| `input` | Dump every input setting with its current value |
| `input <property>` | Get input property value |
| `input <property> <value>` | Set input property value |

Twenty-one properties are reachable over IPC. Run `somewm-client input` with no arguments to print them all with their current values and a one-line description each.

| Group | Properties |
|-------|------------|
| Tap and click | `tap_to_click`, `tap_and_drag`, `drag_lock`, `tap_3fg_drag`, `tap_button_map`, `click_method` |
| Scroll | `natural_scrolling`, `scroll_method` |
| Pointer | `accel_profile`, `accel_speed`, `left_handed`, `middle_button_emulation`, `disable_while_typing`, `send_events_mode` |
| Keyboard | `keyboard_repeat_rate`, `keyboard_repeat_delay`, `xkb_layout`, `xkb_variant`, `xkb_options`, `xkb_model`, `xkb_rules` |

:::note
These commands set **global** input defaults. Per-device rules configured via `awful.input.rules` take priority over global settings. See [awful.input Reference](/docs/reference/awful/input#input-rules) for details.
:::

:::caution
`awful.input` carries four properties the IPC command does not expose: `dwtp`, `scroll_button`, `scroll_button_lock`, and `clickfinger_button_map`. Set those in `rc.lua`; `somewm-client input` rejects them as unknown settings.
:::

## Mouse Commands

| Command | Description |
|---------|-------------|
| `mouse coords [x y]` | Get or set the cursor position |
| `mouse screen` | Screen under the cursor |
| `mousegrabber isrunning` | Whether a mousegrabber is active |
| `mousegrabber stop` | Stop the active mousegrabber |

## Keybinding and Rule Commands

| Command | Description |
|---------|-------------|
| `keybind list [client]` | List keybindings. Pass `client` for per-client bindings |
| `keybind add <mods> <key> <cmd> [desc] [group]` | Add a global binding that spawns a command |
| `keybind remove <mods> <key>` | Remove a global binding |
| `keybind trigger <mods> <key>` | Fire a binding manually |
| `rule list` | List client rules |
| `rule add <json>` | Add a rule from JSON |
| `rule remove <id>` | Remove a rule by ID |
| `rule test <client_id>` | Show which rules match a client |

## Appearance Commands

| Command | Description |
|---------|-------------|
| `theme get [key]` | Get one theme value, or all of them |
| `theme set <key> <value>` | Set a theme value |
| `wallpaper set <path> [screen]` | Set the wallpaper from an image |
| `wallpaper color <hex> [screen]` | Set the wallpaper to a solid color |
| `wibar list` | List wibars |
| `wibar show\|hide\|toggle <screen\|all>` | Control wibar visibility |
| `titlebar show\|hide\|toggle [<id>] [position]` | Control titlebars. `position` is `top`, `bottom`, `left`, or `right`, and may be given in place of the ID |

## Screenshot Commands

| Command | Description |
|---------|-------------|
| `screenshot save <path> [--transparent]` | Capture the whole desktop. `--transparent` preserves alpha by writing ARGB32 |
| `screenshot client <path> [<id>]` | Capture one client |
| `screenshot screen <path> [<id>]` | Capture one screen |
| `screenshot interactive <path>` | Capture an interactively selected region |

## Session Commands {#session-commands}

| Command | Description |
|---------|-------------|
| `lock` | Lock the session |
| `reload` | Reload the configuration, validating it first |
| `restart` | Cold restart via exit code (`somewm-session` restarts the compositor) |
| `rebuild` | Rebuild and restart (`somewm-session` rebuilds, then restarts) |
| `quit` | Exit the compositor |
| `dpms <on\|off\|status>` | Control display power management |
| `idle <timeout\|status\|clear>` | Manage idle timeouts |

## Event Subscription {#events}

`--subscribe` holds the connection open and streams events as they happen, one per line:

```bash
somewm-client --subscribe
```

```
EVENT client_focus {"id":2,"title":"Hacker News","class":"firefox"}
EVENT tag_switch {"index":2,"name":"web","selected":true,"screen":1}
```

Each line is the literal word `EVENT`, the event type, and a JSON object. Key order within the object is not guaranteed.

| Event | Payload keys |
|-------|--------------|
| `client_manage`, `client_unmanage` | `id`, `title`, `class` |
| `client_focus`, `client_unfocus` | `id`, `title`, `class` |
| `client_title` | `id`, `title` |
| `client_urgent` | `id`, `urgent`, `title`, `class` |
| `client_fullscreen` | `id`, `fullscreen` |
| `client_floating` | `id`, `floating` |
| `client_minimized` | `id`, `minimized` |
| `tag_switch` | `index`, `name`, `selected`, `screen` |
| `screen_add`, `screen_remove` | `index`, `name` |

`tag_switch` fires on `property::selected` for each tag, so deselecting one tag and selecting another emits two events, one with `selected: false` and one with `selected: true`.

:::warning
Event-type arguments are accepted and ignored. Subscription is a per-connection flag, so every subscriber receives every event. Filter on the client side.
:::

## Test Mode {#test-mode}

Spawn a nested somewm under your current Wayland or X11 session so you can iterate on `rc.lua` without touching your real desktop. Each instance has its own name (defaults to `test`); the rest of the verbs target the named instance.

| Command | Description |
|---------|-------------|
| `test start [opts]` | Spawn a sandboxed nested somewm. See options below. |
| `test stop [--name N]` | Stop the named instance and remove its state dir. |
| `test list [--json]` | List running instances. Connects to each socket; stale entries are flagged. |
| `test run [--name N] -- CMD` | Spawn a command inside the nested instance (it inherits the right `WAYLAND_DISPLAY`). |
| `test eval [--name N] LUA` | Evaluate Lua inside the nested instance, like `eval` but pointed at the named socket. |
| `test reload [--name N]` | Reload the nested instance's config. |
| `test logs [--name N] [-f]` | Print or follow the nested instance's log. |

### `test start` options

| Option | Description |
|--------|-------------|
| `--config FILE` | Path to the `rc.lua` to load. If omitted, the nested somewm follows its normal lookup. |
| `--name NAME` | Instance name. Default `test`. 1 to 64 characters from `[A-Za-z0-9._-]`, no leading `.`. Each instance gets its own state dir at `$XDG_RUNTIME_DIR/somewm-test/<name>/`. |
| `--host wayland\|x11\|headless` | Outer compositor type. Defaults to `wayland` if `WAYLAND_DISPLAY` is set; otherwise required. `headless` skips display nesting (no window opens) and is used by CI harnesses; typically paired with `WLR_RENDERER=pixman`. |
| `--keybinds auto\|inhibit\|remap\|none` | How keys reach the nested somewm. `auto` tries the shortcut inhibitor protocol and falls back to `Mod4 -> Mod1` remap if the host doesn't support it. |
| `--no-marker` | Skip the wibar marker textbox (cosmetic only). |
| `--force` | Replace an already-running instance with the same name. |

The status block printed on success reports whether the outer compositor accepted the shortcut inhibitor request. `test start` waits up to 30 seconds for the nested compositor's IPC socket to respond to a ping before giving up; if `rc.lua` fails to load, the orchestrator detects the `FATAL:` line in the log and surfaces it instead of leaving the call hanging. See [Testing with a nested compositor](../guides/testing-with-nested-compositor.md) for the workflow.

### Environment variables {#test-env}

Set by `somewm-client test` on the nested compositor:

| Variable | Purpose |
|----------|---------|
| `SOMEWM_TEST_NAME` | Instance name. Compositor reads this to know it is a test instance and to load the keybind-remap shim. |
| `SOMEWM_TEST_STATE_DIR` | Absolute path to the per-instance state directory. The compositor writes `keybinds_status` here. |
| `SOMEWM_TEST_KEYBINDS_MODE` | One of `auto`, `inhibit`, `remap`, `none`. Mirrors `--keybinds`. |
| `SOMEWM_TEST_KEYBINDS_REMAP` | Set to `1` when the orchestrator decides to fall back to `Mod4 -> Mod1` remap. The Lua shim reads this. |
| `SOMEWM_SOCKET` | Absolute path to the per-instance IPC socket so subsequent `somewm-client test ...` calls reach the right compositor. |
| `XDG_RUNTIME_DIR` | Overridden to `<state-dir>/runtime` so the nested compositor's Wayland socket does not collide with the host's. |
| `WLR_BACKENDS`, `WLR_RENDERER`, `WLR_X11_OUTPUTS`, `WLR_WL_OUTPUTS` | Selected based on `--host`. |

Read by `somewm-client test`:

| Variable | Purpose |
|----------|---------|
| `SOMEWM_BINARY` | Path to the somewm binary to launch. Defaults to `somewm` on `$PATH`. Use this to nest a local build (`SOMEWM_BINARY=./build/somewm somewm-client test start ...`) without `make install`. |

### State directory layout {#test-state-dir}

Each instance owns `$XDG_RUNTIME_DIR/somewm-test/<name>/`:

| File | Contents |
|------|----------|
| `pid` | Single line: the nested compositor's PID. |
| `log` | Combined stdout + stderr of the nested compositor. |
| `ipc.sock` | Unix domain socket the orchestrator and `somewm-client test ...` connect to. |
| `runtime/` | Per-instance `XDG_RUNTIME_DIR`. Contains the nested compositor's `wayland-N` socket. |
| `info` | Key-value snapshot for scripts. Keys: `name`, `pid`, `host`, `display`, `config`, `started_at`, `keybinds_mode`, `keybinds_status`, `wl_socket_name`, `no_marker`. |
| `keybinds_status` | Single line written by the nested compositor: `active`, `unavailable`, or `not-applicable`. |

`test stop` removes the directory. A failed start leaves it in place so the log survives, and the next start under that name clears it.

### Exit codes {#test-exit-codes}

The `test` subcommands use a richer exit-code set than the generic codes at the bottom of this page:

| Code | Meaning |
|------|---------|
| 0 | Success. |
| 1 | Usage error (bad flag, missing argument, invalid `--name`). |
| 2 | An instance with the same `--name` is already running. Pass `--force` to replace it. |
| 3 | Named instance not found (`stop`, `run`, `eval`, `reload`, `logs`). |
| 4 | IPC failure (could not connect to the instance's socket, or the read/write failed). |
| 5 | Process/system error (fork failed, the nested compositor exited before the socket came up, `FATAL:` in the startup log). |
| 6 | Filesystem error (could not create the state directory, write the pidfile, or remove the state directory). |

These let scripts and CI tell "already running" from "not found" from "the compositor crashed on startup" without parsing stderr.

**See also:** [Test Mode (concepts)](../concepts/test-mode.md) for the why and when, and [Workflows](../guides/testing-with-nested-compositor.md#workflows) for the full set of recipes.

Test mode is inspired by [AWMTT](https://github.com/serialoverflow/awmtt), a similar nested-compositor testing tool for AwesomeWM.

## Examples

```bash
# Check connection
somewm-client ping

# List windows
somewm-client client list
# Output:
# id=1 title="Firefox" class="firefox" tags=1 floating=false
# id=2 title="Terminal" class="Alacritty" tags=1 floating=false

# Everything about the focused window, including its class
somewm-client client info focused

# Focus window by ID
somewm-client client focus 1

# Float the focused window
somewm-client client floating focused true

# Enable tap-to-click
somewm-client input tap_to_click 1

# View tag 3
somewm-client tag view 3

# Save a screenshot
somewm-client screenshot save ~/shot.png

# Lock the session
somewm-client lock

# Evaluate Lua, for what no command covers
somewm-client eval "return awesome.startup_errors"
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | The compositor replied `ERROR`, or the arguments were unusable |
| 2 | Could not connect to the compositor socket |

A missing compositor and a rejected command are the two cases worth branching on: exit 2 means nothing is listening, exit 1 means SomeWM is running and said no.

## See Also

- [CLI Control Guide](/docs/guides/cli-control)
