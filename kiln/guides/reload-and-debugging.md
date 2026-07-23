---
title: Reload and Debugging
description: The edit-reload loop, what survives some.reload, catching config errors, reading logs, and testing in a nested instance.
sidebar_position: 18
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Reload and Debugging

<YouWillLearn>

- What `some.reload()` does, keeps, and drops
- Catching config errors with the `error` signal
- Where the logs are and what lands in them
- Testing config changes safely in a nested instance

</YouWillLearn>

## 1. The edit-reload loop

`some.reload()` re-runs your config file inside the live compositor: no restart, no session loss. Bind it and keep it bound:

```lua
some.key {
	mods = { "mod", "ctrl" }, key = "r",
	desc = "reload config", group = "system",
	press = some.reload,
}
```

or trigger it from your editor via [IPC](/kiln/guides/ipc-and-scripting):

```bash
scripts/kiln-eval 'require("somewm").reload()'
```

A reload only re-executes the config file. The library itself is not re-required, so editing your config is instant, while changes to kiln's own code need a compositor restart.

## 2. What survives, what resets

Everything the compositor owns survives; everything the config built is rebuilt from scratch.

**Kept:** every client (windows do not flinch), the screens, layer surfaces, notifications, running spawned children, and input settings.

**Dropped and rebuilt:** keybindings, button binds, rules, your signal listeners, bars, tags, and the focus history. The reload re-emits `added` for every screen (so your `screen.on("added")` recreates tags and bars), then replays every client through the new config's rules.

Two consequences worth knowing:

- Clients survive as windows but not as arrangement: each one is re-tagged by the new config's rules, an unruled client lands on the focused screen's selected tag, and floats re-cascade. Want arrangements to stick across reloads? See [Tag Persistence](/kiln/guides/tag-persistence).
- A client you minimized comes back unminimized: that flag was config-side state, and the config just restarted.

A broken config does not kill the session. The reload catches the error, reports it through the error path below, and leaves the compositor running with whatever the file managed to set before it failed; fix the file and reload again.

## 3. Catch errors with the error signal

Every config callback (bindings, listeners, bar functions, rules) runs isolated: an error in one is caught, reported, and does not take down dispatch. Each caught error fires the global `error` signal with the name of the failing hook and the message:

```lua
some.on("error", function(signal, err)
	some.notify {
		urgency = "critical",
		title = "Config error in " .. tostring(signal),
		message = tostring(err),
	}
end)
```

Put this near the top of your config and mistakes surface as notifications instead of silently dead handlers. Every caught error is also printed, so it lands in the log regardless.

## 4. Logs

kiln logs to stderr. The standard make targets from the kiln repo capture it:

- `make run` (the daily session) writes the log to `~/.cache/kiln.log`, keeping the previous run as `kiln.log.old`.
- `make dev` and `make headless` write to a private per-instance file like `/tmp/kiln-dev-1.log` and print the path at startup.

The log carries compositor-level messages plus every caught config error. `print()` from your config goes to stdout, line-buffered so it appears immediately; when you launch kiln by hand and want everything in one file, redirect both streams:

```bash
./build/kiln > /tmp/kiln.log 2>&1
```

Tailing the log while you reload is the fastest debugging loop there is:

```bash
tail -f ~/.cache/kiln.log
```

## 5. Test changes in a nested instance

Editing the config of the session you are sitting in has an obvious failure mode. The safe loop is a second kiln nested as a window inside your current session:

```bash
make dev
```

This starts a fresh compositor in a nested window with a private IPC socket and log file, both printed at startup. Your real session is untouched. From there:

- Point it at an experimental config with `KILN_RC`: `KILN_RC=/path/to/test-rc.lua make dev`.
- Drive it over its own socket: `KILN_SOCK=/tmp/kiln-dev-1.sock scripts/kiln-eval 'require("somewm").reload()'`.
- Launch test clients into it by setting `WAYLAND_DISPLAY` to the display name in its boot log, for example `WAYLAND_DISPLAY=wayland-1 foot`.

Private sockets mean a dev instance can never hijack your live session's IPC, and vice versa. When the config works nested, reload it in the real session.

For fully headless (invisible) instances for automated tests, see [Testing Headless](/kiln/guides/testing-headless).

## See also

- [IPC and Scripting](/kiln/guides/ipc-and-scripting)
- [Testing Headless](/kiln/guides/testing-headless)
- [Tag Persistence](/kiln/guides/tag-persistence)
- [Environment and IPC reference](/kiln/reference/environment-and-ipc)
