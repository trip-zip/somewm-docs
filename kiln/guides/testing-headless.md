---
title: Testing Headless
description: Run kiln invisibly for config testing and CI, drive it over IPC, and verify results with screenshots.
sidebar_position: 19
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Testing Headless

<YouWillLearn>

- Booting kiln with no display using the headless backend
- Keeping test instances off your live session's IPC socket
- Driving a headless instance with `kiln-eval`
- Screenshotting what a headless config actually drew
- A minimal smoke-test script for CI

</YouWillLearn>

kiln runs fine with no monitor, no GPU display, and no input devices: the headless backend creates a virtual output and renders into it in software. That makes a full compositor cheap to boot in a test: start it, evaluate Lua in it over IPC, screenshot the result, kill it. You can verify a config change without logging out, and run the same checks in CI.

## Booting headless

```bash
WLR_BACKENDS=headless WLR_LIBINPUT_NO_DEVICES=1 \
KILN_SOCK=/tmp/kiln-test.sock KILN_RC=./rc.lua \
kiln 2>/tmp/kiln-test.log &
```

- `WLR_BACKENDS=headless` selects the virtual output backend; `WLR_LIBINPUT_NO_DEVICES=1` accepts having no input devices.
- `KILN_RC` points at the config under test, so you test the exact file you are editing rather than whatever `~/.config/kiln/rc.lua` holds.
- `KILN_SOCK` gives the instance a private IPC socket.

From a source checkout, `make headless` does all of this: it auto-picks a free `/tmp/kiln-headless-N.sock` and matching log, and prints both.

:::warning
`KILN_SOCK` is not optional for a test instance. Without it, the new instance binds the default socket at `$XDG_RUNTIME_DIR/kiln.sock`, unlinking it first, which steals IPC out from under a live session you may be sitting in. Every test instance gets its own socket path.
:::

## Driving it over IPC

The IPC protocol is: connect to the unix socket, send Lua source, half-close, read one reply. Expressions and statements both work; results are `tostring`-ed and tab-joined, and errors come back as `ERROR: <message>`. The `kiln-eval` script in the source tree (`scripts/kiln-eval`) wraps this over `nc`:

```bash
export KILN_SOCK=/tmp/kiln-test.sock
scripts/kiln-eval 'return #screen.all()'          # -> 1
scripts/kiln-eval 'return screen.all()[1].name'   # -> HEADLESS-1
scripts/kiln-eval 'return #screen.all()[1].tags'  # -> 4
```

This is a live REPL into the config's Lua state: everything your config can do, an eval can do. Flip a tag, spawn a program, replace a policy, read a client's geometry. See [IPC and scripting](/kiln/guides/ipc-and-scripting) for the full protocol.

Wayland clients can join the test too. The boot log prints the instance's display name ("Running Wayland compositor on WAYLAND_DISPLAY=..."); spawn clients against it:

```bash
WAYLAND_DISPLAY=wayland-1 foot &
```

:::note
Headless means no keyboard and no pointer, so keybindings and click handlers cannot be exercised as input. Test them by calling the same functions the bindings call, over IPC. That is why keeping binding bodies as named functions pays off in testability.
:::

## Seeing what it drew

`core.screenshot(name, path)` renders an output's composed scene to a PNG, and it works headless: the software renderer composes real frames whether or not anyone is watching. This is the ground truth for "did my config actually draw the bar":

```bash
scripts/kiln-eval 'return core.screenshot(screen.all()[1].name, "/tmp/test.png")'
```

Open `/tmp/test.png` and you are looking at the headless desktop: wallpaper, bar, any clients you spawned in.

:::warning
Two timing traps around captures. First, not every Lua state change redraws on its own; after mutating state over IPC, send `core.dirty()` (the `core` global is visible to evals; your rc's `some` local is not) and give the compositor a moment before capturing, or the screenshot shows the pre-mutation frame. Second, all the mutations inside one eval coalesce into a single redraw: if a test wants to observe each intermediate frame of a sequence, it must send one eval per step, not one eval with a loop.
:::

## Shutting down

Quit through the compositor, not around it:

```bash
scripts/kiln-eval 'core.quit()'
```

If you must kill, kill the exact pid you started. Pattern kills like `pkill -f kiln` are a footgun: the pattern can match your own test script's command line, and it cannot tell a test instance from your live session.

## A minimal smoke test

Everything above in one script: boot, wait for the socket, assert, screenshot, quit. It needs only `nc` (with unix-socket and half-close support, the OpenBSD variant) and exits nonzero on failure, so it drops straight into CI:

```bash
#!/bin/sh
# Smoke-test a kiln config headless: boot, assert over IPC, screenshot, quit.
set -eu

rc=${1:-$HOME/.config/kiln/rc.lua}
sock=/tmp/kiln-smoke-$$.sock
log=/tmp/kiln-smoke-$$.log

WLR_BACKENDS=headless WLR_LIBINPUT_NO_DEVICES=1 \
KILN_SOCK="$sock" KILN_RC="$rc" \
kiln 2>"$log" &
pid=$!

i=0
while [ ! -S "$sock" ]; do
  i=$((i + 1))
  [ "$i" -gt 50 ] && { echo "kiln did not come up; see $log"; exit 1; }
  sleep 0.1
done

kev() { printf '%s' "$1" | nc -U -N "$sock"; }

assert_true() {
  out=$(kev "return $1")
  if [ "$out" != "true" ]; then
    echo "FAIL: $1 -> $out"
    kev 'core.quit()'
    exit 1
  fi
}

# The config booted and built a desktop.
assert_true '#screen.all() >= 1'
assert_true '#screen.all()[1].tags >= 1'
assert_true 'screen.all()[1].selected_tag ~= nil'
assert_true '#screen.all()[1].bars >= 1'

# Capture what it drew.
kev 'core.dirty()' > /dev/null
sleep 0.5
kev 'return core.screenshot(screen.all()[1].name, "/tmp/kiln-smoke.png")' > /dev/null

kev 'core.quit()' > /dev/null
wait "$pid" || true
echo "PASS (screenshot at /tmp/kiln-smoke.png)"
```

Extend the assert list with whatever your config promises: a rule applied to a spawned client, a theme value, the number of bindings in `require("somewm").key.all()`. Each assertion is one line of Lua, which is the whole appeal.

## See also

- [IPC and scripting](/kiln/guides/ipc-and-scripting)
- [Environment and IPC reference](/kiln/reference/environment-and-ipc)
- [Screenshots](/kiln/guides/screenshots)
- [Reload and debugging](/kiln/guides/reload-and-debugging)
