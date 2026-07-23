---
title: Environment and IPC
description: Runtime environment variables, the config search order, the -s flag, and the Lua eval socket.
sidebar_position: 17
---

# Environment and IPC

How kiln finds its config, which environment variables it reads and sets, and the IPC socket that gives you a live Lua REPL into the running compositor.

```bash
# ask a running kiln a question from a shell
scripts/kiln-eval 'return #client.all()'
```

## Environment variables

Read by the compositor:

| Variable | Description |
|---|---|
| `KILN_RC` | Explicit path to the config file to load; overrides the search order below. |
| `KILN_SOCK` | Path for the IPC socket. Default: `$XDG_RUNTIME_DIR/kiln.sock` (falling back to `/tmp/kiln.sock`). Set it to give an instance a private socket, for example a nested session next to a headless test run. |
| `KILN_IMAGE_BUDGET_MB` | Image decode cache budget in MB (default 64). A working set larger than the budget stays correct but re-decodes per frame. |
| `LC_ALL`, `LC_CTYPE`, `LANG` | Checked in that order to build the keyboard compose table (dead keys). A locale with no compose table, such as `C`, leaves compose off. |

Set for child processes (everything launched via `core.spawn` and friends):

| Variable | Description |
|---|---|
| `WAYLAND_DISPLAY` | The compositor's Wayland socket, so spawned clients connect to this kiln. |
| `DISPLAY` | The Xwayland display, when kiln is built with Xwayland (the X server itself starts lazily on the first X client). |
| `XDG_ACTIVATION_TOKEN` | Set only for `core.spawn_with_token` children, so the launched client can raise itself as user-initiated. |

Read by the default config, not the compositor:

| Variable | Description |
|---|---|
| `KILN_WALLPAPER` | Path to a wallpaper image; the default config's backdrop recipe reads it and draws the image behind every client. A custom rc.lua only honors it if it does the same. |

## Config search order

First hit wins:

1. `KILN_RC` (used verbatim if set and non-empty)
2. `$XDG_CONFIG_HOME/kiln/rc.lua` when `XDG_CONFIG_HOME` is set, otherwise `~/.config/kiln/rc.lua`
3. The installed default, `<prefix>/share/kiln/rc.lua`
4. `rc.lua` in the working directory (how kiln runs from a source tree)

## Flags

| Flag | Description |
|---|---|
| `-s <command>` | Run a startup command once the compositor is up. |

```bash
kiln -s 'foot'
```

## IPC: the eval socket

kiln listens on a unix socket (mode 0600, owner only) and evaluates whatever Lua you send, inside the same VM that runs your config. This is not a command protocol with a fixed verb list: it is a live REPL into the config VM, and everything in this reference is drivable over it.

The protocol:

1. Connect to the socket and write Lua source.
2. Half-close the write side (send EOF). The compositor evaluates on half-close.
3. Read one reply, then the connection closes.

Evaluation tries expression form first (so `1+1` answers `2`), then statement form, so both expressions and statements work. The reply is the results tab-joined through `tostring` with a trailing newline, or `ERROR: <msg>` on a load or runtime error, capped at 4096 bytes.

`scripts/kiln-eval` in the source tree wraps this with `nc`:

```bash
scripts/kiln-eval 'return core.output.list()[1].name'
scripts/kiln-eval 'core.spawn({ "foot" })'
echo 'require("somewm").notify{ title = "hi", message = "from IPC" }' | scripts/kiln-eval
```

:::warning
Anything that can connect to the socket evaluates arbitrary Lua in your compositor, including while the screen is locked. The 0600 mode keeps that to your own user; do not loosen it.
:::

## See also

- [IPC and scripting](/kiln/guides/ipc-and-scripting): workflows built on the socket
- [Testing headless](/kiln/guides/testing-headless): a private instance with `KILN_SOCK` and `KILN_RC`
- [Reload and debugging](/kiln/guides/reload-and-debugging): poking a live session
- [core](/kiln/reference/core): the raw surface you can drive over IPC
