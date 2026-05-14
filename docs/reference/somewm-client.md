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

Commands for window management. Client IDs are simple integers (1, 2, 3...) assigned when windows open. IDs increment but don't reuse within a session, and reset when the compositor restarts.

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

Available properties: `tap_to_click`, `tap_and_drag`, `drag_lock`, `tap_3fg_drag`, `natural_scrolling`, `disable_while_typing`, `dwtp`, `left_handed`, `middle_button_emulation`, `scroll_method`, `scroll_button`, `scroll_button_lock`, `click_method`, `send_events_mode`, `accel_profile`, `accel_speed`, `tap_button_map`, `clickfinger_button_map`, `keyboard_repeat_rate`, `keyboard_repeat_delay`, `xkb_layout`, `xkb_variant`, `xkb_options`, `numlock`

:::note
These commands set **global** input defaults. Per-device rules configured via `awful.input.rules` take priority over global settings. See [awful.input Reference](/docs/reference/awful/input#input-rules) for details.
:::

## Screenshot Commands

| Command | Description |
|---------|-------------|
| `screenshot` | Take full screenshot |
| `screenshot <filename>` | Save screenshot to file |

## Session Commands {#session-commands}

| Command | Description |
|---------|-------------|
| `lock` | Lock the session |

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
| `SOMEWM_TEST_KEEP_FAILED` | If set to any value, the orchestrator preserves the state directory after a failed start instead of cleaning it up. The log at `<state-dir>/log` survives so you can read it. |

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

`test stop` and the failed-start path both remove the directory unless `SOMEWM_TEST_KEEP_FAILED` is set.

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

# Focus window by ID
somewm-client client focus 1

# Enable tap-to-click
somewm-client input tap_to_click 1

# Evaluate Lua
somewm-client eval "return client.focus and client.focus.name"

# View tag 3
somewm-client tag viewidx 3

# Lock the session
somewm-client lock
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Connection failed |
| 2 | Command failed |
| 3 | Invalid arguments |

## See Also

- [CLI Control Guide](/docs/guides/cli-control)
