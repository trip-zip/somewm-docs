---
sidebar_position: 4
title: Signals
description: Signal arguments, synchronous dispatch and request handlers in SomeWM 1.4.
---

# Signals

Signals call registered handlers when an object changes or requests an action. In SomeWM 1.4, handlers run synchronously: emitting a signal runs its handlers before returning.

## Connect, emit, disconnect

This custom global signal passes exactly the arguments supplied by the caller:

```lua
local function report(value)
    print("Value: " .. value)
end

awesome.connect_signal("example::value", report)
awesome.emit_signal("example::value", 42)
awesome.disconnect_signal("example::value", report)
```

Keep the function reference if you need to disconnect it. Signal names are strings. The `property::` and `request::` prefixes describe conventions, not special Lua syntax.

## Two sources: C and Lua

The C compositor emits lifecycle events such as client management and output changes. Lua libraries also emit signals, including property changes and requests for rules, layouts or notification widgets. A signal's object or name alone does not tell you which language emits it.

## Dispatch

Handlers can emit more signals, and those nested handlers run before the original emission returns. Avoid changing a property unconditionally from its own change handler, which can cause recursive updates.

Synchronous dispatch does not mean every operation is immediate. Libraries can schedule work with `gears.timer.delayed_call`, then emit signals when that work runs.

## Most signals receive their object as the first argument

For an instance signal, a handler receives the object followed by the signal's arguments:

```lua
local gears = require("gears")
local object = gears.object {}

object:connect_signal("example::value", function(self, value)
    assert(self == object)
    print(value)
end)
object:emit_signal("example::value", 42)
```

Class listeners such as `client.connect_signal("focus", handler)` receive the client that emitted the event. Global signals such as `awesome`'s `startup` do not add an object argument. Consult the [signal reference](../reference/signals.md) for each signature.

## The `request::*` pattern

A request asks handlers to perform an action. For example, `request::activate` asks for client activation, and `ruled.client`'s `request::rules` asks configuration modules to register rules.

Many requests have handlers in `awful.permissions` or another library. Connecting an additional handler leaves existing handlers in place. To replace one, disconnect that specific function before connecting yours. A request is not guaranteed to have a default handler.

## Startup ordering

Register handlers at module load time in `rc.lua`. Requiring a library may connect its own handlers, and registering screen decoration can immediately configure screens that already exist.

The timing depends on the request:

| Request | Trigger |
| --- | --- |
| `tag`'s `request::default_layouts` | The layout library's first request for default layouts |
| `ruled.client`'s `request::rules` | Client scanning after config loading |
| Client default key and mouse bindings | Client scanning after config loading |
| `ruled.notification`'s `request::rules` | The global `startup` signal, when a rules handler is connected |

After config loading, the compositor emits `screen.scanned`, `client.scanning`, `client.scanned` and the global `startup` signal. `awesome.startup` is also a boolean property, distinct from the signal.

## What's safe to do in a handler

- Keep handlers short. Blocking work also blocks the compositor. Use asynchronous process helpers for external commands.
- In `request::manage`, other handlers may still be applying rules. In `manage`, the management request has completed.
- In an unmanage handler, do not retain the client for later use without checking `c.valid`.
- Avoid expensive work in `refresh`, which runs frequently.
- Errors are reported through the error-handling machinery. The default config displays them with notifications.

## Connect vs. disconnect vs. replace

Use a custom signal to test a callback. Manually emitting `focus` or `manage` invokes handlers but does not perform the underlying compositor operation, and can leave library state inconsistent.

For actual activation, use `c:activate { context = "my_config", raise = true }`. To observe it, connect to `focus`.

## Where to look next

- [Signals Reference](../reference/signals.md)
- [Object Model](object-model.md)
- [Architecture](architecture.md)
