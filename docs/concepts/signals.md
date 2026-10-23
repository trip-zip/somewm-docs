---
sidebar_position: 8
title: Signals
description: Connect Lua handlers to events, understand their arguments, and know when they run.
---

# Signals

A signal is a named event. Connecting a function to a signal makes that function run when the event occurs. For example, this handler logs the title of each window that gains focus:

```lua
local function log_focus(c)
    print("Focused: " .. (c.name or "untitled"))
end

client.connect_signal("focus", log_focus)
```

`client.connect_signal` listens for all clients. The `c` argument is the client that gained focus. To stop listening, pass the same function to `client.disconnect_signal("focus", log_focus)`.

Signal names are strings. The `property::` prefix conventionally means a property changed. `request::` asks a handler to perform an action. The `::` has no special meaning to Lua.

## Which arguments a handler receives {#who-emits}

The arguments depend on the emitter:

| Connection | Handler receives |
| --- | --- |
| `client.connect_signal("focus", handler)` | The client that gained focus. |
| `widget:connect_signal("button::press", handler)` | That widget, then pointer coordinates, button number, modifiers and hit information. |
| `awesome.connect_signal("volume::changed", handler)` | Exactly the arguments passed to `awesome.emit_signal`. No object is added. |

Notice the dot for `client.connect_signal` and `awesome.connect_signal`, and the colon for a widget instance's `:connect_signal`. An instance signal supplies that instance as the first argument. Global and module signals have their own argument lists. The [signal reference](../reference/signals.md) lists them.

Custom signals let unrelated parts of a configuration communicate. This one passes a volume percentage to its handler:

```lua
local function log_volume(percent)
    print("Volume: " .. percent .. "%")
end

awesome.connect_signal("volume::changed", log_volume)
awesome.emit_signal("volume::changed", 50)
awesome.disconnect_signal("volume::changed", log_volume)
```

The handler prints `Volume: 50%` during `emit_signal`, before the next line runs. Emitting a signal only calls its handlers. It does not perform the operation named by the signal. For example, manually emitting `focus` does not focus a window.

## When handlers run {#dispatch}

Signals emitted directly from Lua run synchronously: the connected functions run before `emit_signal` returns. This includes custom signals and signals emitted by the Lua libraries.

Some notifications from the C compositor wait in a queue. Ordinary focus changes and client geometry changes are examples. The main loop delivers queued notifications before `refresh` and before the next [layout pass](./how-somewm-draws.md). Other C signals run immediately, including `request::manage`, `request::unmanage`, `request::geometry` and client properties such as `property::name` and `property::fullscreen`.

The distinction matters when you read state. After a focus change, `client.focus` can already name the new client while `awful.client.focus.history` still contains the previous result: its signal handler has not run yet. Code that depends on that handler's update can defer the read with `gears.timer.delayed_call`. See [state before a queued handler runs](../reference/signals.md#state-before-a-queued-handler-runs).

Timing can also depend on what caused the change. Screen changes made by Lua through `screen.fake_add`, `screen.fake_remove`, `s:swap()` and `screen.primary = s` notify handlers immediately. Some corresponding changes caused by monitor hotplug are queued. The [dispatch reference](../reference/signals.md#dispatch) lists the signals and exceptions, including the two sources of `property::workarea`.

## Why some notifications wait {#why-notifications-are-queued}

<span id="why-the-queue-is-an-execution-boundary" />

A handler can call compositor functions and change other objects. Calling it halfway through a C operation would let those changes happen before the original operation finishes. Queuing selected notifications allows the operation to finish first.

Each delivery pass processes the events that were waiting when it began, in order. Events added to the queue by those handlers wait for the next pass. A handler can still emit a synchronous signal, which runs immediately.

Consecutive `mouse::move` events for the same object are combined into the latest move, provided no other event intervenes. Other queued events are delivered separately. The queue holds references to its objects and arguments until delivery. Reloading the Lua configuration clears pending references.

## Requests and default handlers {#the-request-pattern}

A `request::*` signal asks handlers to do something. Many client requests have a default handler in `awful.permissions`. For example, a `request::activate` handler decides whether to focus or raise a window. Connecting another handler adds behaviour. It does not remove the default.

To replace a default, disconnect the function that implements it, then connect your replacement. [Replacing a default handler](../guides/replace-default-handler.md) gives complete examples. There is no general cancellation return value for signals: returning `false` from an ordinary handler does not stop the others.

Request arguments vary. `request::activate` supplies a client, a context string and a hints table. `request::tag` supplies a client, a tag or `true` for sticky state, and hints. Check the [reference](../reference/signals.md#requests) before writing a handler.

## Startup order

`rc.lua` runs before existing clients are managed. Requiring a library can connect its default handlers during this time.

1. The first tag creation, or an earlier read of `awful.layout.layouts`, triggers `tag`'s `request::default_layouts`. Connect before either if you want to supply the layouts. Assigning `awful.layout.layouts` directly bypasses this request.
2. After configuration, `client` emits `scanning`. `ruled.client` requests client rules. `awful.keyboard` and `awful.mouse` request default client bindings.
3. Existing clients receive `request::manage`.
4. `client` emits `scanned`, then `awesome` emits `startup`. `ruled.notification` requests notification rules from `startup`.

Connect rule handlers while loading the configuration, before the corresponding startup signal. [Defer startup with request::rules](../guides/defer-startup-with-request-rules.md) shows how to organise this across modules.

## In a handler

Keep handlers short: they run on the compositor's main thread. A slow handler delays input and drawing. Use asynchronous commands for external work.

During `request::unmanage`, the client has been removed from the client list and its tags. Do cleanup there. Do not retain the client and expect it to remain valid after the callback. Save any state you need later while the client is still managed.

`refresh` runs during main-loop processing, even when no frame is presented. It is not a notification that a frame has reached the screen. Errors reaching the compositor's Lua error handler are reported through `debug::error`.
