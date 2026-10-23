---
sidebar_position: 4
title: Signals Reference
description: Signals emitted by SomeWM and the AwesomeWM Lua libraries
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Signals Reference

Signals are grouped by the object or module that emits them. See [signal concepts](../concepts/signals.md) for connecting handlers and replacing defaults.

## Dispatch

The C-generated signals listed below are queued and drained at `some_refresh()`. Other C-generated signals and all Lua-emitted signals run synchronously. See [Signals (concepts): Dispatch model](../concepts/signals.md#dispatch-model) for the model and the implications.

Currently queued:

- Property: `property::geometry`, `property::position`, `property::size`, `property::x`, `property::y`, `property::width`, `property::height`, `property::active`
- Focus: `focus`, `unfocus`, `client::focus`, `client::unfocus`
- Mouse: `mouse::enter`, `mouse::leave`, `mouse::move` (coalesced per object)
- Lifecycle: `list`, `swapped`
- Request: `request::activate`, `request::urgent`
- Systray: `request::secondary_activate`, `request::context_menu`, `request::scroll`
- Output: `property::enabled`, `property::scale`, `property::transform`, `property::mode`, `property::adaptive_sync`, `property::screen` (screen attached), and the output class `added`
- Screen: `property::scale`, `property::geometry`, `property::workarea`, `primary_changed`, and the screen class `list` and `property::_viewports`
- Layer shell: `property::layer`, `property::anchor`, `property::exclusive_zone`, `property::keyboard_interactive`, `property::margin`
- Globals: `xkb::map_changed`, `xkb::group_changed`, `idle::stop`, `dpms::on`, `spawn::timeout`, `spawn::completed`, `switch::toggle`, `screen::focus`, `client::map`, `client::unmap`, `client::property::geometry`

Dispatch depends on the emitter, not only the signal name. Every Lua `emit_signal()` runs inline. These C paths also run inline:

| Path | Signals |
| --- | --- |
| Client lifecycle | `request::manage`, `request::unmanage`, `scanning`, `scanned` |
| Client requests and scalar properties | `request::geometry`, `property::name`, `property::fullscreen`, and other properties absent from the queue list |
| Screen lifecycle | `added`, `removed`, `request::focus_restore` |
| Lua screen operations | `fake_add`/`fake_remove` deliver `list`, `swap` delivers `list` and `swapped`, setting `screen.primary` delivers `primary_changed` |
| Strut changes | `property::workarea`, including wibar changes |
| Output teardown | `removed`, and `property::screen` when detaching the screen |
| Lua output setters | Property notifications from the setter, apart from the queued screen geometry updates it causes |
| Input and layer lifecycle | Key/button and grabber callbacks, layer manage/unmanage and keyboard requests |
| Idle, power, and sleep | `idle::start` before its timeout callback, `awesome.dpms_on()` notifications, `logind::prepare_sleep` before suspend |

D-Bus method handlers also run inline. `request::tag` and `request::select` are Lua-emitted and synchronous.

### State before a queued handler runs

The queue drains before `refresh` and layout. An object's state can change before its queued handlers run. For example, `client.focus` may already name the new client while focus history still reflects the previous event. Use `gears.timer.delayed_call()` when a read needs to follow those handlers.

Queued arguments retain their emitted values, but reading the object returns its current state. Events for screens or outputs removed before delivery are dropped. Only `valid` remains readable on these invalid objects, and `screen[s]` returns nil for a removed screen.

## `client` signals

Connect with `client.connect_signal("name", handler)`. Instance signals pass the client as the first argument. Class signals such as `scanning` do not.

### Lifecycle

| Signal | Args | Notes |
|--------|------|-------|
| `request::manage` | `c, context, hints` | A new client wants to be managed. Default handlers (in `awful.permissions`, `ruled.client`) tag it, place it, and apply rules. Class-handler connection order does not guarantee execution order. Use a rule callback to read post-rule properties. `context` is `"new"` or `"startup"`. |
| `request::unmanage` | `c, context, hints` | The client is going away. Default handlers do final cleanup. `context` is `"user"`, `"reparented"`, or `"destroyed"`. The client is still valid and its geometry and screen are readable, but its tags have already been detached. |
| `scanning` | none | Compositor is enumerating already-running clients before any are managed. `ruled.client` emits `request::rules` from here. |
| `scanned` | none | Initial scan is complete. Fires before `awesome.startup` callbacks. |

### Focus and stacking

| Signal | Args | Notes |
|--------|------|-------|
| `focus` | `c` | Client gained focus. |
| `unfocus` | `c` | Client lost focus. Fires before `focus` on the new client. |
| `raised` | `c` | Client moved to top of its layer (see [Client Stacking](../concepts/client-stack.md)). |
| `lowered` | `c` | Client moved to bottom of its layer. |

### Properties

Each `property::*` fires after the property changes. Read the new value off the client.

| Signal | Notes |
|--------|-------|
| `property::name` | Title changed. |
| `property::class` | Class changed (usually at startup). |
| `property::geometry` | Size or position changed. |
| `property::floating` | Floating state toggled. |
| `property::fullscreen` | Fullscreen toggled. |
| `property::ontop` | Above-everything layer toggled. |
| `property::above` | Above-normal layer toggled. |
| `property::below` | Below-normal layer toggled. |
| `property::urgent` | Urgency hint changed. Check `c.urgent` inside the handler. Fires for both `true` and `false`. |

### Requests

`request::*` signals ask handlers to do something. Replace a default handler by disconnecting it and connecting your replacement. See [Replacing a default handler](../guides/replace-default-handler.md).

| Signal | Args | Notes |
|--------|------|-------|
| `request::activate` | `c, context, hints` | Something asked for the client to become active (focused/raised). Default handler in `awful.permissions.activate`. |
| `request::titlebars` | `c, context, hints` | Client should grow titlebars. Connect to draw them (or skip drawing to opt out). |
| `request::geometry` | `c, context, hints` | Client (or another module) asked to be moved/resized. `context` says why (`"maximized_horizontal"`, `"fullscreen"`, etc.). |
| `request::tag` | `c, tag_or_true, hints` | Client needs a tag (after creation, after losing its screen). Default handler: `awful.permissions.tag`. A true second argument requests sticky state. `hints.reason` can be `"screen"`, `"screen-removed"`, `"rules"`. |
| `request::border` | `c, context, hints` | Client wants its border restyled. Default handler: `awful.permissions.update_border`. `context` is one of `"added"`, `"active"`, `"inactive"`, `"floating"`, `"urgent"`, `"maximized"`, `"fullscreen"`. |
| `request::urgent` | `c, urgent` | Application requested an urgency change. The default handler decides whether to set `c.urgent`. |
| `request::default_keybindings` | `context` (string) | Class signal emitted once at startup. Connect to register default keybindings via `awful.keyboard.append_client_keybindings`. |
| `request::default_mousebindings` | `context` (string) | Class signal emitted once at startup. Connect to register default mousebindings via `awful.mouse.append_client_mousebindings`. |

## `screen` signals

| Signal | Args | Notes |
|--------|------|-------|
| `added` | `s` | New output connected. |
| `removed` | `s` | Output disconnected. Tags on this screen will get `request::screen` next. |
| `request::desktop_decoration` | `s` | Screen needs tags and wibars. Your handler creates them. See [Tag Persistence](tag-persistence.md). |
| `request::wallpaper` | `s` | Screen wants its wallpaper drawn. The default handler builds it with `awful.wallpaper`. |
| `request::focus_restore` | `s` | Something that had focus went away (client closed, layer surface dismissed, session unlocked, monitor disconnected). Default handler: `awful.permissions.focus_restore`, which activates the most recent visible client from focus history. If no handler focuses a client, C tries the topmost eligible client on the monitor. <SomewmOnly /> |
| `property::geometry` | `s, old_geometry` | Screen geometry changed (resolution or layout). |
| `property::workarea` | `s, old_workarea` | Workarea (geometry minus struts) changed. Fires when wibars appear or resize. |
| `property::scale` | `s` | Output scale changed. <SomewmOnly /> |
| `property::outputs` | `s` | Output metadata (model, make, refresh) changed. |

## `tag` signals

Connect with `tag.connect_signal("name", handler)`. Handlers receive the tag.

| Signal | Args | Notes |
|--------|------|-------|
| `request::screen` | `t, reason` | Tag's screen was removed and it needs a new one. Default handler: `awful.permissions.tag_screen`. See [Tag Persistence](tag-persistence.md). |
| `request::default_layouts` | `context` (string) | Class signal emitted once at startup. Connect to register layouts via `awful.layout.append_default_layouts`. |
| `property::selected` | `t` | Tag was selected or deselected. |
| `property::activated` | `t` | Tag was added to or removed from a screen. |
| `tagged` | `t, c` | Client added to tag. |
| `untagged` | `t, c` | Client removed from tag. |

## `ruled.client` signals

Module-level signals on `ruled.client`. Connect with `ruled.client.connect_signal(...)`.

| Signal | Args | Notes |
|--------|------|-------|
| `request::rules` | none | Fires once on `client.scanning`, after all modules are loaded but before any client is managed. Call `ruled.client.append_rule()` here before client matching begins. See [Defer startup with `request::rules`](../guides/defer-startup-with-request-rules.md). |

## `ruled.notification` signals

Module-level signals on `ruled.notification`.

| Signal | Args | Notes |
|--------|------|-------|
| `request::rules` | none | Fires from `awesome.startup`. Register rules with `ruled.notification.append_rule()`. |

## `naughty` signals

| Signal | Args | Notes |
|--------|------|-------|
| `added` | `n` | A notification was created. |
| `destroyed` | `n, reason` | A notification was destroyed. `reason` matches `naughty.notification_closed_reason.*`. |
| `request::display` | `n` | Naughty wants this notification rendered. Connect a handler that builds a notification widget. See [Notifications](../guides/notifications.md). |
| `request::action_icon` | `a` | An action wants its icon resolved. |

See the [naughty reference](naughty/index.md) for the full set.

## Layer surface signals <SomewmOnly />

| Signal | Args | Notes |
|--------|------|-------|
| `request::manage` | `l, context, hints` | A layer-shell surface appeared. |
| `request::unmanage` | `l, context, hints` | A layer-shell surface is closing. |
| `request::keyboard` | `l, context, hints` | Layer surface wants keyboard interactivity. |
| `property::has_keyboard_focus` | `l` | Keyboard focus on the layer surface changed. |

See [layer_surface reference](layer_surface/index.md) for context.

## Lock signals <SomewmOnly />

| Signal | Args | Notes |
|--------|------|-------|
| `lock::activate` | `source` (string) | Session locked via `awesome.lock()`. `source` is always `"user"`. |
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

See [Lock, Idle, and DPMS reference](lock.md).

## `awesome` signals

Global signals on `awesome.*`. Connect with `awesome.connect_signal(...)`.

| Signal | Args | Notes |
|--------|------|-------|
| `startup` | none | SomeWM finished starting. Fires after `client.scanned`. Safe to assume all default handlers are connected. |
| `exit` | `restart` (boolean) | SomeWM is shutting down. `restart` is `true` for a Lua hot reload in the same process. |
| `refresh` | none | About to redraw. Avoid expensive work in this handler. It fires often. |
| `debug::error` | `msg` | An uncaught Lua error occurred. Default handler logs to stderr. |

## Example usage

```lua
local gears = require("gears")

client.connect_signal("focus", function(c)
    gears.timer.delayed_call(function()
        if c.valid then print(c.name) end
    end)
end)
```

## See also

- [Signals (concepts)](../concepts/signals.md): what signals are, where they come from, and how `request::*` plus default handlers work
- [Replacing a default handler](../guides/replace-default-handler.md)
- [React to client lifecycle](../guides/react-to-client-lifecycle.md)
- [Defer startup with `request::rules`](../guides/defer-startup-with-request-rules.md)
- [AwesomeWM signals on `gears.object`](https://awesomewm.org/doc/api/libraries/gears.object.html): the connect/emit/disconnect machinery
