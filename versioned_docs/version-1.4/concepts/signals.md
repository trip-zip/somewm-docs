---
sidebar_position: 4
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
- `client::*`, `screen::*`, `tag::*`, layer-surface signals fire from the C side
- Module-level signals on `ruled.*`, `naughty`, `awful.layout` fire from the Lua side

## Dispatch

In SomeWM 1.4, every signal dispatches synchronously: when a signal is emitted, its handlers run inline, in the same call stack as the emit. Handlers can re-enter; you can emit further signals from inside a handler and they will run before the original emit returns.

This matches AwesomeWM's behavior. SomeWM 2.0 introduces a queue for some C-emitted signals that drains at deliberate points; that's documented separately in the 2.0 docs when you're working on a 2.0 config.

## Most signals receive their object as the first argument

```lua
client.connect_signal("manage", function(c)
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

The `awful.permissions` module is the home for the default handlers.

`request::*` signals always have a default handler. If you connect *additionally* (without disconnecting the default), both run.

## Startup ordering

Signal ordering matters most at startup. The sequence is:

1. `rc.lua` runs top to bottom. `require` statements pull in libraries, which connect their default handlers.
2. The compositor starts scanning for already-running clients.
3. `client.scanning` fires.
4. `ruled.client` (and `ruled.notification`) emit `request::rules` from inside `scanning`. This is the moment for modules to add rules.
5. `awful.layout` has already wired itself to the first `tag.new` and will emit `request::default_layouts` from there.
6. `awful.keyboard` and `awful.mouse` emit `request::default_keybindings` and `request::default_mousebindings` from the same scanning window.
7. Existing clients are managed (`request::manage` then `manage`).
8. `client.scanned` fires.
9. `awesome.startup` fires.

The takeaway: connect handlers for `request::rules` *before* `client.scanning` fires (i.e. at module load time, in `rc.lua` or the module's top level), and they will run in time. Appending to `ruled.client.rules` directly at module load time also works, but it forces the module to be `require`-d in a specific order, which is exactly what `request::rules` is designed to avoid.

## What's safe to do in a handler

A few rules of thumb:

- **In `manage`, the client is fully tagged and placed.** Reading `c.screen`, `c:tags()`, `c.geometry` is safe.
- **In `request::manage`, default handlers may not have run yet.** If you connect after `awful.permissions` and `ruled.client`, you'll see the post-rule state. If you connect before, you won't.
- **In `unmanage`, the client is gone.** Don't read geometry or screen; they may already be invalid. Save what you need by stashing it on `manage`.
- **In `refresh`, do as little as possible.** It fires often (every redraw). Anything heavy will visibly slow the compositor.
- **Errors in handlers are caught.** The default `debug::error` handler logs them to stderr. Add your own `debug::error` handler if you want to surface them somewhere visible.

## Connect vs. disconnect vs. replace

Three patterns, in increasing invasiveness:

```lua
-- 1. Add a reaction (default handler still runs)
client.connect_signal("manage", function(c)
    if c.class == "Firefox" then c.maximized = true end
end)

-- 2. Stop reacting (your handler stops running; default unaffected)
client.disconnect_signal("manage", my_handler)

-- 3. Replace the default (default stops; yours takes over)
client.disconnect_signal("request::tag", awful.permissions.tag)
client.connect_signal("request::tag", my_tag_handler)
```

For non-`request::` signals, additive `connect_signal` is the common case. For `request::*`, decide whether you want to *add to* or *replace* the default handler.

## Where to look next

- [Signals Reference](../reference/signals.md): every signal SomeWM and the AwesomeWM libraries emit
- [Object Model](/docs/concepts/object-model): the things that emit signals
- [`gears.object`](https://awesomewm.org/doc/api/libraries/gears.object.html): the underlying machinery
