---
title: The Native/Lua Boundary
description: How the native core handles protocols and rendering while Lua defines window management and UI behaviour.
sidebar_position: 5
---

# The Native/Lua Boundary {#the-clua-boundary}

Odin occupies the native side of the policy boundary: the Wayland
protocols, the backends, input devices, client buffers and the renderer are
Odin. Clay, Mesa, libinput, xkbcommon, cairo, pango and LuaJIT remain C
dependencies.

## Native core {#what-c-owns}

The Odin core handles the Wayland protocols, outputs and input devices, client buffers, scene rendering, and PAM authentication. It exposes operations such as focusing a surface and configuring an output.

## Lua configuration {#what-lua-owns}

Lua defines focus behaviour, tags, layouts, rules, keybindings, menus, and notifications. It handles fullscreen and activation requests and declares the UI.

## Events and function calls {#one-event-stream-in-verbs-out}

Odin sends events as tables to a single handler in the standard library, which emits object signals. For example, a native `map` event creates a client object and emits its `map` signal. See the [events reference](/kiln/reference/events).

Lua calls native functions to focus clients, configure surfaces, and set output modes.

## Defaults are policy you can replace

`kiln.defaults` defines the default request handlers. Assign a new function to any `kiln.defaults` field to replace that policy:

```lua
kiln.defaults.fullscreen = function(c, on)
  -- the stock handler does `c.fullscreen = on`
end
```

To remove a request handler without a replacement, take the stock function off the bus; the request is then ignored:

```lua
client.off("request::fullscreen", kiln.defaults.fullscreen)
```
 See [defaults](/kiln/reference/defaults) and [Replacing default policies](/kiln/guides/replace-default-policies).

## Direct core access {#core-is-real-but-not-the-surface}

The [`core` global](/kiln/reference/core) exposes the native API used by the standard library. It bypasses the object model, signals, and policies. Use objects and `kiln.*` for configuration; use `core` when extending the library, such as for [output configuration](/kiln/guides/multi-monitor).

## Why the line is drawn here

Policy lives in Lua so `kiln.reload()` can replace it without restarting, and so your config and the default desktop use the same API.

## See also

- [The Clay Bet](/kiln/concepts/the-clay-bet)
- [The Object Model](/kiln/concepts/object-model)
- [defaults reference](/kiln/reference/defaults)
- [core reference](/kiln/reference/core)
- [events reference](/kiln/reference/events)
- [Replacing default policies](/kiln/guides/replace-default-policies)
