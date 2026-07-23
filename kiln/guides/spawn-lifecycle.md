---
title: Spawn Lifecycle
description: Run apps once per session, focus running instances instead of respawning, and route new windows to the right tag.
sidebar_position: 15
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Spawn Lifecycle

<YouWillLearn>

- Autostart that survives config reloads without doubling processes
- Checking for a running app by scanning `client.all()`
- Single-instance app keys: focus the window if it exists, spawn if not
- Routing a spawned client to a tag with a rule
- Why app_id matching is the mechanism, and what activation tokens add

</YouWillLearn>

Snippets assume the standard config preamble:

```lua
local some = require("somewm")
local key, rule = some.key, some.rule
```

`some.spawn(cmd)` is fire and forget: kiln launches the process and forgets it. Everything smarter (run once, focus-or-spawn, tag routing) is a few lines of config, built on one identity fact: a client's `app_id`.

## Run once at startup

Your config file runs at boot, and runs again on every `some.reload()`. A bare `some.spawn` at the top level therefore spawns again on each reload. The fix is a session flag. A reload re-runs the file in the same Lua state, so a global (deliberately not `local`) survives it:

```lua
-- Global on purpose: survives some.reload(), so autostart runs once per session.
autostarted = autostarted or false

if not autostarted then
  autostarted = true
  some.spawn("mako")
  some.spawn({ "foot", "--server" })
end
```

`some.spawn` takes a shell string (run through `sh -c`) or an argv table (run directly, no shell).

## Check what is already running

For apps that own windows, `client.all()` answers "is it running" directly:

```lua
local function running(app_id)
  for _, c in ipairs(client.all()) do
    if c.app_id == app_id then return c end
  end
  return nil
end

local function ensure_running(app_id, cmd)
  if running(app_id) == nil then
    some.spawn(cmd)
  end
end
```

:::warning
At the moment your config file executes, `client.all()` is empty: on a fresh boot no client has mapped yet, and during a reload the existing clients are re-announced only after the config finishes. A top-level `ensure_running` call therefore always spawns. Use the session flag for load-time autostart, and call `ensure_running` from places that run later: a keybinding, a `some.timer`, or a signal handler. Note also that the scan only sees clients with windows; a windowless daemon is invisible to it.
:::

## Single-instance app keys

The most useful form: a key that focuses the app's existing window, viewing its tag if needed, and only spawns when nothing matches:

```lua
local function focus_or_spawn(app_id, cmd)
  return function()
    local c = running(app_id)
    if c ~= nil then
      if c.tag ~= nil and not c.tag.selected then
        c.tag:view()
      end
      c:focus()
      return
    end
    some.spawn_with_token(cmd)
  end
end

key { mods = { "mod" }, key = "b", desc = "browser", group = "launch",
  press = focus_or_spawn("firefox", "firefox") }
key { mods = { "mod" }, key = "c", desc = "chat", group = "launch",
  press = focus_or_spawn("Slack", "slack") }
```

The spawn leg uses `some.spawn_with_token`, covered below: since the key press is an explicit user request, the new window should arrive focused.

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

## The honest note: identity on Wayland

There is no startup-notification handshake on Wayland that ties "the process I spawned" to "the window that just mapped". kiln cannot tell you that this window came from that spawn; nobody can, portably. Matching on `app_id` is the mechanism, and it is almost always enough, with two caveats:

- The `app_id` is whatever the app declares, and it does not always equal the binary name (case differs, or it is a reverse-DNS name like `org.mozilla.firefox`). Check it once with the `map` handler above.
- Two instances of the same app share an `app_id`, so `running()` finds an arbitrary one. If you need per-instance identity, distinguish by `c.title` or track handles yourself.

X11 apps running through Xwayland expose `class` and `instance` instead; rules match those with the `class` and `instance` clauses.

## Focus handoff: spawn_with_token

What kiln can do is vouch for the user's intent. `some.spawn_with_token(cmd)` launches the command with an XDG activation token in its environment. When the app maps and presents that token, its activation request arbitrates as user-initiated, and the stock policy focuses it. Without a token, an app that asks for focus out of the blue is marked urgent instead of being focused.

Use `spawn_with_token` at the sites where a human just asked for the window: launcher rows, app keys, focus-or-spawn. Use plain `some.spawn` for autostart daemons and background jobs, which have no business taking your keyboard when they finally map.

## See also

- [Client rules](/kiln/guides/client-rules)
- [App launcher](/kiln/guides/app-launcher)
- [Replace default policies](/kiln/guides/replace-default-policies), including the activation policy
- [client reference](/kiln/reference/client)
