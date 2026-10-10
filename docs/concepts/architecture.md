---
sidebar_position: 1
title: Architecture
description: "Three layers, as in AwesomeWM: a C core that owns Wayland, wlroots and the objects; Lua libraries that supply defaults; your config on top. C and Lua meet at signals, properties and methods, never in one call stack."
---

# Architecture

```
┌─────────────────────────────────────┐
│         User Configuration          │  ~/.config/somewm/rc.lua
│                                     │  ~/.config/somewm/theme.lua
├─────────────────────────────────────┤
│         Lua Libraries               │  awful.*, gears.*, wibox.*
│         (Default Behavior)          │  naughty, beautiful, ruled
├─────────────────────────────────────┤
│         C Core                      │  Compositor, wlroots bindings
│         (Primitives)                │  Wayland protocols
└─────────────────────────────────────┘
```

**The C core** is the compositor: Wayland protocols, wlroots (rendering, input, outputs), the core objects, input routing, and the Lua bindings. It exposes `client`, `screen`, `tag`, `output`, `awesome` and `root` to Lua. You do not modify it.

**The Lua libraries** are AwesomeWM's, installed with SomeWM and overwritten on update, so override them from your config rather than editing them:

| Library | Purpose |
| --- | --- |
| `awful.*` | window management, keybindings, layouts, spawning |
| `gears.*` | timers, shapes, filesystem, tables |
| `wibox.*` | widgets, containers, layouts |
| `beautiful` | theming |
| `naughty` | notifications |
| `ruled` | rules for clients and notifications |

**Your configuration** is `rc.lua` (keybindings, tags, rules, layouts) and `theme.lua` (colours, fonts, sizes), both using the libraries:

```lua
awful.keyboard.append_global_keybindings({
    awful.key({ "Mod4" }, "Return", function() awful.spawn("alacritty") end),
})
```

## How the layers meet

| Mechanism | Direction | Example |
| --- | --- | --- |
| signals | C or a library to your handlers | `client.connect_signal("focus", function(c) c.border_color = "#88c0d0" end)` |
| properties | Lua reads state and writes changes C applies | `c.floating = true`, `c.geometry = { x = 100, y = 100, width = 800, height = 600 }` |
| methods | Lua asks for an action | `c:kill()`, `c:move_to_tag(t)`, `t:view_only()` |

C handles each Wayland event without entering Lua. Signals it emits go on a queue that drains at `some_refresh()` before every event-loop iteration: the handlers run in order, then each output a handler touched [declares its tree once and the renderer draws it](./how-somewm-draws.md), then the loop blocks for the next event. AwesomeWM and SomeWM 1.x ran Lua handlers inside the event handler, several times per event; 2.x never shares a call stack between the layers. [Signals](./signals.md) has what is queued, what stays synchronous, and coalescing.

## Startup

1. The C core initialises: wlroots sets up the outputs, the Lua VM starts, the libraries load.
2. `rc.lua` runs top to bottom, once. `beautiful.init()` early in it loads the theme; `connect_signal` calls register handlers that run later.
3. `request::desktop_decoration` fires per screen: tags and wibars are created in its handler.
4. Existing clients are managed: `request::manage` per client.
5. The event loop runs.

A config reload runs `rc.lua` again in the same process ([Reloading](../guides/debugging.md)).

## Where things live

| To change | Edit | Using |
| --- | --- | --- |
| keybindings | `rc.lua` | `awful.keyboard.append_global_keybindings` |
| colours and fonts | `theme.lua` | `beautiful` variables |
| layouts | `rc.lua` | `awful.layout.layouts` |
| window rules | `rc.lua` | `ruled.client.append_rule` |
| tags | `rc.lua` | `awful.tag()` |
| the bar | `rc.lua` | `awful.wibar {}` inside the screen handler |
| notifications | `rc.lua` | `naughty.config`, `ruled.notification` |
| input devices | `rc.lua` | `awful.input` properties |

[The Object Model](./object-model.md) describes the objects the three layers share.
