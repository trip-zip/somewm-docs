---
title: Origin Events
description: The 40 raw events C pushes into the single event handler, grouped by class with payload fields.
sidebar_position: 16
---

# Origin Events

Every fact the compositor learns arrives in Lua as one origin event: C pushes a table with the envelope `{ class = ..., name = ..., ...payload }` into the single handler installed with `core.set_event_handler`. The stdlib owns that handler and translates events into the object signals a config actually subscribes to, so a config normally never sees these. They are documented here for two audiences: anyone replacing stdlib behavior at the raw boundary, and anyone debugging over IPC who wants to know exactly what C said.

```lua
-- what a raw event looks like inside the handler
local ev = { class = "client", name = "map", handle = 7,
  x = 0, y = 0, width = 800, height = 600,
  app_id = "foot", title = "foot" }
```

The envelope always carries `class` and `name`; payload fields ride flat beside them. `mods`, where present, is a table of four booleans: `shift`, `ctrl`, `alt`, `super`. There are 40 events in 11 classes.

## client

| Event | Payload | Emitted when |
|---|---|---|
| `map` | `handle, x, y, width, height, app_id, title`; X11 extras when present: `wm_class, wm_instance, pid, transient_for, window_type, role, icon, override_redirect, wants_focus`; initial state only when set: `fullscreen, maximized, minimized` | A client surface becomes visible. X11 hints are absent (`nil`) for Wayland clients and for X clients that do not declare them; `override_redirect` marshals only when true, and carries `wants_focus` with it. |
| `unmap` | `handle` | The surface is no longer visible. |
| `destroy` | `handle` | The client is gone. |
| `commit_size` | `handle, width, height` | The client committed a new surface size. |
| `metadata` | `handle, app_id, title, wm_class, wm_instance, role, icon` | Title, app id, or X11 metadata changed. A vanished field marshals as `nil`, which is how the reader clears it. |
| `request::decoration_mode` | `handle, mode` | The client asked for a decoration mode. |
| `request::activate` | `handle, valid, app_id` | An activation request (xdg-activation) arrived; `valid` says whether the token was seat-backed. |
| `request::configure` | `handle, x, y, width, height` | The client asked for a geometry (X11 configure request). |
| `request::urgent` | `handle, urgent` | The client asked for attention. |
| `request::fullscreen` | `handle, on` | The client asked to enter or leave fullscreen. |
| `request::maximize` | `handle, on` | The client asked to (un)maximize. |
| `request::minimize` | `handle, on` | The client asked to (un)minimize. |
| `request::close` | `handle` | Something asked for this client to be closed. |

## input

| Event | Payload | Emitted when |
|---|---|---|
| `key` | `keysym, key, utf8, pressed, mods` | A key went down or up. `utf8` is always present (empty string mid-compose or on release). |
| `button` | `button, pressed, x, y, screen, client, mods` | A pointer button. `client` is the handle under the pointer, `nil` when the topmost node is chrome or nothing. |
| `motion` | `x, y, screen, client` | The pointer moved. Same `client` rule as `button`. |
| `axis` | `dx, dy, x, y, screen, client, mods` | A scroll. Same `client` rule as `button`. |
| `pointer_enter` | `handle` | The pointer crossed onto a client; `handle` is `nil` when it is over no client. |

## output

| Event | Payload | Emitted when |
|---|---|---|
| `add` | `output` | An output appeared. `output` is its name. |
| `remove` | `output` | An output is gone. |
| `change` | `output` | An output's mode, scale, position, or enabled state changed. |

## layer

| Event | Payload | Emitted when |
|---|---|---|
| `map` | `handle, namespace, output, layer, interactivity, anchors, margin, exclusive, width, height` | A layer-shell surface mapped. `output` is `nil` when the client let the compositor choose. `anchors` is `{top, bottom, left, right}` booleans; `margin` is `{top, right, bottom, left}` numbers. Answer with `core.layer_configure`. |
| `commit` | same as `map` | The surface committed new layer state. |
| `unmap` | `handle` | The surface is hidden. |
| `destroy` | `handle` | The surface is gone. |

## session

| Event | Payload | Emitted when |
|---|---|---|
| `lock` | `kind` | The session locked. `kind` is `"ext"` (an external locker) or `"native"` (`core.lock`). Informational: Lua cannot veto a lock. |
| `unlock` | none | The session unlocked. |
| `key` | as input `key` | A key while natively locked. Delivered only to the lockscreen path, never reaches bindings or clients. |

## drag

| Event | Payload | Emitted when |
|---|---|---|
| `start` | none | A drag-and-drop began. |
| `end` | none | The drag ended. |

## notify

| Event | Payload | Emitted when |
|---|---|---|
| `notify` | `id, replaces_id, app_name, app_icon, summary, body, urgency, image, expire_timeout, actions, hints` | A desktop notification arrived. `replaces_id` only when nonzero; `image` is an image-cache key, never pixels; `actions` is `{ { key, label }, ... }` in the order the client sent them; `hints` carries every untyped hint flat and verbatim. |
| `close` | `id` | The sender asked to close a notification. |

## tray

| Event | Payload | Emitted when |
|---|---|---|
| `item` | `service, id, title, status, icon` | A status-notifier item appeared or changed. `icon` is an image-cache key or a passed-through icon name, `nil` when the item offered neither. |
| `gone` | `service` | The item left the bus. |

## frame

| Event | Payload | Emitted when |
|---|---|---|
| `tick` | `screen, dt` | An armed frame clock (`core.tick`) completed a cycle; `dt` is the true delta. |

## spawn

| Event | Payload | Emitted when |
|---|---|---|
| `out` | `id, fd, data` | A `core.spawn_pipe` child wrote output. `fd` is 1 (stdout) or 2 (stderr); `data` is the raw chunk, possibly without a trailing newline, and may contain embedded NULs. |
| `exit` | `id, code` | The child exited and both streams hit EOF. `code` is the exit status, or 128 plus the signal number. Always after the last `out`. |

## idle

| Event | Payload | Emitted when |
|---|---|---|
| `start` | none | The idle timeout (`core.set_idle_timeout`) elapsed with no input. |
| `stop` | none | Input returned. `start` and `stop` strictly alternate. |
| `inhibit` | `on` | A client took or released an idle inhibitor. |

## See also

- [Signals](/kiln/reference/signals): the object-signal layer these translate into, which is what configs subscribe to
- [core](/kiln/reference/core): the verbs you answer these events with
- [The C/Lua boundary](/kiln/concepts/c-lua-boundary): why events are the only way facts cross
- [IPC and scripting](/kiln/guides/ipc-and-scripting): observing a live session from a shell
