---
sidebar_position: 8
title: Signals
description: Event handlers, queued notifications and synchronous requests in SomeWM 2.0.
---

# Signals

Signals let configuration react to changes without polling. Clients emit focus and title changes, widgets emit redraw requests, and libraries request rules or UI from connected handlers.

## Connect, emit, disconnect

```lua
local function show_volume(value)
    print("Volume: " .. value)
end

awesome.connect_signal("volume::changed", show_volume)
awesome.emit_signal("volume::changed", 50)
awesome.disconnect_signal("volume::changed", show_volume)
```

Signal names are strings. `::` is a naming convention. Emitting a signal invokes its handlers, but does not perform the operation its name describes. Manually emitting `focus`, for example, does not focus a client.

## Two sources: C and Lua

C emits signals for compositor events, and Lua libraries emit signals for their own state and requests. Both can emit on client, screen or tag objects, so the object's name alone does not identify the source or delivery timing.

## Why the queue is an execution boundary

Calling Lua in the middle of a C operation lets a handler change objects that the operation is still using. In 2.0, selected notifications wait in a queue until `some_refresh()` drains them before the `refresh` signal and layout work.

The queue retains Lua references to targets and arguments until delivery. Reload clears references belonging to the old Lua state. This protects queued references but does not guarantee that a client is still managed when its handler runs.

## Dispatch model

### What's queued

Examples include compositor-generated focus, geometry and pointer notifications. Their handlers run after the emitting C operation returns. Object state may already have changed again, so a handler should read current state when it needs the latest value.

Delivery depends on the emitter, not just the signal name. For example, geometry-driven `property::workarea` is queued, while the strut-driven path delivers inline. Lua operations such as `screen.fake_add`, `screen.fake_remove`, screen swaps and `awesome.dpms_on()` use inline delivery.

The [signal reference](../reference/signals.md#dispatch) lists the queued and synchronous paths.

### What stays synchronous

Lua-emitted signals run handlers immediately. C requests needing an immediate result, including `request::manage`, `request::unmanage` and `request::geometry`, also remain synchronous. Screen `added` and `removed` and client scalar-property signals are synchronous too.

### Coalescing

Consecutive queued `mouse::move` events for the same object can merge into one event with the latest coordinates. Coalescing stops at an intervening non-move event, preserving enter/move/leave order. Other queued signals are delivered individually.

### Reentrancy and snapshot semantics

Each drain processes the events present when it started. Events queued by those handlers wait for the next drain. Lua-emitted signals and synchronous C signals still run inline, including when emitted inside a queued handler.

### Practical consequences

Do not assume a queued handler has updated your cache before the next line of code runs. A focus change, for example, can precede the focus-history update. Read the object's property directly when you need its current state, or perform dependent work in the appropriate handler.

## Most signals receive their object as the first argument

```lua
client.connect_signal("property::name", function(c)
    if c.valid then
        print(c.name)
    end
end)
```

Global and module signals have their own argument lists. `request::*` arguments also vary. Check the signal's reference rather than assuming every request receives the same context and hints.

## The `request::*` pattern

A request asks handlers to perform an operation, such as assigning a tag or choosing client geometry. Many requests have default handlers in `awful.permissions` or another library. The prefix does not itself install a handler or determine delivery timing.

Adding a handler keeps existing handlers connected. Replacing policy requires disconnecting the relevant default. See [Replacing a default handler](../guides/replace-default-handler.md).

## Startup ordering

Libraries register handlers as `rc.lua` loads. Some callbacks can run during loading, such as screen decoration and `tag`'s first `request::default_layouts` emission.

After the initial config returns, C emits screen `scanned`, client `scanning` and `scanned`, then the global `startup` signal. Client rule registration is triggered by `scanning`. Notification rule registration is triggered by `startup`. These are separate stages.

Connect rule-registration handlers while the config loads. Initialise the theme before connecting handlers that create widgets. The boolean `awesome.startup` property is distinct from the global signal named `startup`.

## What's safe to do in a handler

Handlers run on the compositor thread. Blocking commands or long work delay input and rendering. Use asynchronous process helpers for external commands.

`request::manage` handlers cannot assume client rules have already finished. Use a rule callback for work that depends on applied properties. During `request::unmanage`, the client is still available for cleanup, but it is being removed. Do not retain it for later work without checking `c.valid`.

Handler errors are caught and reported through `debug::error`. A handler should still leave its own state consistent if an operation fails.

## Connect vs. disconnect vs. replace

Keep a reference to a function if you need to disconnect it. A new anonymous function with the same body is a different handler. For an object instance, use `c:connect_signal(...)`. For class or module signals, use `client.connect_signal(...)` or the module's documented form.

## Where to look next

- [Signal reference](../reference/signals.md)
- [Client lifecycle guide](../guides/react-to-client-lifecycle.md)
- [Rule registration](../guides/defer-startup-with-request-rules.md)
