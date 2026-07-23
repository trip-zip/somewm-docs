---
title: Signal Index
description: Every signal in kiln, per object class, with payloads.
sidebar_position: 14
---

# Signal Index

Every signal name in one place. Instance listeners attach with `obj:on(name, fn)`, class listeners with `Class.on(name, fn)`; an instance emission fires the instance bus then the class bus. Listeners are pcall-isolated: a listener error surfaces as `error` on the global bus instead of breaking dispatch. See [The object model](/kiln/concepts/object-model).

```lua
client.on("focus", function(c) print("focused", c.title) end)
some.on("error", function(signal, err) some.notify { title = signal, message = err } end)
```

## client

| Signal | Payload | Emitted when |
|---|---|---|
| `map` | none | A window maps; properties already seeded. |
| `unmap` | none | A window unmaps. |
| `destroy` | none | A window is destroyed. |
| `focus` | none | The client gains focus through `c:focus()`. |
| `tagged` | the tag | The client joins a tag. |
| `untagged` | the tag | The client leaves a tag. |
| `mouse::enter` | none | The pointer enters the client. |
| `request::activate` | `{valid, app_id}` | The client asks to be raised; `valid` means a seat-backed token. |
| `request::configure` | `{x, y, width, height}` | An X11 client asks to place or size itself. |
| `request::urgent` | boolean | ICCCM urgency changed. |
| `request::fullscreen` | boolean | The client asks for (or maps already in) fullscreen. |
| `request::maximize` | boolean | Same, for maximized. |
| `request::minimize` | boolean | Same, for minimized. |
| `request::decoration_mode` | mode | The client states its preferred decoration mode. |
| `request::close` | none | A foreign toplevel (taskbar) asks to close this client. |
| `property::<any>` | new value | A property write changed the value (`property::tags` carries the new list). |

## tag

| Signal | Payload | Emitted when |
|---|---|---|
| `property::<any>` | new value | A tag property write changed the value. |

Tags emit only property signals. Selection changes surface as `property::selected_tags` on the screen.

## screen

| Signal | Payload | Emitted when |
|---|---|---|
| `added` | none | A new output appears (restated per screen on reload). |
| `changed` | none | Mode, scale, position, or enabled state changed. |
| `removed` | none | The output is gone; clients were already rehomed. |
| `property::<any>` | new value | A property write changed the value, notably `property::selected_tags` on every tag switch. |

## layer

| Signal | Payload | Emitted when |
|---|---|---|
| `map` | none | The surface's initial commit; blocks until a policy answers. |
| `commit` | none | The surface committed new facts. |
| `unmap` | none | The surface unmapped. |
| `destroy` | none | The surface is gone. |
| `property::<any>` | new value | A property write changed the value. |

## notification

| Signal | Payload | Emitted when |
|---|---|---|
| `added` | none | A notification is created, before display. |
| `dismissed` | reason | The notification ended (`"expired"`, `"user"`, `"action"`, `"closed"`). |
| `invoked` | action key | An action button fired. |
| `property::<any>` | new value | A property write changed the value. |

## drag (bus)

The `drag` global is a plain signal bus (`drag.on`, `drag.off`), not an object class: drag-and-drop is arbitrated by the compositor, and these are informational.

| Signal | Payload | Emitted when |
|---|---|---|
| `start` | none | A drag-and-drop operation began. |
| `end` | none | It ended. |

## some.on (global bus)

Subscribe with `some.on(name, fn)`.

| Signal | Payload | Emitted when |
|---|---|---|
| `error` | signal name, error message | Any listener anywhere raised an error (also printed to stderr). |
| `idle::start` | none | The armed idle timeout elapsed with no input. |
| `idle::stop` | none | Input resumed after idle. |
| `idle::inhibit` | boolean | A visible idle inhibitor appeared (true) or went away (false). |

## See also

- [The object model](/kiln/concepts/object-model)
- [client](/kiln/reference/client), [tag](/kiln/reference/tag), [screen](/kiln/reference/screen), [layer](/kiln/reference/layer), [notification](/kiln/reference/notification)
- [Lockscreen and idle](/kiln/guides/lockscreen-and-idle)
