---
sidebar_position: 4
title: Testing with a Nested Compositor
description: "Recipes for somewm-client test: iterate on rc.lua with reload, review someone else's config, bisect a regression, sandbox a widget, assert in headless CI, test a local build, and compare two configs side by side."
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Testing with a Nested Compositor <SomewmOnly />

`somewm-client test start` runs a second somewm in a window on your session; a crash in it leaves your desktop alone ([Test Mode](../concepts/test-mode.md) has what it is and is not).

```bash
somewm-client test start --name work --config ~/dev/somewmrc.lua
```

```
test 'work': pid 12345 on wayland-3 (host: wayland), config /home/you/dev/somewmrc.lua
  keybinds: shortcut inhibitor ACTIVE on outer compositor, Mod4 passes through
  log:      /run/user/1000/somewm-test/work/log
  socket:   /run/user/1000/somewm-test/work/ipc.sock
  next:     somewm-client test run  --name work -- alacritty
            somewm-client test eval --name work 'return mouse.coords()'
            somewm-client test stop --name work
```

Each instance has its own directory under `$XDG_RUNTIME_DIR/somewm-test/<name>/` with runtime dir, IPC socket, pid file, log and an `info` snapshot ([layout](../reference/somewm-client.md#test-state-dir)). `--config` takes the `rc.lua` file, not a directory.

| Flag | Values |
| --- | --- |
| `--host` | `wayland` (default), `x11` for an X11 session including AwesomeWM on Xorg, `headless` for CI. It does not guess: on X11 without it, `Error: WAYLAND_DISPLAY not set`. |
| `--name` | the instance; every other `test` verb takes it |
| `--force` | stop and replace a running instance of that name in one command |
| `--keybinds` | `remap` forces the Mod4 to Mod1 remap, `none` disables it |

## Verbs

```bash
somewm-client test run    --name work -- alacritty            # spawn inside
somewm-client test eval   --name work 'return mouse.coords()' # Lua in the nested VM
somewm-client test reload --name work                         # re-run rc.lua
somewm-client test logs   --name work -f                      # tail the log
somewm-client test list                                       # running and (stale) instances
somewm-client test stop   --name work                         # SIGTERM, 5 s, SIGKILL; removes the directory
```

Arguments after `--` in `test run` are re-split on spaces on the receiving side, so a command with embedded spaces or `;` goes in a script: `test run --name work -- /path/to/script.sh`.

## Recipes

### Iterate on your config {#iterative-dev}

```bash
somewm-client test start --name dev --config ~/.config/somewm/rc.lua
$EDITOR ~/.config/somewm/rc.lua
somewm-client test reload --name dev
```

`reload` re-runs the Lua only. A syntax error shows in the log and touches nothing else. For a change the C layer reads at startup, `stop` and `start`.

### Review someone else's rc.lua {#pr-review}

```bash
cd ~/.config/somewm && git fetch origin pull/123/head:pr-123 && git checkout pr-123
somewm-client test start --name pr --config ./rc.lua --force
```

It runs against your installed binary, so an error that depends on their build does not reproduce; read `test logs --name pr`.

### Bisect a regression {#bisect}

```bash
cd ~/.config/somewm
git bisect start && git bisect bad HEAD && git bisect good <known-good>
somewm-client test start --name bisect --config ./rc.lua --force   # each step, then bad or good
```

Modules and themes the config requires must be in the same history.

### Sandbox an unproven widget {#sandbox}

```bash
cat > /tmp/scratch-rc.lua <<'EOF'
dofile(os.getenv("HOME") .. "/.config/somewm/rc.lua")
require("the-suspicious-widget")
EOF
somewm-client test start --name sandbox --config /tmp/scratch-rc.lua
```

If it locks up, `test stop --name sandbox` still works: the orchestrator runs in your real session. It shares your home, so a widget that writes `~/.config/somewm/state.json` writes the real file. Hostile code needs a VM or another user.

### Assert in CI {#headless-ci}

```bash
WLR_RENDERER=pixman somewm-client test start --name ci --host headless --config ./rc.lua
somewm-client test eval --name ci 'return tostring(#screen) == "1"' | grep -q '^true$' || exit 1
somewm-client test eval --name ci 'return type(awful.layout.layouts) == "table"' | grep -q '^true$' || exit 1
somewm-client test stop --name ci
```

`eval` prints the return value and exits non-zero on a Lua error. Headless has no input and no pixels, so assert on what the Lua VM owns.

### Test a local build {#custom-binary}

```bash
cd ~/tools/some && make build-test
SOMEWM_BINARY=~/tools/some/build-test/somewm somewm-client test start --name dev --force --config ~/.config/somewm/rc.lua
```

If the branch changes the IPC protocol, use its own `build-test/somewm-client` too.

### Compare two configs {#side-by-side}

```bash
somewm-client test start --name a --config ~/dev/rc-before.lua --force
somewm-client test start --name b --config ~/dev/rc-after.lua  --force
somewm-client test run  --name a -- alacritty; somewm-client test run --name b -- alacritty
somewm-client test eval --name a 'return #client.get()'; somewm-client test eval --name b 'return #client.get()'
```

Both share your D-Bus session and home, so first-write-wins state is visible across them.

## Keybindings per host

| Host | Mod4 | Status line |
| --- | --- | --- |
| Sway, KDE, Hyprland, recent niri | forwarded through `zwp_keyboard_shortcuts_inhibit_manager_v1` while the window has focus | `shortcut inhibitor ACTIVE on outer compositor` |
| GNOME, any host without the protocol | every `Mod4` binding remapped to `Mod1` for this instance | `! outer compositor did not advertise shortcut inhibitor` |
| X11 | same remap | `host=x11, no shortcut-inhibitor negotiation needed` |

Even with the inhibitor, a host-reserved combo such as Super+L may still be taken by the host.

## When start fails

A `test start` that fails before the socket comes up (broken `rc.lua`, missing module, backend error) leaves the state directory and names the log:

```bash
cat "$XDG_RUNTIME_DIR/somewm-test/broken/log"
```

The next `start` under that name clears it. `test list` marks an instance whose socket is gone `(stale)`; `test stop` by name cleans it.
