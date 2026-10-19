---
sidebar_position: 8
title: Signals
description: How SomeWM uses signals for events, lifecycle, and customization
---

# Signals

SomeWM is event-driven. When a client is created, a screen is added, focus changes, or a property updates, the relevant object emits a signal. Your `rc.lua` (and the AwesomeWM Lua libraries) connect handlers to those signals to react.

If you've used Qt, GObject, or any pub/sub system, this will feel familiar. The mechanism comes from `gears.object`, the same object system AwesomeWM uses.

## Connect, emit, disconnect

Three operations:

```lua
-- Run my_handler whenever the focused client changes
client.connect_signal("focus", my_handler)

-- Emit a signal manually (rare in user code; libraries do this)
client.emit_signal("focus", c)

-- Stop listening
client.disconnect_signal("focus", my_handler)
```

Signal names are strings. Many include `::` (`property::name`, `request::tag`); that's a convention, not syntax. Anything is a valid signal name; tooling treats them as opaque.

For the full list of signals SomeWM emits, see the [Signals Reference](../reference/signals.md).

## Two sources: C and Lua

Signals come from two places.

**The C side** fires signals when the compositor itself does something: a Wayland client mapped (`request::manage`), the focused window changed (`focus`/`unfocus`), an output was hot-plugged (`screen` `added`). These are part of the compositor lifecycle and you generally can't suppress them. You can only choose whether to react.

**The Lua side** fires signals from the AwesomeWM libraries: `ruled.client` emits `request::rules` to ask modules for rules; `naughty` emits `request::display` to ask for a notification widget; `awful.layout` emits `request::default_layouts` to ask for layouts at startup. These exist so user code and modules can plug into the library without monkey-patching.

You can usually tell from where a signal is documented:
- `client::*`, `screen::*`, `tag::*`, layer-surface signals → C side
- Module-level signals on `ruled.*`, `naughty`, `awful.layout` → Lua side

## Why the queue is an execution boundary

A notification emitted inside a C operation can immediately call Lua, whose handlers can call back into C and change related objects. That nests configuration reactions inside the operation producing the notification. The queue gives selected notifications a separate delivery phase.

C records the signal, its target and its arguments. At `some_refresh()`, the queue dispatches a snapshot in order, before the `refresh` signal and pending layout work. Handlers can update configuration state during that phase. New queued notifications wait for the next drain, so a handler cannot keep extending the current batch indefinitely.

This also gives notification delivery explicit lifetime rules. Queued events hold Lua references to their targets and arguments until delivery. Pending references are cleared when the owning Lua state is replaced during reload. Consecutive pointer moves for the same object can be coalesced while preserving intervening events.

The result is a defined place to run queued configuration reactions. It does not make every callback asynchronous or eliminate every C-to-Lua call. Requests needing an immediate answer and Lua-emitted signals remain synchronous. The dispatch rules below distinguish those paths.

## Dispatch model

Some C-generated notifications are queued until `some_refresh()`. The queue drains before `refresh` and the layout pass. Requests whose results the compositor needs immediately call Lua synchronously. The [signal reference](../reference/signals.md#dispatch) defines both sets.

### What's queued

Queued signals include property changes, focus, mouse motion, lifecycle notifications, some requests, hotplug notifications, layer-shell properties and global signals. The [signal reference](../reference/signals.md#dispatch) lists the exact set.

Other C-emitted signals (`request::manage`, `request::unmanage`, `request::geometry`, screen `added` and `removed`, and the client scalar `property::*` signals) still dispatch synchronously.

Where a signal has both a compositor-driven and a Lua-driven path, only the compositor-driven one is queued. Monitor hotplug queues most of the screen and output signals it causes, but screen `added` and `removed` stay synchronous even there, because the compositor acts on their handlers' results immediately. The Lua-initiated paths all deliver inline: `screen.fake_add`, `screen.fake_remove`, `s:swap(...)`, `screen.primary = s` and `awesome.dpms_on()`. This keeps a change you make from Lua visible to the next line of your own code.

The one signal that splits differently is `property::workarea`: the emitter driven by wibar and client struts stays inline, so a wibar appearing notifies Lua immediately, while the geometry-driven emitter queues so it cannot overtake the queued `property::geometry` it follows.

### What stays synchronous

- Signals you emit from Lua. `c:emit_signal("my::custom")`, `awesome.emit_signal("volume::changed")`, and the AwesomeWM libraries' Lua-side emits (`ruled.client` `request::rules`, `naughty` `request::display`) run handlers immediately. The queue applies to the C/Lua boundary, not to Lua-only signal use.
- C-emitted signals outside the queued set, including requests whose results the compositor needs immediately.

### Coalescing

`mouse::move` is coalesced per object: if several moves are queued on the same object with no intervening event, only the latest survives, carrying the most recent coordinates. Without coalescing, fast cursor motion would dispatch thousands of redundant Lua calls per frame. Coalescing stops at the first non-move event on the queue, so the chronological ordering of `enter` / `move` / `leave` is preserved.

No other queued signal is coalesced. Each emit produces one drained call, in queue order.

### Reentrancy and snapshot semantics

When the queue drains, it processes a snapshot of the events queued at that moment. New queued events added during the drain wait for the next refresh. Synchronous C signals and Lua-emitted signals still run inline. The snapshot bounds a drain even when a queued handler adds more events.

### Practical consequences

- Queued handlers run after the C event handler that triggered them returns. They can't re-enter the code that emitted the signal.
- Lua-emitted signals from inside a handler still dispatch synchronously, so a chain of Lua-only signals runs to completion within the same drain.
- A property change you make from a handler that triggers a queued C signal will fire on the next drain, not this one.
- Custom signals you emit from your own code keep AwesomeWM semantics: synchronous, in the same call stack as the emit.

[State before a queued handler runs](../reference/signals.md#state-before-a-queued-handler-runs) describes the interval in which Lua caches can lag object state.

## Most signals receive their object as the first argument

```lua
client.connect_signal("request::manage", function(c)
    -- c is the client that was just managed
end)

screen.connect_signal("added", function(s)
    -- s is the new screen
end)

tag.connect_signal("property::selected", function(t)
    -- t is the tag whose selection changed
end)
```

Some signals carry extra arguments after the object. `request::*` signals usually pass a `context` string and an optional `hints` table:

```lua
client.connect_signal("request::border", function(c, context, hints)
    -- context is one of "added", "active", "inactive", "floating", ...
end)
```

The reference page lists arguments per signal.

## The `request::*` pattern

Many signals start with `request::`. They aren't notifications that something happened. They're requests for someone to do something. The compositor (or a library) emits them; a default handler does the standard thing; user code can replace the default.

`request::tag` is a clean example. When a client appears with no tag (say, after a screen was just removed), the compositor emits `client.request::tag`. The default handler, `awful.permissions.tag`, picks a reasonable tag. If you want different behavior (always send to tag 1, send to a tag named after the app's class, etc.), replace the handler.

```lua
-- Replace the default tag handler
client.disconnect_signal("request::tag", awful.permissions.tag)

client.connect_signal("request::tag", function(c, t, hints)
    c:move_to_tag(screen.primary.tags[1])
end)
```

The `awful.permissions` module is the home for the default handlers. See [Replacing a default handler](../guides/replace-default-handler.md) for the patterns.

`request::*` signals always have a default handler. If you connect *additionally* (without disconnecting the default), both run.

## Startup ordering

Signal ordering matters most at startup. The sequence is:

1. `rc.lua` runs top to bottom. `require` statements pull in libraries, which connect their default handlers.
2. The compositor starts scanning for already-running clients.
3. `client.scanning` fires.
4. `ruled.client` (and `ruled.notification`) emit `request::rules` from inside `scanning`. This is the moment for modules to add rules.
5. `awful.layout` has already wired itself to the first `tag.new` and will emit `request::default_layouts` from there.
6. `awful.keyboard` and `awful.mouse` emit `request::default_keybindings` and `request::default_mousebindings` from the same scanning window.
7. Existing clients are managed (`request::manage`).
8. `client.scanned` fires.
9. `awesome.startup` fires.

The takeaway: connect handlers for `request::rules` *before* `client.scanning` fires (i.e. at module load time, in `rc.lua` or the module's top level), and they will run in time. Append to `ruled.client.rules` directly at module load time also works, but it forces the module to be `require`-d in a specific order, which is exactly what `request::rules` is designed to avoid.

See [Defer startup with `request::rules`](../guides/defer-startup-with-request-rules.md) for the pattern.

## What's safe to do in a handler

A few rules of thumb:

- **In `request::manage`, default handlers may not have run yet.** If you connect after `awful.permissions` and `ruled.client`, you'll see the post-rule state (the client fully tagged and placed). If you connect before, you won't.
- **In `request::unmanage`, the client is gone.** Don't read geometry or screen; they may already be invalid. Save what you need by stashing it on `request::manage`.
- **In `refresh`, do as little as possible.** It fires often (every redraw). Anything heavy will visibly slow the compositor.
- **Errors in handlers are caught.** The default `debug::error` handler logs them to stderr. Add your own `debug::error` handler if you want to surface them somewhere visible.

## Connect vs. disconnect vs. replace

Three patterns, in increasing invasiveness:

```lua
-- 1. Add a reaction (default handler still runs)
client.connect_signal("request::manage", function(c)
    if c.class == "Firefox" then c.maximized = true end
end)

-- 2. Stop reacting (your handler stops running; default unaffected)
client.disconnect_signal("request::manage", my_handler)

-- 3. Replace the default (default stops; yours takes over)
client.disconnect_signal("request::tag", awful.permissions.tag)
client.connect_signal("request::tag", my_tag_handler)
```

For non-`request::` signals, additive `connect_signal` is the common case. For `request::*`, decide whether you want to *add to* or *replace* the default handler.

## Where to look next

- [Signals Reference](../reference/signals.md): every signal SomeWM and the AwesomeWM libraries emit
- [Replacing a default handler](../guides/replace-default-handler.md): disconnect-and-replace pattern with worked examples
- [React to client lifecycle](../guides/react-to-client-lifecycle.md): common patterns on `manage`, `focus`, `property::*`
- [Defer startup with `request::rules`](../guides/defer-startup-with-request-rules.md): adding rules from a module without ordering pain
- [Object Model](object-model.md): the things that emit signals
- [`gears.object`](https://awesomewm.org/doc/api/libraries/gears.object.html): the underlying machinery
