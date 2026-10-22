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
kiln-odin-client eval 'require("kiln").reload()'
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

The Odin compositor logs to stdout and stderr. `make run` does not capture or
rotate them. The TTY launcher records both in `server.log` under the directory
listed in `build/last-tty-trial`. For a nested trial, capture both streams:

```sh
kiln_demo=$(mktemp -d /tmp/kiln-demo.XXXXXX)
KILN_SOCK="$kiln_demo/eval.sock" KILN_RC="$PWD/kilnrc.lua" \
  dbus-run-session -- ./build/kiln-odin >"$kiln_demo/server.log" 2>&1
```

Follow that exact log from another terminal while the trial is running.

## 5. See what your config actually built

Errors and logs tell you what broke. Clay's debug inspector tells you what your config built: the live element tree, one row per element, with the solved box for each. Toggle it with `mod+shift+i`.

## 6. Test changes in a nested instance

Use the private nested command above or
[First launch](/kiln/getting-started/first-launch). Set `KILN_RC` to a reviewed
test config, and pass that trial's socket explicitly to each client command.
Do not guess `WAYLAND_DISPLAY`; use `kiln-odin-client -s PATH exec foot` to
spawn through the trial's own environment. The Odin build has no `make dev`.

For full HOME/config/cache isolation, use
[Testing headless](/kiln/guides/testing-headless). A private bus and socket alone
do not isolate side effects of arbitrary config code.

## See also

- [Inspect the Live Element Tree](/kiln/guides/inspector)
- [IPC and Scripting](/kiln/guides/ipc-and-scripting)
- [Testing Headless](/kiln/guides/testing-headless)
- [Tag Persistence](/kiln/guides/tag-persistence)
- [Environment and IPC reference](/kiln/reference/environment-and-ipc)
