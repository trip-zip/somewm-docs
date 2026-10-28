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
kiln-client eval 'require("kiln").reload()'
```

A reload re-executes the config file in the same Lua VM. Modules loaded with
`require` remain cached, including your own modules. See
[Configs split across modules](#configs-split-across-modules).

## 2. What survives, what resets

| State | On reload |
|---|---|
| Application windows and running children | Kept. |
| Client and tag Lua objects | Retired and replaced. Saved references no longer control windows or tag membership. |
| Screens, layer surfaces, notifications | Kept. Screen custom properties and instance listeners are cleared. Layer and notification instance listeners are cleared too. |
| Bindings, rules, config listeners, bars, declare hooks | Removed; the config must register them again. |
| Config timers, watches, pipe callbacks, grabs, animations, scroll offsets | Cleared. Running child processes are not terminated. |
| Config popups | Closed and unregistered; construct new ones. |
| Focus and tag-selection histories | Cleared. |
| Theme, input settings, globals, cached modules | Kept unless the config overwrites them. |
| Replacements for the ten `kiln.defaults` policies | All reset except `successor`, which retains its current function. |
| `kiln.widgets` replacements | `titlebar` resets. Other function replacements remain. |

After running the config, Kiln emits `added` for each screen, refreshes layer
surfaces, then replays clients through the new rules. Clients without a matching
tag rule go to the focused screen's selected tag. Config-side minimisation and
floating geometry are lost. To retain memberships, see
[Keep client tags across reload](./tag-persistence.md#keep-client-tags-across-reload).

`kiln.reload()` schedules this work after the current callback returns. It
returns true when accepted, false during initial config loading or while a
reload is already pending or running. Code after the call still sees the old
configuration.

A config error leaves the session running with the registrations made before
the failure. Reload does not restore the previous config. Fix the file and
reload again.

### Configs split across modules

Export a setup function from each module. Call it from `rc.lua` on every load.
Registrations in the module body run only on the first `require`; reload removes
them without running that body again.

Save `bindings.lua` beside `rc.lua`:

```lua
local M = {}

function M.setup(kiln)
  kiln.key {
    mods = { "mod" }, key = "Return",
    press = function() kiln.spawn("foot") end,
  }
end

return M
```

In `rc.lua`, after setting `kiln.modkey`:

```lua
require("bindings").setup(kiln)
```

This restores registrations but does not reread edits to `bindings.lua`. To
reread that module, clear its cache entry before requiring it:

```lua
package.loaded["bindings"] = nil
require("bindings").setup(kiln)
```

Dependencies remain cached. Restart Kiln after editing its standard library;
clearing individual `kiln.*` entries can leave references to older modules.

## 3. Catch errors with the error signal

Errors in bindings, signal listeners, rules and spawn callbacks emit the global
`error` signal and are printed to stderr. Register a listener near the top of
the config to display them:

```lua
kiln.on("error", function(signal, err)
	kiln.notify {
		urgency = "critical",
		title = "Config error in " .. tostring(signal),
		message = tostring(err),
	}
end)
```

Bar and layout declaration errors are logged as `Lua frame: ...`; they do not
emit this signal. Direct `kiln.timer` callback errors are logged as
`Lua timer: ...`. Always check the log when the error listener reports nothing.

### Declaration failures

A declaration error rejects the screen's entire new frame. The previous scene
and its pointer handlers remain active. Lua state writes made before the error
are not undone. A duplicate element ID has the same frame-rejection behaviour.

After correcting the cause, reload the config or call `kiln.dirty()` to request
another frame. A failed declaration does not schedule its own retry.
`kiln.on_declare` hook errors also emit `error` before rejecting the frame.
A failed `notify_display` function emits `error` and is skipped on later frames
until replaced with another function or reset by reload.

## 4. Logs

Kiln logs to stdout and stderr. `make run` does not capture or
rotate them. The TTY launcher records both in `server.log` under the directory
listed in `build/last-tty-trial`. For a nested trial, capture both streams:

```sh
kiln_demo=$(mktemp -d /tmp/kiln-demo.XXXXXX)
KILN_SOCK="$kiln_demo/eval.sock" KILN_RC="$PWD/kilnrc.lua" \
  dbus-run-session -- ./build/kiln >"$kiln_demo/server.log" 2>&1
```

`tail -f "$kiln_demo/server.log"` from another terminal.

## 5. See what your config actually built

Toggle the Clay inspector with `mod+shift+i`; see [Inspect the Live Element Tree](/kiln/guides/inspector).

## 6. Test changes in a nested instance

Run the nested command above with `KILN_RC` pointing at the config under
test. Address it with `kiln-client -s $kiln_demo/eval.sock ...`;
`kiln-client -s PATH exec foot` starts a client inside it.

For full HOME/config/cache isolation, use
[Testing headless](/kiln/guides/testing-headless). A private bus and socket alone
do not isolate side effects of arbitrary config code.

## See also

- [Inspect the Live Element Tree](/kiln/guides/inspector)
- [IPC and Scripting](/kiln/guides/ipc-and-scripting)
- [Testing Headless](/kiln/guides/testing-headless)
- [Tag Persistence](/kiln/guides/tag-persistence)
- [Environment and IPC reference](/kiln/reference/environment-and-ipc)
