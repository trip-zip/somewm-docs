---
sidebar_position: 23
title: Defer startup with request::rules
description: Add client and notification rules from a module without ordering pain
---

# Defer startup with `request::rules`

If you write a custom module that wants to add a `ruled.client` or `ruled.notification` rule, the obvious approach is to append the rule at module load time:

```lua
-- my_module.lua
local ruled = require("ruled")

table.insert(ruled.client.rules, {
    rule = { class = "Firefox" },
    properties = { tag = "web" },
})
```

This works until two modules both want to add rules and the order they're `require`-d in matters, or a module is `require`-d *after* clients have already been scanned, or your `rc.lua` reorganizes and one module suddenly loads before the rules table exists.

`request::rules` is the structured way around this. Both `ruled.client` and `ruled.notification` emit it once, on `client.scanning`, after all modules have had a chance to load and *before* any client is matched against rules.

## The pattern

```lua
-- my_module.lua
local ruled = require("ruled")

ruled.client.connect_signal("request::rules", function()
    ruled.client.append_rule {
        rule = { class = "Firefox" },
        properties = { tag = "web" },
    }
end)
```

You connect the handler at module load time. The handler doesn't run until the compositor is ready to apply rules, which gives every other module a chance to register first.

## Why this is better than appending directly

- **Order independence.** Modules can be `require`-d in any order in `rc.lua`. The rules table is built once, all at once, when `request::rules` fires.
- **Late `require` works.** If you `require("my_module")` from inside another callback (lazy loading), and that happens before scanning, the handler still runs at the right moment.
- **It matches the library's expectation.** `ruled.client` is designed around `request::rules`. Other modules that introspect or modify the rule list assume the rules are added through this signal.

## For notifications

`ruled.notification` works the same way:

```lua
ruled.notification.connect_signal("request::rules", function()
    ruled.notification.append_rule {
        rule = { app_name = "spotify" },
        properties = { ignore = true },
    }
end)
```

If a Spotify notification arrives, naughty applies the rule and ignores it.

## Multiple handlers compose

Each module can connect its own `request::rules` handler. They all run in connect order. You don't need to coordinate between modules:

```lua
-- module_a.lua
ruled.client.connect_signal("request::rules", function()
    ruled.client.append_rule { ... }
end)

-- module_b.lua
ruled.client.connect_signal("request::rules", function()
    ruled.client.append_rule { ... }
end)
```

Both rules end up in the rules table by the time the first client is matched.

## When *not* to use `request::rules`

The signal fires once at startup. If you want to add a rule at runtime (e.g. user toggles a setting), connecting to `request::rules` won't help; that signal already fired. Use `ruled.client.append_rule` directly:

```lua
function on_user_setting_changed()
    ruled.client.append_rule {
        rule = { class = "Slack" },
        properties = { tag = "chat" },
    }
end
```

This applies to clients managed *after* the rule is appended. Already-managed clients won't be re-evaluated.

## Loading order, in full

The full startup sequence looks like:

1. `rc.lua` runs. Modules are `require`-d. Each connects its `request::rules` handler.
2. Compositor begins scanning for already-running clients.
3. `client.scanning` fires.
4. `ruled.client` emits `request::rules`. All connected handlers run, in order. Rules are appended.
5. `ruled.notification` emits its own `request::rules`.
6. Each pre-existing client is managed, with rules now in place.
7. `client.scanned` fires. New clients from this point also see the rules.

See [Signals (concepts)](../concepts/signals.md#startup-ordering) for the larger startup sequence.

## See also

- [Client Rules](/docs/guides/client-rules)
- [Notifications](/docs/guides/notifications)
- [Signals (concepts)](../concepts/signals.md)
- [`ruled.client` signals](../reference/signals.md#ruledclient-signals)
