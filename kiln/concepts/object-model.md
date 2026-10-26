---
title: The Object Model
description: One class mixin behind every kiln object, with open properties and a signal on every write.
sidebar_position: 3
---

# The Object Model

Clients, screens, tags, layer surfaces, and notifications use the same class mixin. Properties are not restricted to a fixed list.

## Reads and writes

Reading `obj.key` consults, in order: the class's methods, then any declared getter, then plain storage in the object's `_data` table. Writing `obj.key = value` consults any declared setter, else stores the value in `_data`.

`c.screen` is computed from the client's first tag. `c.tag` reads `c.tags[1]`; assigning it updates tag membership. `t.selected` reads and writes the screen's `selected_tags`. Most other properties are stored directly.

## Every write is a signal

A plain property write emits `property::<key>` when the value changes. This also applies to custom properties:

```lua
c.my_project = "kiln"          -- stored, emits property::my_project
client.on("property::my_project", function(c, v)
	-- react to the write
end)
```

A misspelled property name creates a new property without an error. Writes to a destroyed object are ignored. Writes outside the [dirty lists](/kiln/concepts/frames-and-dirty) change state without triggering a redraw.

## Two buses per signal

`obj:emit(name, ...)` calls the object's listeners first, then the class's listeners:

```lua
c:on("property::urgent", fn)        -- this one client
client.on("property::urgent", fn)   -- every client, current and future
```

`obj:off` and `Class.off` remove listeners. See the [signals reference](/kiln/reference/signals) for each class's signals.

## Listener failures do not cascade

Listeners run inside `pcall`. If one fails, the others still run. The failure emits a global `error` signal:

```lua
kiln.on("error", function(signal, err)
  kiln.notify { title = "config error", message = signal .. ": " .. err }
end)
```

## Construction is silent

`Class.new(props)` stores initial properties without emitting signals. The client `map` signal fires after geometry, `app_id`, title, and other initial properties are set. A `map` listener or [rule](/kiln/guides/client-rules) can read them then.

## See also

- [Frames and Dirty State](/kiln/concepts/frames-and-dirty)
- [signals reference](/kiln/reference/signals)
- [client reference](/kiln/reference/client)
- [Client rules](/kiln/guides/client-rules)
- [Reload and debugging](/kiln/guides/reload-and-debugging)
