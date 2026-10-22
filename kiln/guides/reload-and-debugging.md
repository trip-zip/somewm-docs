---
title: Reload and Debugging
description: The edit-reload loop, what survives kiln.reload, catching config errors, reading logs, and testing changes in a nested instance.
sidebar_position: 19
---

# Reload and Debugging

## 1. The edit-reload loop

`kiln.reload()` re-runs your config file without restarting the compositor:

```lua
kiln.key {
	mods = { "mod", "ctrl" }, key = "r",
	desc = "reload config", group = "system",
	press = kiln.reload,
}
```

or trigger it from your editor via [IPC](/kiln/guides/ipc-and-scripting):

```bash
scripts/kiln-eval 'require("kiln").reload()'
```

A reload only re-executes the config file. The library itself is not re-required, so editing your config is instant, while changes to kiln's own code need a compositor restart.

## 2. What survives, what resets

**Kept:** clients, the screens, layer surfaces, notifications, running spawned children, and input settings.

**Dropped and rebuilt:** keybindings, button binds, rules, your signal listeners, bars, tags, and the focus history. The reload re-emits `added` for every screen (so your `screen.on("added")` recreates tags and bars), then replays every client through the new config's rules.

- Clients survive as windows but not as arrangement: each one is re-tagged by the new config's rules, an unruled client lands on the focused screen's selected tag, and floats re-cascade. To preserve arrangements, see [Tag Persistence](/kiln/guides/tag-persistence).
- A client you minimized comes back unminimized: that flag was config-side state, and the config just restarted.

A broken config does not kill the session. The reload catches the error, reports it through the error path below, and leaves the compositor running with whatever the file managed to set before it failed; fix the file and reload again.

## 3. Catch errors with the error signal

Every config callback (bindings, listeners, bar functions, rules) runs isolated: an error in one is caught, reported, and does not take down dispatch. Each caught error fires the global `error` signal with the name of the failing hook and the message:

```lua
kiln.on("error", function(signal, err)
	kiln.notify {
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

`print()` from your config goes to stdout, line-buffered so it appears immediately; when you launch kiln by hand and want everything in one file, redirect both streams:

```bash
./build/kiln > /tmp/kiln.log 2>&1
```

Follow the log while reloading:

```bash
tail -f ~/.cache/kiln.log
```

## 5. See what your config actually built

Errors and logs tell you what broke. Clay's debug inspector tells you what your config built: the live element tree, one row per element, with the solved box for each. Toggle it with `mod+shift+i`.

## 6. Test changes in a nested instance

Run a second instance in a window to test config changes:

```bash
make dev
```

This starts a fresh compositor in a nested window with a private IPC socket and log file, both printed at startup. Your real session is untouched. From there:

- Point it at an experimental config with `KILN_RC`: `KILN_RC=/path/to/test-rc.lua make dev`.
- Drive it over its own socket: `KILN_SOCK=/tmp/kiln-dev-1.sock scripts/kiln-eval 'require("kiln").reload()'`.
- Launch test clients into it by setting `WAYLAND_DISPLAY` to the display name in its boot log, for example `WAYLAND_DISPLAY=wayland-1 foot`.

For fully headless (invisible) instances for automated tests, see [Testing Headless](/kiln/guides/testing-headless).

## See also

- [Inspect the Live Element Tree](/kiln/guides/inspector)
- [IPC and Scripting](/kiln/guides/ipc-and-scripting)
- [Testing Headless](/kiln/guides/testing-headless)
- [Tag Persistence](/kiln/guides/tag-persistence)
- [Environment and IPC reference](/kiln/reference/environment-and-ipc)
