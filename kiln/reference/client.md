---
title: client
description: The client object, its properties, methods, class functions, and signals.
sidebar_position: 2
---

# client

A client is one application window. The `client` global is the class: it carries the class-level signal bus, the focus field, and the history helpers, while each mapped window is an instance you read, write, and call methods on.

```lua
client.on("map", function(c)
  if c.app_id == "mpv" then
    c.floating = true
    c.ontop = true
  end
end)

some.key { mods = { "mod" }, key = "q", press = some.focused(function(c)
  c:close()
end) }
```

## Properties

### Computed properties

These are backed by getters and setters, not plain storage.

| Property | Type | Default | Description |
|---|---|---|---|
| `tag` | tag or nil | nil | Sugar for `c.tags[1]`. Read returns the first tag; write means `c.tags = {t}` (nil writes `{}`). |
| `tags` | list of tags | `{}` | The membership write. Assigning diffs old against new, updates each tag's `clients` list, emits `tagged`/`untagged` per tag, then `property::tags`. Read/write. |
| `screen` | screen or nil | derived | The first tag's screen. Derived on every read, never stored. Read only. |
| `parent` | client or nil | derived | The client object for `transient_for` (a dialog's parent), else nil. Read only. |

### Protocol-seeded properties

Written by the compositor when the window maps or its metadata changes. Read them freely; most are facts, not knobs.

| Property | Type | Default | Description |
|---|---|---|---|
| `handle` | number | seeded | The C-side identity. Key for `core.client.*` and `core.surface`. |
| `x`, `y`, `width`, `height` | number | seeded | Geometry facts. Updated on map and on every size commit. |
| `app_id` | string | seeded | Wayland app id. |
| `title` | string | seeded | Window title. |
| `class`, `instance` | string | X11 only | The X11 WM_CLASS pair. |
| `pid` | number | X11 only | Process id, when the client reports one. |
| `transient_for` | number or nil | seeded | Parent handle for dialogs. Prefer `c.parent` for the object. |
| `window_type` | list of strings | X11 only | _NET_WM_WINDOW_TYPE atoms, in client order. |
| `role` | string or nil | seeded | X11 window role. |
| `icon` | string or nil | seeded | Icon name or path. |
| `override_redirect` | boolean | X11 OR only | True for override-redirect windows (menus, tooltips). No rules, no chrome, no focus-on-open. |
| `wants_focus` | boolean | X11 OR only | Whether an override-redirect window takes focus, per the ICCCM answer. |
| `mapped` | boolean | true on map | Liveness. Maintained by the map/unmap handlers. |

### Policy properties

Written by the standard library, rules, or your config. All read/write, all emit `property::<name>`.

| Property | Type | Default | Description |
|---|---|---|---|
| `floating` | boolean | false | Out of the tiled order; the layout declares the client as a float. |
| `float` | table | seeded on map | The floating box `{x, y, width, height}`. Replace the whole table; one write is one `property::float`. |
| `fullscreen` | boolean | false | The write is the whole verb: a listener mirrors the protocol hint and redraws. |
| `maximized` | boolean | false | Same shape as `fullscreen`. |
| `minimized` | boolean | false | The client stops being declared: not drawn, not hit, not focusable. Focus moves to the successor. |
| `ontop` | boolean | false | Band choice; read by the layout at declare time. |
| `urgent` | boolean | false | Drawn by the border. Set by requests, cleared by `c:focus()`. |
| `titlebar` | boolean | false | Whether the titlebar row is declared. |
| `sticky` | boolean | false | Visible on every tag of its screen. |
| `no_focus` | boolean | false | Set by a rule's `focus = false`; activation policy reads it. |

:::note
There is no property allowlist. Any key you write on a client stores and emits `property::<key>` exactly like the built-in ones, so you can hang your own state off a client and listen for changes to it.
:::

### Which property writes redraw

Writes to `floating`, `float`, `ontop`, `urgent`, `titlebar`, `sticky`, `title`, `app_id`, and `icon` mark the client's screen dirty and redraw (so do `fullscreen`, `maximized`, and `minimized`, through their own listeners). Geometry writes do not: `width` and `height` are written on every size commit, and a redraw there would pin the screen at panel rate. A write outside the list still changes state and emits its signal, but draws nothing until the next frame; call `some.dirty()` if you need one now.

## Methods

| Method | Description |
|---|---|
| `c:raise()` | Move to the tail of every tag's client list, the top of the stack. |
| `c:lower()` | Move to the head, the bottom of the stack. |
| `c:swap(other)` | Exchange positions with `other` in every shared tag. For tiled clients this is "promote to master". |
| `c:focus()` | The canonical focus: activates, clears `urgent`, sets `screen.focused`, emits `focus`. |
| `c:close()` | Polite close (the xdg close request). |
| `c:kill()` | Force kill. See the warning below. |
| `c:toggle_fullscreen()` | Sugar for `c.fullscreen = not c.fullscreen`. |
| `c:toggle_maximized()` | Sugar for `c.maximized = not c.maximized`. |
| `c:toggle_minimized()` | Sugar for `c.minimized = not c.minimized`. |
| `c:grab_move()` | Interactive move. Needs a held button, so call it from a button handler. |
| `c:grab_resize(edges)` | Interactive resize from a compass edge (`"n"`, `"se"`, ...). |
| `c:grab_resize_nearest()` | Interactive resize from the corner nearest the press. |
| `c:move_to(target)` | Move to screen `target`'s selected tag. Focus follows. |

:::warning
`c:kill()` is the impolite path: SIGKILL for a Wayland client, `xcb_kill_client` for an X11 one. If you are coming from AwesomeWM, note that awesome's `c:kill()` is the polite close; in kiln the polite close is `c:close()`.
:::

## Class functions and fields

| Method | Description |
|---|---|
| `client.all()` | Deduplicated list of every client on every screen. |
| `client.focus` | Plain field: the focused client or nil. Set by `c:focus()` and by unmap policy. |
| `client.history()` | Read-only copy of the most-recently-used focus list, most recent first. |
| `client.history.previous()` | The most recent mapped, non-minimized client that is not focused (the mod+Tab target). |
| `client.on(name, fn)` / `client.off(name, fn)` | Class-level signals: catch a signal on every client. |

## Signals

| Signal | Payload | Emitted when |
|---|---|---|
| `map` | none | A window maps. Properties are already seeded when this fires. |
| `unmap` | none | A window unmaps. |
| `destroy` | none | A window is destroyed. |
| `focus` | none | The client gains focus through `c:focus()`. |
| `tagged` | the tag | The client joins a tag. |
| `untagged` | the tag | The client leaves a tag. |
| `property::tags` | the new list | The tag membership changed. |
| `property::<any>` | new value | Any property write that changed the value. |
| `mouse::enter` | none | The pointer enters the client. |
| `request::activate` | `{valid, app_id}` | The client asks to be raised; `valid` means a seat-backed activation token. |
| `request::configure` | `{x, y, width, height}` | An X11 client asks to place or size itself. |
| `request::urgent` | boolean | ICCCM urgency changed. |
| `request::fullscreen` | boolean | The client asks for (or arrives in) fullscreen. |
| `request::maximize` | boolean | Same, for maximized. |
| `request::minimize` | boolean | Same, for minimized. |
| `request::decoration_mode` | mode | The client states its preferred decoration mode. |
| `request::close` | none | A foreign toplevel (a taskbar) asks to close this client. |

Two stock listeners ride the `focus` signal: one promotes the client in the focus history, one raises floating, fullscreen, and maximized clients (tiled clients are deliberately not raised, since their list position is their cell). Every `request::*` signal routes to the matching `some.defaults.*` policy, and each is replaceable wholesale; see [defaults](/kiln/reference/defaults).

## See also

- [Client rules](/kiln/guides/client-rules)
- [Floating and placement](/kiln/guides/floating-and-placement)
- [Replacing default policies](/kiln/guides/replace-default-policies)
- [The object model](/kiln/concepts/object-model)
- [Signal index](/kiln/reference/signals)
