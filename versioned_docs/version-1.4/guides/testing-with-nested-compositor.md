---
sidebar_position: 4
title: Testing with a Nested Compositor
description: Run a sandboxed somewm inside your current desktop to test rc.lua changes without touching your real session.
---

import SomewmOnly from '@site/src/components/SomewmOnly';
import YouWillLearn from '@site/src/components/YouWillLearn';

# Testing with a Nested Compositor <SomewmOnly />

`somewm-client test` spawns a sandboxed nested somewm under your current Wayland or X11 session. Crashing the nested instance leaves your real desktop untouched, so it's a safe place to iterate on `rc.lua`, try a PR's config, or reproduce a bug report.

<YouWillLearn>
- Iterate on `rc.lua` with a fast edit / reload loop without restarting your real session
- Try someone else's `rc.lua` (a PR, a forum snippet, a wiki recipe) without committing
- Bisect which commit or edit broke your config
- Read the keybind status line so you know whether the host is forwarding `Mod4`
</YouWillLearn>

For the bigger picture, see [Test Mode](../concepts/test-mode.md) for what nesting is, what it isn't, and when to reach for it instead of a VM or `somewm --check`.

## Quick start

```bash
somewm-client test start --name work --config ~/dev/somewmrc.lua
```

The status block looks like this on a Wayland host that supports the shortcut inhibitor protocol (Sway, KDE, Hyprland, recent niri):

```
test 'work': pid 12345 on wayland-3 (host: wayland), config /home/you/dev/somewmrc.lua
  keybinds: shortcut inhibitor ACTIVE on outer compositor, Mod4 passes through
  log:      /run/user/1000/somewm-test/work/log
  socket:   /run/user/1000/somewm-test/work/ipc.sock
  next:     somewm-client test run  --name work -- alacritty
            somewm-client test eval --name work 'return mouse.coords()'
            somewm-client test stop --name work
```

Each instance gets its own directory at `$XDG_RUNTIME_DIR/somewm-test/<name>/` with an isolated `XDG_RUNTIME_DIR`, IPC socket, pid file, log, and an `info` key-value file you can inspect.

## Drive commands into the nested instance

The other `test` verbs accept the same `--name` flag and route through the named instance's IPC socket.

```bash
# Spawn a terminal inside the nested compositor
somewm-client test run --name work -- alacritty

# Evaluate Lua in the nested compositor's Lua VM
somewm-client test eval --name work 'return mouse.coords()'

# Reload after editing rc.lua
somewm-client test reload --name work

# Tail the log
somewm-client test logs --name work -f
```

:::note `test run` and shell quoting
The arguments after `--` are forwarded through the same line-based IPC that `somewm-client exec` uses, so complex shell quoting (e.g. `-e sh -c 'echo hi; sleep 60'`) does not survive the marshal: the command string gets re-split on spaces on the receiving side. For commands with embedded spaces or `;`, write a small shell script and call that instead: `somewm-client test run --name work -- /path/to/your-script.sh`.
:::

## Workflows

Each of these is a recipe for a real reason someone reaches for `test`. Pick the one that matches the situation, copy the commands, adapt the paths.

### Iterative widget development {#iterative-dev}

The bread and butter. You're editing `rc.lua` to add a wibar widget, tweak a layout, or wire up a new signal handler. You want to see each change without restarting your real session.

```bash
# Start the test instance against your live config
somewm-client test start --name dev --config ~/.config/somewm/rc.lua

# Edit in your usual editor, save
$EDITOR ~/.config/somewm/rc.lua

# Reload the test instance to pick up the change
somewm-client test reload --name dev

# Keep iterating; tail the log in another terminal if you want
somewm-client test logs --name dev -f
```

`test reload` re-runs `rc.lua` inside the nested compositor and re-registers widgets, keybindings, and signal handlers. A syntax error in `rc.lua` shows up in the log but does not take down your real session.

Gotcha: `test reload` re-runs Lua only. If you change something that the C layer would normally pick up at startup (very rare for a config tweak), `test stop && test start` is the cleanest reset.

### Reviewing someone else's `rc.lua` {#pr-review}

You're reviewing a PR, a dotfile gist, or a wiki recipe that ships an `rc.lua`. You want to actually watch it run before you copy ideas or merge anything.

```bash
# Fetch the PR's branch into your local somewm-config repo
cd ~/.config/somewm
git fetch origin pull/123/head:pr-123
git checkout pr-123

# Run it in a nested instance, replacing any previous one cleanly
somewm-client test start --name pr --config ./rc.lua --force
```

`--force` replaces any previously-running instance with the same name in one shot, so jumping between branches becomes `git checkout other-pr-456 && somewm-client test start --name pr --config ./rc.lua --force` with no manual stop step.

Gotcha: the PR author's `rc.lua` runs against your installed `somewm` binary, not theirs. Errors that only show up on their machine (newer API, different theme) won't reproduce here, and vice versa. Check the log with `somewm-client test logs --name pr`.

### Bisecting which change broke your config {#bisect}

Your config worked last week and doesn't today. You don't remember which edit was the culprit. Pair `git bisect` with test mode.

```bash
cd ~/.config/somewm
git bisect start
git bisect bad HEAD
git bisect good <known-good-commit>

# git checks out a midpoint commit; bring it up in the test instance
somewm-client test start --name bisect --config ./rc.lua --force

# Try the broken behavior in the test window. If it reproduces:
git bisect bad
# If it doesn't:
git bisect good

# Repeat. After each step, the next commit is checked out and you
# rerun test start --force to bring it up. Total time per step: ~2s.
```

The orchestrator's `--force` is the unlock here: every bisection step is one command, no separate stop / wait / start.

Gotcha: if your `rc.lua` depends on widget modules or themes elsewhere in `~/.config/somewm/`, make sure those are in the same git history. Otherwise the bisect will trip on a missing file from an unrelated reason.

### Sandboxing a risky widget or signal handler {#sandbox}

You found a clever signal handler on a blog post or a community widget in someone else's dotfiles. You're not sure it won't loop forever, leak memory, or fire on every `manage` and tank your performance. Try it nested first.

```bash
# Build a scratch rc.lua that loads your normal config plus the new code
cat > /tmp/scratch-rc.lua <<'EOF'
dofile(os.getenv("HOME") .. "/.config/somewm/rc.lua")
-- Experimental code below
require("the-suspicious-widget")
EOF

# Run the test instance against it
somewm-client test start --name sandbox --config /tmp/scratch-rc.lua
```

If the widget locks up the test instance, `somewm-client test stop --name sandbox` still works from your real session, because the orchestrator runs in your real session, not the nested one.

Gotcha: test mode is not a security boundary. The nested instance shares your home directory; a widget that writes to `~/.config/somewm/state.json` writes to the real file. For untrusted code, use a separate user account or a VM. Test mode is for trusted but unproven Lua, not for hostile code. See [Test Mode](../concepts/test-mode.md#what-test-mode-is-not).

## Keybind behavior on each host

The nested somewm sits between your hand and the host compositor. Keys flow into the host first, and the host decides what to forward.

| Host | What happens | What the status block says |
|------|--------------|-----------------------------|
| Sway, KDE, Hyprland, niri (recent) | somewm binds the host's `zwp_keyboard_shortcuts_inhibit_manager_v1` and the host forwards Mod4 combos to the nested window when it has focus. | `shortcut inhibitor ACTIVE on outer compositor` |
| GNOME, host without inhibitor support | Inhibitor unavailable. Bindings are auto-remapped: every `Mod4` becomes `Mod1` for this instance only. | `! outer compositor did not advertise shortcut inhibitor` |
| X11 (Xorg + i3 / awesome / dwm) | Inhibitor doesn't apply on X11. Same `Mod4 -> Mod1` remap as the GNOME case. | `host=x11, no shortcut-inhibitor negotiation needed` |

When the remap kicks in, the bindings your `rc.lua` registered with `Mod4` activate on `Mod1` (Alt). Bindings without `Mod4` are unchanged. You can force or disable the behavior with `--keybinds`:

```bash
# Force remap even on hosts that support the inhibitor
somewm-client test start --name work --keybinds=remap --config ...

# Don't auto-remap; accept that some Mod4 combos won't reach the nested instance
somewm-client test start --name work --keybinds=none --config ...
```

## Replace a running instance

By default `test start` refuses to clobber a running instance with the same name:

```
Error: test instance 'work' already running (pid 12345).
       Use --force to replace it, or pick a different --name.
```

Pass `--force` to stop and replace the existing one in a single command. The new instance gets a fresh state directory.

## Stop and clean up

```bash
somewm-client test stop --name work
```

`test stop` sends `SIGTERM`, waits up to five seconds for the IPC socket to disappear, then escalates to `SIGKILL` if needed. The state directory is removed on the way out.

`somewm-client test list` connects to each instance's IPC socket with a short timeout and reports `(stale)` for entries whose socket is gone. Stop any stale entries by name.

## Compositor compatibility (Wayland host)

The shortcut inhibitor protocol is the only piece that varies between hosts.

- **Sway**, **KDE / KWin**, **Hyprland**: implement `zwp_keyboard_shortcuts_inhibit_manager_v1` and forward shortcuts as expected.
- **niri**: supports the protocol in recent releases.
- **GNOME / Mutter**: does not implement the protocol. The fallback `Mod4 -> Mod1` remap kicks in automatically.
- Any compositor: even with the inhibitor active, a few host-reserved combos (e.g. `Super+L` to lock) may still be intercepted by the host. Pick `Mod4` keybindings that don't collide with your daily-driver's reserved shortcuts.

## Credit

Test mode is inspired by [AWMTT](https://github.com/serialoverflow/awmtt), a bash wrapper around Xephyr that gave AwesomeWM users the same workflow on X11. The somewm version is a native subcommand because wlroots already handles the nesting, and it adds named multi-instance support plus the shortcut inhibitor negotiation.
