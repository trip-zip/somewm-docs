---
sidebar_position: 4
title: Signals Reference
description: Signals emitted by SomeWM and the AwesomeWM Lua libraries
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Signals Reference

SomeWM is event-driven. The compositor and the AwesomeWM Lua libraries emit signals at lifecycle points; your `rc.lua` connects handlers to react. For the model behind signals (what they are, when C fires them, the `request::*` pattern, default handlers, ordering), see [Signals (concepts)](../concepts/signals.md).

This page is the lookup reference. Signals are grouped by the class or module that emits them.

## Dispatch

C-emitted signals are queued and drained at `some_refresh()` in 2.0, not run inline with the Wayland event that triggered them. See [Signals (concepts): Dispatch model](../concepts/signals.md#dispatch-model) for the model and the implications.

Currently queued:

- Property: `property::geometry`, `property::position`, `property::size`, `property::x`, `property::y`, `property::width`, `property::height`, `property::active`
- Focus: `focus`, `unfocus`, `client::focus`, `client::unfocus`
- Mouse: `mouse::enter`, `mouse::leave`, `mouse::move` (coalesced per object)
- Lifecycle: `list`, `swapped`
- Request: `request::activate`, `request::urgent`, `request::tag`, `request::select`
- Systray: `request::secondary_activate`, `request::context_menu`, `request::scroll`

All other C-emitted signals (and every Lua-emitted signal) dispatch synchronously today.

## `client` signals

Emitted on the `client` class. Connect with `client.connect_signal("name", handler)` (no `c` argument: handlers receive whichever client the signal was emitted on).

### Lifecycle

| Signal | Args | Notes |
|--------|------|-------|
| `request::manage` | `c, context, hints` | A new client wants to be managed. Default handlers (in `awful.permissions`, `ruled.client`) tag it, place it, and apply rules. Connect after default handlers run if you want to read post-rule properties. `context` is `"new"` or `"startup"`. |
| `request::unmanage` | `c, context, hints` | The client is going away. Default handlers do final cleanup. `context` is `"user"`, `"reparented"`, or `"destroyed"`. Don't access geometry or screen; they may already be invalid. |
| `scanning` | none | Compositor is enumerating already-running clients before any are managed. `ruled.client` emits `request::rules` from here. |
| `scanned` | none | Initial scan is complete. Fires before `awesome.startup` callbacks. |

### Focus and stacking

| Signal | Args | Notes |
|--------|------|-------|
| `focus` | `c` | Client gained focus. |
| `unfocus` | `c` | Client lost focus. Fires before `focus` on the new client. |
| `raised` | `c` | Client moved to top of its layer (see [Client Stacking](/docs/concepts/client-stack)). |
| `lowered` | `c` | Client moved to bottom of its layer. |

### Properties

Each `property::*` fires after the property changes. Read the new value off the client.

| Signal | Notes |
|--------|-------|
| `property::name` | Title changed. |
| `property::class` | Class changed (rare; usually only at startup). |
| `property::geometry` | Size or position changed. |
| `property::floating` | Floating state toggled. |
| `property::fullscreen` | Fullscreen toggled. |
| `property::ontop` | Above-everything layer toggled. |
| `property::above` | Above-normal layer toggled. |
| `property::below` | Below-normal layer toggled. |
| `property::urgent` | Urgency hint changed. Check `c.urgent` inside the handler; fires for both `true` and `false`. |

### Requests

`request::*` signals ask handlers to do something. The default handler usually lives in `awful.permissions` and ships with sensible defaults; replace it by `disconnect_signal` plus your own `connect_signal`. See [Replacing a default handler](../guides/replace-default-handler.md).

| Signal | Args | Notes |
|--------|------|-------|
| `request::activate` | `c, context, hints` | Something asked for the client to become active (focused/raised). Default handler in `awful.permissions.activate`. |
| `request::titlebars` | `c, context, hints` | Client should grow titlebars. Connect to draw them (or skip drawing to opt out). |
| `request::geometry` | `c, context, hints` | Client (or another module) asked to be moved/resized. `context` says why (`"maximized_horizontal"`, `"fullscreen"`, etc.). |
| `request::tag` | `c, tag, hints` | Client needs a tag (after creation, after losing its screen). Default handler: `awful.permissions.tag`. `hints.reason` can be `"screen"`, `"screen-removed"`, `"rules"`. |
| `request::border` | `c, context, hints` | Client wants its border restyled. Default handler: `awful.permissions.update_border`. `context` is one of `"added"`, `"active"`, `"inactive"`, `"floating"`, `"urgent"`, `"maximized"`, `"fullscreen"`. |
| `request::urgent` | `c` | Urgency hint set. Fires alongside `property::urgent`. |
| `request::default_keybindings` | `context` (string) | Class signal emitted once at startup. Connect to register default keybindings via `awful.keyboard.append_client_keybindings`. |
| `request::default_mousebindings` | `context` (string) | Class signal emitted once at startup. Connect to register default mousebindings via `awful.mouse.append_client_mousebindings`. |

## `screen` signals

| Signal | Args | Notes |
|--------|------|-------|
| `added` | `s` | New output connected. |
| `removed` | `s` | Output disconnected. Tags on this screen will get `request::screen` next. |
| `request::desktop_decoration` | `s` | Screen needs tags and wibars. Your handler creates them. See [Tag Persistence](/docs/reference/tag-persistence). |
| `request::wallpaper` | `s` | Screen wants its wallpaper drawn. Default consumers in `gears.wallpaper`. |
| `property::geometry` | `s` | Screen geometry changed (resolution or layout). |
| `property::workarea` | `s` | Workarea (geometry minus struts) changed. Fires when wibars appear or resize. |
| `property::scale` | `s` | Output scale changed. <SomewmOnly /> |
| `property::outputs` | `s` | Output metadata (model, make, refresh) changed. |

## `tag` signals

Connect with `tag.connect_signal("name", handler)`. Handlers receive the tag.

| Signal | Args | Notes |
|--------|------|-------|
| `request::screen` | `t, reason` | Tag's screen was removed and it needs a new one. Default handler: `awful.permissions.tag_screen`. See [Tag Persistence](/docs/reference/tag-persistence). |
| `request::default_layouts` | `context` (string) | Class signal emitted once at startup. Connect to register layouts via `awful.layout.append_default_layouts`. |
| `property::selected` | `t` | Tag was selected or deselected. |
| `property::activated` | `t` | Tag was added to or removed from a screen. |
| `tagged` | `t, c` | Client added to tag. |
| `untagged` | `t, c` | Client removed from tag. |

## `ruled.client` signals

Module-level signals on `ruled.client`. Connect with `ruled.client.connect_signal(...)`.

| Signal | Args | Notes |
|--------|------|-------|
| `request::rules` | none | Fires once on `client.scanning`, after all modules are loaded but before any client is managed. Append rules to `ruled.client.rules` here so every module gets a chance before client matching begins. See [Defer startup with `request::rules`](../guides/defer-startup-with-request-rules.md). |

## `ruled.notification` signals

Module-level signals on `ruled.notification`.

| Signal | Args | Notes |
|--------|------|-------|
| `request::rules` | none | Same shape as `ruled.client` `request::rules`. Append entries to `ruled.notification.rules`. |

## `naughty` signals

| Signal | Args | Notes |
|--------|------|-------|
| `added` | `n` | A notification was created. |
| `destroyed` | `n, reason` | A notification was destroyed. `reason` matches `naughty.notification_closed_reason.*`. |
| `request::display` | `n` | Naughty wants this notification rendered. Connect a handler that builds a notification widget. See [Notifications](/docs/guides/notifications). |
| `request::action_icon` | `a` | An action wants its icon resolved. |

See the [naughty reference](/docs/reference/naughty/) for the full set.

## Layer surface signals <SomewmOnly />

| Signal | Args | Notes |
|--------|------|-------|
| `request::manage` | `l, context, hints` | A layer-shell surface appeared. |
| `request::unmanage` | `l, context, hints` | A layer-shell surface is closing. |
| `request::keyboard` | `l, context, hints` | Layer surface wants keyboard interactivity. |
| `property::has_keyboard_focus` | `l` | Keyboard focus on the layer surface changed. |

See [layer_surface reference](/docs/reference/layer_surface/) for context.

## Lock signals <SomewmOnly />

| Signal | Args | Notes |
|--------|------|-------|
| `lock::activate` | `source` (string) | Session locked. `source` identifies the locker (`"swaylock"`, `"loginctl"`, etc.). |
| `lock::deactivate` | none | Session unlocked. |
| `lock::auth_failed` | none | Password authentication failed. |

## Idle signals <SomewmOnly />

| Signal | Args | Notes |
|--------|------|-------|
| `idle::start` | none | First idle timeout fired. |
| `idle::stop` | none | Activity detected after being idle. |
| `property::idle_inhibited` | none | Combined idle inhibition state changed. |

## DPMS signals <SomewmOnly />

| Signal | Args | Notes |
|--------|------|-------|
| `dpms::off` | none | At least one display entered sleep. |
| `dpms::on` | none | At least one display woke up. |

See [Lock, Idle, and DPMS reference](/docs/reference/lock).

## `awesome` signals

Global signals on `awesome.*`. Connect with `awesome.connect_signal(...)`.

| Signal | Args | Notes |
|--------|------|-------|
| `startup` | none | SomeWM finished starting. Fires after `client.scanned`. Safe to assume all default handlers are connected. |
| `exit` | `restart` (boolean) | SomeWM is shutting down. `restart` is `true` if we're about to re-exec for a hot reload. |
| `refresh` | none | About to redraw. Avoid expensive work in this handler; it fires often. |
| `debug::error` | `msg` | An uncaught Lua error occurred. Default handler logs to stderr. |
| `debug::deprecation` | `msg, args` | A deprecated API was called. |

## Example usage

```lua
-- React to new clients
client.connect_signal("request::manage", function(c, context, hints)
    if c.floating then
        awful.placement.centered(c)
    end
end)

-- Add rules late, from a module
ruled.client.connect_signal("request::rules", function()
    ruled.client.append_rule {
        rule = { class = "Firefox" },
        properties = { tag = screen.primary.tags[2] },
    }
end)

-- Set default layouts at startup
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts {
        awful.layout.suit.tile,
        awful.layout.suit.floating,
    }
end)
```

## See also

- [Signals (concepts)](../concepts/signals.md): what signals are, where they come from, and how `request::*` plus default handlers work
- [Replacing a default handler](../guides/replace-default-handler.md)
- [React to client lifecycle](../guides/react-to-client-lifecycle.md)
- [Defer startup with `request::rules`](../guides/defer-startup-with-request-rules.md)
- [AwesomeWM signals on `gears.object`](https://awesomewm.org/doc/api/libraries/gears.object.html): the connect/emit/disconnect machinery
