---
sidebar_position: 4
title: Test in a nested compositor
description: Test configuration changes in a separate compositor instance.
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Test in a nested compositor <SomewmOnly />

Run `somewm-client test` to try configuration changes in a separate compositor. A crash there leaves your desktop running. The instance still shares your user account, files and D-Bus session, so it is not a security sandbox.

## Quick start

```bash
somewm-client test start --name work --config ~/dev/rc.lua
somewm-client test run --name work -- alacritty
somewm-client test logs --name work -f
```

Replace the config path and terminal command. `--config` takes a file. The startup output reports the IPC socket, log path and whether shortcuts pass through from the host.

Each instance has a directory at `$XDG_RUNTIME_DIR/somewm-test/<name>/`. See the [state directory reference](../reference/somewm-client.md#test-state-dir) for its contents.

## Choosing a host

| `--host` | Environment |
| --- | --- |
| `wayland` (default) | A Wayland desktop |
| `x11` | An X11 desktop |
| `headless` | No graphical host |

The command does not infer X11 from the environment. Select it explicitly:

```bash
somewm-client test start --name work --host x11 --config ~/.config/awesome/rc.lua
```

## Drive commands into the nested instance

<span id="verbs" />

```bash
somewm-client test eval --name work 'return #client.get()'
somewm-client test reload --name work
somewm-client test logs --name work -f
```

Use the same `--name` on each command. `test run` forwards a command through line-based IPC. For arguments containing embedded spaces or shell syntax, put the command in an executable script and run its absolute path.

## Workflows

<span id="recipes" />

### Iterative widget development {#iterative-dev}

<span id="sandbox" />

```bash
somewm-client test start --name dev --config ~/dev/rc.lua
$EDITOR ~/dev/rc.lua
somewm-client test reload --name dev
```

Exercise the changed widget and read the log. Reload rebuilds Lua state and its widgets, bindings and handlers. Restart the test instance when changing the compositor binary or startup environment.

### Reviewing someone else's rc.lua {#pr-review}

Keep the config and its modules in a separate directory, then run:

```bash
somewm-client test start --name review --config ~/dev/example-config/rc.lua
```

It runs against your installed SomeWM binary unless you select another one. Check API version, theme and external command dependencies before interpreting errors.

### Bisecting which change broke your config {#bisect}

In a clean checkout of your config repository:

```bash
git bisect start
git bisect bad HEAD
git bisect good KNOWN_GOOD_COMMIT
somewm-client test start --name bisect --config ./rc.lua --force
```

Replace `KNOWN_GOOD_COMMIT` with a working revision. Test the behaviour, mark the revision with `git bisect good` or `git bisect bad`, then repeat `test start --force` at the next revision. Finish with `git bisect reset`.

Keep required widget modules and themes in the same checkout so each tested revision has its dependencies.

### Headless integration testing for CI {#headless-ci}

```bash
WLR_RENDERER=pixman somewm-client test start \
    --name ci --host headless --config ./rc.lua
trap 'somewm-client test stop --name ci' EXIT

somewm-client test eval --name ci 'assert(screen.count() == 1)' || exit 1
somewm-client test eval --name ci \
    'assert(type(require("awful").layout.layouts) == "table")' || exit 1
```

Assertions make `test eval` return a failure status. Returning `false` alone is a successful Lua evaluation. Library locals from `rc.lua` are not in scope, so require modules inside the expression.

Headless tests can inspect Lua state and captured pixels. They do not reproduce physical output modes, real touchpad input or host shortcut interception.

### Testing a custom build without installing {#custom-binary}

From the SomeWM source checkout:

```bash
make
SOMEWM_BINARY="$PWD/build/somewm" ./build/somewm-client test start \
    --name dev --force --config ~/.config/somewm/rc.lua
./build/somewm-client test eval --name dev 'return #client.get()'
```

Use the matching `somewm-client` binary when testing IPC changes. `make` creates the normal release build without installing it.

### Side-by-side comparison of two configs {#side-by-side}

```bash
somewm-client test start --name a --config ~/dev/rc-before.lua
somewm-client test start --name b --config ~/dev/rc-after.lua
somewm-client test run --name a -- alacritty
somewm-client test run --name b -- alacritty
somewm-client test eval --name a 'return #client.get()'
somewm-client test eval --name b 'return #client.get()'
somewm-client test stop --name a
somewm-client test stop --name b
```

The instances share files and session services. Account for that when comparing autostart or saved state.

## Keybind behaviour on each host {#keybindings-per-host}

On a Wayland host with shortcut-inhibitor support, SomeWM requests that shortcuts reach the nested window. The status block reports whether inhibition is active. Host-reserved shortcuts may still be intercepted.

Without inhibitor support, including an X11 host, test mode remaps `Mod4` bindings to `Mod1` for that instance. Use **Alt** where your config normally uses **Super**. Bindings without `Mod4` are unchanged.

Override this with `--keybinds=remap` to force remapping, or `--keybinds=none` to disable it. See [Test Mode](../concepts/test-mode.md) for the input path.

## Replace a running instance

`test start` refuses to replace a running instance with the same name unless you pass `--force`. That flag stops the old instance and creates a fresh state directory.

## Stop and clean up

<span id="when-start-fails" />

```bash
somewm-client test stop --name work
somewm-client test list
```

Stopping sends `SIGTERM`, waits up to five seconds for the IPC socket to disappear, then sends `SIGKILL` if needed. It removes the state directory, including the log. Copy logs you want to keep before stopping.

If startup fails, the state directory remains for inspection. The error prints the log path. Starting again with the same name clears that directory. `test list` marks unreachable entries as stale.

## Credit

Test mode is inspired by [AWMTT](https://github.com/serialoverflow/awmtt), an AwesomeWM test wrapper around Xephyr.
