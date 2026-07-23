---
title: The Object Model
description: One class mixin behind every kiln object, with open properties and a signal on every write.
sidebar_position: 3
---

# The Object Model

Every object kiln hands you (a client, a screen, a tag, a layer surface, a notification) is built from the same class mixin. Learn its rules once and you know how all five behave. There is no per-class property machinery, no C-side object system, and, importantly, no fixed list of allowed properties.

## Reads and writes

Reading `obj.key` consults, in order: the class's methods, then any declared getter, then plain storage in the object's `_data` table. Writing `obj.key = value` consults any declared setter, else stores the value in `_data`.

Getters and setters exist where one property is the honest face of another. `c.screen` is computed from the client's first tag, never stored, so it cannot go stale. `c.tag` is sugar for `c.tags[1]`, and writing it routes through the real membership write. `t.selected` reads and writes the screen's `selected_tags`. These are the exceptions; almost everything else is plain storage.

## Every write is a signal

A plain write that changes a value emits `property::<key>` on the object. Same value, no signal; new value, always a signal. This is not opt-in and not limited to known keys:

```lua
c.my_project = "kiln"          -- stored, emits property::my_project
client.on("property::my_project", function(c, v)
	-- react to the write
end)
```

There is no property allowlist. Unknown keys are yours: they store, they read back, they emit, exactly like the properties the stdlib itself uses. Rules can set them, widgets can render them, and nothing in kiln will ever collide with or strip them. The flip side: a typo in a property name is silently a new property, and a write outside the dirty lists changes state without drawing a frame (see [Frames and Dirty State](/kiln/concepts/frames-and-dirty)).

## Two buses per signal

Every object carries its own signal bus, and every class carries one more. `obj:emit(name, ...)` fires the instance bus first, then the class bus. So you can listen at either granularity:

```lua
c:on("property::urgent", fn)        -- this one client
client.on("property::urgent", fn)   -- every client, current and future
```

`Class.on` catches the signal on every instance because emission always ends at the class bus; there is no registration step per object and no way for an instance to miss it. `obj:off` and `Class.off` remove listeners. The full signal inventory per class is in the [signals reference](/kiln/reference/signals).

## Listener failures do not cascade

Every listener runs inside `pcall`. A listener that throws does not break the emit, does not skip the listeners after it, and does not take down your session. Instead the failure is reported as an `error` signal on the global bus:

```lua
some.on("error", function(signal, err)
  some.notify { title = "config error", message = signal .. ": " .. err }
end)
```

This is the single place all listener errors surface, which makes it the first thing to wire up when debugging a config; see [Reload and debugging](/kiln/guides/reload-and-debugging).

## Construction is silent

`Class.new(props)` seeds the given properties directly into storage without emitting anything. Initial state is read at construction, not observed: class listeners see only writes that happen after the object exists. For clients this means the interesting moment is not construction but the `map` signal, which fires after C's facts (geometry, `app_id`, `title`, and the rest) are already seeded, so a `map` listener or a [rule](/kiln/guides/client-rules) reads a fully populated object.

## See also

- [Frames and Dirty State](/kiln/concepts/frames-and-dirty)
- [signals reference](/kiln/reference/signals)
- [client reference](/kiln/reference/client)
- [Client rules](/kiln/guides/client-rules)
- [Reload and debugging](/kiln/guides/reload-and-debugging)
