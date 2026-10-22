---
title: The C/Lua Boundary
description: How the C core handles protocols and rendering while Lua defines window management and UI behaviour.
sidebar_position: 6
---

# The C/Lua Boundary

## C core {#what-c-owns}

The C core handles wlroots, input devices, client buffers, scene rendering, and PAM authentication. It exposes operations such as focusing a surface and configuring an output.

## Lua configuration {#what-lua-owns}

Lua defines focus behaviour, tags, layouts, rules, keybindings, menus, and notifications. It handles fullscreen and activation requests and declares the UI.

## Events and function calls {#one-event-stream-in-verbs-out}

C sends events as tables to a single handler in the standard library, which emits object signals. For example, a C `map` event creates a client object and emits its `map` signal. See the [events reference](/kiln/reference/events).

Lua calls C functions to focus clients, configure surfaces, and set output modes.

## Defaults are policy you can replace

`kiln.defaults` defines the default request handlers. Assign a new function to replace `successor` or `notify_display`, which are read at call time. Other handlers are registered at startup; disconnect the old handler and connect its replacement:

```lua
client.off("request::fullscreen", kiln.defaults.fullscreen)
client.on("request::fullscreen", function(c, on)
  -- your rule; the stock one is simply `c.fullscreen = on`
end)
```

Removing a handler without a replacement leaves the request unhandled. See [defaults](/kiln/reference/defaults) and [Replacing default policies](/kiln/guides/replace-default-policies).

## Direct C access {#core-is-real-but-not-the-surface}

The [`core` global](/kiln/reference/core) exposes the C API used by the standard library. It bypasses the object model, signals, and policies. Use objects and `kiln.*` for configuration; use `core` when extending the library, such as for [output configuration](/kiln/guides/multi-monitor).

## Why the line is drawn here

Lua configuration can be reloaded without rebuilding C. It uses the same public API as the default desktop.

## See also

- [The Clay Bet](/kiln/concepts/the-clay-bet)
- [The Object Model](/kiln/concepts/object-model)
- [defaults reference](/kiln/reference/defaults)
- [core reference](/kiln/reference/core)
- [events reference](/kiln/reference/events)
- [Replacing default policies](/kiln/guides/replace-default-policies)
