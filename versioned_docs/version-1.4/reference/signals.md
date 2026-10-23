---
sidebar_position: 4
title: Signals Reference
description: Signals emitted by SomeWM and the AwesomeWM Lua libraries
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Signals Reference

Signals run synchronously in SomeWM 1.4. Handlers finish before the emitting call returns. The tables group signals by their emitter. See [Signals](../concepts/signals.md) for handler ordering and the `request::*` pattern.

## `client` signals

Emitted on the `client` class. Connect with `client.connect_signal("name", handler)`.

### Lifecycle

| Signal | Args | Notes |
|--------|------|-------|
| `request::manage` | `c, context, hints` | A new client wants to be managed. Default handlers (in `awful.permissions`, `ruled.client`) tag it, place it, and apply rules. Connect after default handlers run if you want to read post-rule properties. |
| `manage` | `c` | Legacy notification after `request::manage`. Prefer `request::manage` for new handlers. |
| `request::unmanage` | `c, context, hints` | The client is closing. Default handlers do final cleanup. |
| `unmanage` | `c` | The client is gone. Don't access geometry or screen. They may already be invalid. |
| `scanning` | none | Compositor is enumerating already-running clients before any are managed. `ruled.client` emits `request::rules` from here. |
| `scanned` | none | Initial scan is complete. Fires before the `awesome` `startup` signal. |

### Focus and stacking

| Signal | Args | Notes |
|--------|------|-------|
| `focus` | `c` | Client gained focus. |
| `unfocus` | `c` | Client lost focus. Fires before `focus` on the new client. |
| `raised` | `c` | Client moved to top of its layer (see [Client Stacking](/docs/1.4/concepts/client-stack)). |
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
| `property::ontop` | Ontop layer toggled. Other layers can still appear above it. |
| `property::above` | Above-normal layer toggled. |
| `property::below` | Below-normal layer toggled. |
| `property::urgent` | Urgency hint changed. Check `c.urgent` inside the handler. Fires for both `true` and `false`. |

### Requests

`request::*` signals ask handlers to do something. Most default handlers live in `awful.permissions`. Disconnect the named handler before replacing it.

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
| `added` | `s` | Screen created, including when an output is enabled. |
| `removed` | `s` | Screen removed, including when an output is disabled. Tag handlers request replacement screens. |
| `request::desktop_decoration` | `s` | Screen needs tags and wibars. Your handler creates them. See [Tag Persistence](/docs/1.4/reference/tag-persistence). |
| `request::wallpaper` | `s` | Screen wants its wallpaper drawn. Default consumers in `gears.wallpaper`. |
| `property::geometry` | `s` | Screen geometry changed (resolution or layout). |
| `property::workarea` | `s` | Workarea (geometry minus struts) changed. Fires when wibars appear or resize. |
| `property::scale` | `s` | Output scale changed. <SomewmOnly /> |
| `property::outputs` | `s` | Screen output metadata changed. |

## `tag` signals

Connect with `tag.connect_signal("name", handler)`. Object signals receive the tag. `request::default_layouts` is a class signal.

| Signal | Args | Notes |
|--------|------|-------|
| `request::screen` | `t, reason` | Tag's screen was removed and it needs a new one. Default handler: `awful.permissions.tag_screen`. See [Tag Persistence](/docs/1.4/reference/tag-persistence). |
| `request::default_layouts` | `context` (string) | Class signal emitted once at startup. Connect to register layouts via `awful.layout.append_default_layouts`. |
| `property::selected` | `t` | Tag was selected or deselected. |
| `property::activated` | `t` | Tag was added to or removed from a screen. |
| `tagged` | `t, c` | Client added to tag. |
| `untagged` | `t, c` | Client removed from tag. |

## `ruled.client` signals

Module-level signals on `ruled.client`. Connect with `ruled.client.connect_signal(...)`.

| Signal | Args | Notes |
|--------|------|-------|
| `request::rules` | none | Fires once on `client.scanning`, after all modules are loaded but before any client is managed. Register rules with `ruled.client.append_rule()`. |

## `ruled.notification` signals

Module-level signals on `ruled.notification`.

| Signal | Args | Notes |
|--------|------|-------|
| `request::rules` | none | Emitted during the `awesome` `startup` signal. Register rules with `ruled.notification.append_rule()`. |

## `naughty` signals

| Signal | Args | Notes |
|--------|------|-------|
| `added` | `n` | A notification was created. |
| `destroyed` | `n, reason` | A notification was destroyed. `reason` matches `naughty.notification_closed_reason.*`. |
| `request::display` | `n` | Naughty wants this notification rendered. Connect a handler that builds a notification widget. See [Notifications](/docs/1.4/guides/notifications). |
| `request::action_icon` | `a` | An action wants its icon resolved. |

See the [naughty reference](/docs/1.4/reference/naughty/) for the full set.

## Layer surface signals <SomewmOnly />

| Signal | Args | Notes |
|--------|------|-------|
| `request::manage` | `l, context, hints` | A layer-shell surface appeared. |
| `request::unmanage` | `l, context, hints` | A layer-shell surface is closing. |
| `request::keyboard` | `l, context, hints` | Layer surface wants keyboard interactivity. |
| `property::has_keyboard_focus` | `l` | Keyboard focus on the layer surface changed. |

See [layer_surface reference](/docs/1.4/reference/layer_surface/) for context.

## Lock signals <SomewmOnly />

| Signal | Args | Notes |
|--------|------|-------|
| `lock::activate` | `source` (string) | Lua session locked. `source` is `"user"`. |
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

See [Lock, Idle, and DPMS reference](/docs/1.4/reference/lock).

## `awesome` signals

Global signals on `awesome.*`. Connect with `awesome.connect_signal(...)`.

| Signal | Args | Notes |
|--------|------|-------|
| `startup` | none | SomeWM finished starting. Fires after `client.scanned`. Safe to assume all default handlers are connected. |
| `exit` | `restart` (boolean) | Lua state is closing. `restart` is `true` for a configuration reload in the existing compositor. |
| `refresh` | none | About to redraw. Avoid expensive work in this handler. It fires often. |
| `debug::error` | `msg` | An uncaught Lua error occurred. Default handler logs to stderr. |
| `debug::deprecation` | `msg, args` | A deprecated API was called. |

## Example usage

Retain the function to disconnect it later:

```lua
local function report_focus(c)
    print("Focused:", c.name)
end

client.connect_signal("focus", report_focus)

-- Stop reporting focus changes.
client.disconnect_signal("focus", report_focus)
```

## See also

- [Signals (concepts)](../concepts/signals.md): what signals are, where they come from, and how `request::*` plus default handlers work
- [Client Stacking](/docs/1.4/concepts/client-stack)
- [Tag Persistence](/docs/1.4/reference/tag-persistence)
- [AwesomeWM signals on `gears.object`](https://awesomewm.org/doc/api/libraries/gears.object.html): the connect/emit/disconnect machinery
