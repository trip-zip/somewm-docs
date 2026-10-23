---
sidebar_position: 1
title: Architecture
description: How the C compositor, Lua libraries and user configuration work together in SomeWM 1.4.
---

# Architecture

SomeWM 1.4 runs Lua configuration inside a C compositor. The C core handles Wayland, input and rendering. Lua libraries provide window management and widgets, and `rc.lua` configures their behaviour.

## The Three Layers

<span id="c-core-primitives" />
<span id="lua-libraries-default-behavior" />
<span id="user-configuration" />

| Layer | Responsibility | Where to change behaviour |
| --- | --- | --- |
| C core | Wayland protocols, wlroots scene, input routing and bindings for objects such as `client`, `screen` and `output` | Compositor source |
| Lua libraries | Layouts, widgets, rules, notifications and utility functions | Configure the installed modules through their APIs |
| User configuration | Tags, keybindings, rules, themes and widget composition | `rc.lua` and modules it imports |

The main libraries are `awful` for window management, `wibox` for widgets, `gears` for utilities, `beautiful` for themes, `naughty` for notifications and `ruled` for rules. Installed library files are overwritten on update, so keep customisations in your configuration directory.

## How Layers Communicate

<span id="signals" />
<span id="properties" />
<span id="methods" />

Objects expose properties, methods and signals. Some are implemented in C and others in Lua. For example, `c.floating` is managed by the Lua client library, while the C core applies geometry changes.

| Interface | Example | Effect |
| --- | --- | --- |
| Property | `c.floating = true` | Exclude the client from ordinary tiling |
| Method | `c:geometry { x = 100, y = 100, width = 800, height = 600 }` | Request a position and size |
| Signal | `client.connect_signal("focus", handler)` | Run a handler when a client gains focus |

In 1.4, signal handlers run synchronously during emission. A handler can trigger another signal before the first has returned. See [Signals](signals.md).

### Widget drawing

Widgets in 1.4 measure with `fit`, place children with `layout` and paint with `draw`. The wibox hierarchy combines their output into Cairo drawable surfaces. SomeWM places these surfaces alongside application buffers in the wlroots scene.

Application clients render their own content. Widget rendering is handled by the compositor's Lua and Cairo code. The [scene graph](scene-graph.md) determines which surfaces appear above others.

## Startup Order

The C core creates the Lua state and starts the backend, which discovers outputs. It then loads `rc.lua`. Libraries loaded by the config register handlers, and screen decoration can run as those handlers are connected.

After the config returns, SomeWM emits `screen`'s `scanned`, `client`'s `scanning` and `scanned`, and the global `startup` signal. Normal event processing follows. A Lua reload rebuilds configuration in the existing compositor while applications remain connected.

Initialise the theme before constructing widgets or connecting handlers that create them. Do not assume that every callback waits until the end of `rc.lua`.

## Where Things Live

| Change | Configuration API |
| --- | --- |
| Keybindings | `awful.keyboard.append_global_keybindings` |
| Colours and fonts | `beautiful` variables, usually in `theme.lua` |
| Available layouts | `awful.layout.append_default_layouts` |
| Window rules | `ruled.client.append_rule` |
| Tags | `awful.tag` |
| Panels | `awful.wibar` in a screen decoration handler |
| Notifications | `ruled.notification` and `naughty` |
| Keyboard and pointer settings | `awful.input` |

[Anatomy of rc.lua](rc-lua-anatomy.md) maps these APIs to the default configuration.

## Example: Tracing a Keybind

For the terminal shortcut, the compositor receives a key event and matches a registered binding. Its Lua callback calls `awful.spawn`. When the application maps a window, client rules and management handlers configure it.

## See Also

- [Object Model](object-model.md)
- [AwesomeWM Compatibility](awesomewm-compat.md)
- [Basics](../tutorials/basics.md)
