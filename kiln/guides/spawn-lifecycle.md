---
title: Spawn Lifecycle
description: Start applications, route their windows, and manage asynchronous command callbacks across stop and reload.
sidebar_position: 16
---

# Spawn Lifecycle

kiln does not link spawned processes to the windows they open; these recipes match windows by `app_id`.

Snippets assume the standard config preamble:

```lua
local kiln = require("kiln")
local key, rule = kiln.key, kiln.rule
```

## Run once at startup

Your config file runs at boot, and runs again on every `kiln.reload()`. A bare `kiln.spawn` at the top level therefore spawns again on each reload. The fix is a session flag. A reload re-runs the file in the same Lua state, so a global (deliberately not `local`) survives it:

```lua
-- Global on purpose: survives kiln.reload(), so autostart runs once per session.
autostarted = autostarted or false

if not autostarted then
  autostarted = true
  kiln.spawn("nm-applet")
  kiln.spawn({ "foot", "--server" })
end
```

`kiln.spawn` takes a shell string (run through `sh -c`) or an argv table (run directly, no shell).

## Check what is already running

Find an existing window by its `app_id`:

```lua
local function running(app_id)
  for _, c in ipairs(client.all()) do
    if c.app_id == app_id then return c end
  end
  return nil
end

local function ensure_running(app_id, cmd)
  if running(app_id) == nil then
    kiln.spawn(cmd)
  end
end
```

:::warning
At the moment your config file executes, `client.all()` is empty: on a fresh boot no client has mapped yet, and during a reload the existing clients are re-announced only after the config finishes. A top-level `ensure_running` call therefore always spawns. Use the session flag for load-time autostart, and call `ensure_running` from places that run later: a keybinding, a `kiln.timer`, or a signal handler. Note also that the scan only sees clients with windows; a windowless daemon is invisible to it.
:::

## Single-instance app keys

Bind a key that focuses the app's existing window, viewing its tag if needed, and only spawns when nothing matches:

```lua
local function focus_or_spawn(app_id, cmd)
  return function()
    local c = running(app_id)
    if c ~= nil then
      if c.tag ~= nil and not c.tag.selected then
        c.tag:view()
      end
      c.minimized = false
      c:focus()
      return
    end
    kiln.spawn_with_token(cmd)
  end
end

key { mods = { "mod" }, key = "b", desc = "browser", group = "launch",
  press = focus_or_spawn("firefox", "firefox") }
key { mods = { "mod" }, key = "c", desc = "chat", group = "launch",
  press = focus_or_spawn("Slack", "slack") }
```

Find an app's `app_id` by launching it and asking:

```lua
client.on("map", function(c)
  print(c.app_id)
end)
```

or over [IPC](/kiln/guides/ipc-and-scripting) with `client.all()`.

## Route the window to a tag

A rule matches on map and applies properties, so "my browser always opens on the web tag" is one line, independent of who spawned it:

```lua
rule { match = { app = "^firefox$" }, props = { tag = "web" } }
```

The `app` clause is a Lua pattern against `app_id`; `props.tag` takes a tag name or a tag object. Combined with `focus_or_spawn`, the first press spawns Firefox onto `web`, and every later press jumps to it. Add `focus = false` to the props if a rule-routed app should not steal focus when it maps. See [client rules](/kiln/guides/client-rules) for the full matcher.

## Matching windows {#the-honest-note-identity-on-wayland}

kiln does not associate spawned processes with new windows. These recipes match by `app_id`, with two caveats:

- The `app_id` is whatever the app declares, and it does not always equal the binary name (case differs, or it is a reverse-DNS name like `org.mozilla.firefox`). Check it once with the `map` handler above.
- Two instances of the same app share an `app_id`, so `running()` finds an arbitrary one. If you need per-instance identity, distinguish by `c.title` or track handles yourself.

X11 apps running through Xwayland expose `class` and `instance` instead; rules match those with the `class` and `instance` clauses.

## Focus handoff: spawn_with_token

`kiln.spawn_with_token(cmd)` gives the child an XDG activation token. The stock
activation policy focuses a client presenting a valid token; an invalid request
marks it urgent.

Focus on map is separate: a newly mapped window normally takes focus even when
started with plain `kiln.spawn`. Use a rule with `focus = false` to suppress
that step. To also refuse later activation requests, see
[map order and focus](./client-rules.md#map-order-and-focus).

## Pipes and watches across stop and reload

`kiln.spawn.pipe(cmd, callbacks)` starts one command. Stdout arrives through
`on_line(line)` after each newline; any final unterminated line arrives at exit.
Stderr reaches `on_err(chunk)` without line splitting. `on_exit(code)` runs after
the child is reaped and both pipes reach EOF. Descendants keeping a pipe open
can delay it. The returned ID identifies this stream, not an OS process ID.

`kiln.spawn.watch(cmd, interval, callbacks)` starts immediately, then waits
`interval` seconds after each completed run before starting another. A command
that never exits, or whose pipes never reach EOF, prevents another run.

| Action or failure | Behaviour |
|---|---|
| `watch:stop()` | Cancels the next run and suppresses the current run's `done` callback. Does not terminate the child or suppress its remaining `line` callbacks. Repeated stops do nothing. |
| `kiln.reload()` | Stops watches and drops all pipe callbacks. Running children continue. New config watches can overlap those children. |
| Child exits nonzero | Reports the status and schedules the next watch run normally. |
| Output or completion callback raises | Emits `error`; remaining callbacks and watch scheduling continue. |
| Watch launch or timer registration raises | Emits `error` and stops that watch. |

There is no process-termination method on a pipe ID or watch handle. Use commands
that finish, or manage a long-running service separately. To prevent late
output updating state after a manual stop, guard the callback:

```lua
local load, stopped = "", false
local watcher = kiln.spawn.watch({ "cat", "/proc/loadavg" }, 5, function(line)
  if stopped then return end
  load = line
  kiln.dirty()
end)

local function stop_load()
  stopped = true
  watcher:stop()
end
```

Read `load` from a bar declaration. Call `stop_load()` when removing the widget.
Reload drops its old callbacks automatically. For whole-command results,
`kiln.poll` publishes `.lines` and `.value` after completion; its `:stop()` also
guards against late updates.

## See also

- [Client rules](/kiln/guides/client-rules)
- [App launcher](/kiln/guides/app-launcher)
- [Replace default policies](/kiln/guides/replace-default-policies), including the activation policy
- [client reference](/kiln/reference/client)
