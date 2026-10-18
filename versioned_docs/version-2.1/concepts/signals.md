---
sidebar_position: 8
title: Signals
description: Objects emit signals; rc.lua connects handlers. C-emitted signals are queued and drained before each event-loop iteration, Lua-emitted ones run inline. The request::* pattern and startup order.
---

# Signals

Every object in SomeWM is a `gears.object`: it emits named signals, and handlers connected to a name run with the object as their first argument. The compositor emits them when something happens (a client maps, focus moves, an output appears), and the Lua libraries emit them to ask for something (`request::rules`, `request::display`). [Signals Reference](../reference/signals.md) lists every one with its arguments.

```lua
client.connect_signal("focus", handler)
client.disconnect_signal("focus", handler)
client.emit_signal("focus", c)      -- libraries do this; user code rarely
```

A name is any string; the `::` in `property::name` is convention, not syntax.

## Who emits

| Source | Examples | Can you suppress it |
| --- | --- | --- |
| C | `request::manage`, `focus`, `property::geometry`, screen `added`, `mouse::move` | no; only choose whether to react |
| Lua libraries | `ruled.client` `request::rules`, `naughty` `request::display`, `awful.layout` `request::default_layouts` | yes; they exist so modules can plug in without monkey-patching |
| your code | `awesome.emit_signal("volume::changed")` | |

## Dispatch

Some C-generated notifications are queued until `some_refresh()`. The queue drains before `refresh` and the output declarations ([How SomeWM draws](./how-somewm-draws.md)). Requests whose results the compositor needs immediately call Lua synchronously.

- **Queued:** property changes, focus, mouse motion, lifecycle, most `request::*`, the output and screen signals hotplug causes, layer-shell properties, most global signals. The exact set is the [dispatch section of the reference](../reference/signals.md#dispatch).
- **Synchronous from C:** `request::manage`, `request::unmanage`, `request::geometry`, screen `added` and `removed`, and the client scalar `property::*` signals. The compositor acts on their handlers' results immediately.
- **Synchronous when Lua caused it:** `screen.fake_add`, `screen.fake_remove`, `s:swap()`, `screen.primary = s`, `awesome.dpms_on()` deliver inline, so a change you make is visible to your next line.
- **Always synchronous:** anything emitted from Lua, including the libraries' own `request::*` emits and your custom signals. The queue is the C to Lua boundary only.

`property::workarea` has two emitters: the one driven by wibar and client struts is inline, the one driven by geometry is queued so it cannot overtake the `property::geometry` it follows.

**Coalescing.** `mouse::move` on one object is coalesced: of several queued moves with no other event between them, only the latest survives. Nothing else is coalesced.

**Reentrancy.** A drain processes a snapshot of the queue. New queued events wait for the next drain. Synchronous C signals and Lua-emitted signals still run inline, including when emitted by a queued handler. [State before a queued handler runs](../reference/signals.md#state-before-a-queued-handler-runs) describes the effect on Lua caches.

## The `request::*` pattern

A `request::*` signal asks for something to be done rather than reporting that it happened. A default handler in `awful.permissions` does the standard thing, and user code can add to it or replace it:

```lua
-- Add: the default still runs
client.connect_signal("request::manage", function(c)
    if c.class == "Firefox" then c.maximized = true end
end)

-- Replace: the default stops
client.disconnect_signal("request::tag", awful.permissions.tag)
client.connect_signal("request::tag", function(c, t, hints)
    c:move_to_tag(screen.primary.tags[1])
end)
```

Most carry a `context` string and a `hints` table after the object: `request::border` passes `"added"`, `"active"`, `"inactive"`, `"floating"`. [Replacing a default handler](../guides/replace-default-handler.md) has the patterns.

## Startup order

1. `rc.lua` runs top to bottom; each `require` connects that library's default handlers.
2. `client.scanning` fires. Inside it, `ruled.client` and `ruled.notification` emit `request::rules`, and `awful.keyboard` and `awful.mouse` emit `request::default_keybindings` and `request::default_mousebindings`. `awful.layout` emits `request::default_layouts` from the first `tag.new`.
3. Existing clients are managed: `request::manage` for each.
4. `client.scanned`, then `awesome.startup`.

Connect a `request::rules` handler at module load time and it runs in time, whatever order modules are required in. [Defer startup with request::rules](../guides/defer-startup-with-request-rules.md) shows the pattern.

## In a handler

- In `request::manage`, handlers connected after `awful.permissions` and `ruled.client` see the client tagged and placed; handlers connected before do not.
- In `request::unmanage`, the client is gone: geometry and screen may be invalid. Stash what you need at `request::manage`.
- `refresh` fires every frame. Keep its handlers small.
- Errors in handlers are caught and logged through `debug::error`; connect your own handler to surface them elsewhere.
