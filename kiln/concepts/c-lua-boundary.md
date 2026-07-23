---
title: The C/Lua Boundary
description: C owns protocol facts and pixels; Lua owns every policy decision. Where the line sits and why.
sidebar_position: 5
---

# The C/Lua Boundary

kiln splits into a small C core and a Lua standard library, and the line between them is principled, not incidental: **C owns protocol facts and pixels; Lua owns every decision.**

## What C owns

C holds everything that is forced to be C by a protocol or by hardware: the wlroots compositor machinery, input devices, clients' buffer trees in the scene graph, the render reconcile that turns Clay's solved boxes into `wlr_scene` nodes, and PAM authentication for the session lock. C can place a window, focus a surface, configure an output, read a keyboard. What C never does is decide. There is no C code that chooses which client gets focus, what happens when an app asks for fullscreen, where a new window goes, or what a bar contains.

## What Lua owns

Every policy: what focuses and when, how tags behave, what a fullscreen or activation request actually does, where anything sits on screen, what the chrome looks like. Layouts, rules, keybindings, menus, notifications: all Lua, all replaceable, most of it running in your own config's process and language.

## One event stream in, verbs out

C pushes everything it learns into a single event handler as plain tables: a client mapped, a key was pressed, an output changed, a notification arrived. The stdlib owns that handler and translates the stream into the object signals you actually use: a C `map` event becomes a populated client object emitting `map`; a C `request::fullscreen` event becomes the `request::fullscreen` signal on the right client. You almost never see the raw events; they are enumerated in the [events reference](/kiln/reference/events) for completeness.

In the other direction, Lua calls C verbs: focus this handle, configure this surface, set this output's mode. The verbs are mechanisms without opinions; the opinions live in whoever called them.

## Defaults are policy you can replace

The stdlib's own default reactions to requests are not privileged. They live on `some.defaults` as plain functions: the focus successor when a client unmaps, what activation does, how layer surfaces are sized, the entire notification display, what fullscreen, maximize, minimize, and close requests do. Two of them (`successor` and `notify_display`) are read at call time, so assigning a new function is the whole replacement. The rest are connected to the signal buses by value at startup, so replacing one is a swap: take the stock function off the bus, put yours on.

```lua
client.off("request::fullscreen", some.defaults.fullscreen)
client.on("request::fullscreen", function(c, on)
  -- your rule; the stock one is simply `c.fullscreen = on`
end)
```

Because C never acts on a request itself, swapping a handler off with nothing in its place means the request does nothing at all: the client stays exactly where it was. Refusing is as easy as deciding. See the [defaults reference](/kiln/reference/defaults) and [Replacing default policies](/kiln/guides/replace-default-policies).

## core is real, but not the surface

The raw C boundary is exposed to your config as the `core` global: declare-time primitives, client and output verbs, input configuration, timers, spawn. It exists, it is documented in the [core reference](/kiln/reference/core), and the stdlib is built from nothing else, which is itself the proof that the boundary is sufficient. But `core` bypasses the object model: no signals fire, no state is tracked, no policy runs. The intended surface is the one described everywhere else in these docs: objects, signals, `some.*`. Reach for `core` when you are extending the stdlib's own layer (a new output arrangement in [multi-monitor setups](/kiln/guides/multi-monitor), for instance), not for daily configuration.

## Why the line is drawn here

Keeping decisions out of C keeps them changeable at Lua speed: a reload, not a rebuild. It also keeps the C core small enough to audit, and makes the stdlib honest, since it holds no private capability your config lacks. Everything the default desktop does, your `rc.lua` could do differently.

## See also

- [The Clay Thesis](/kiln/concepts/the-clay-thesis)
- [The Object Model](/kiln/concepts/object-model)
- [defaults reference](/kiln/reference/defaults)
- [core reference](/kiln/reference/core)
- [events reference](/kiln/reference/events)
- [Replacing default policies](/kiln/guides/replace-default-policies)
