---
sidebar_position: 1
title: Architecture
description: Lua supplies configuration and layout declarations. A scheduled C-to-Lua notification queue precedes the Clay layout pass and scene reconciliation.
---

# Architecture

SomeWM separates state changes, layout computation and scene rendering. C owns Wayland objects and protocol handling; Lua supplies configuration and policy. Queued notifications reach Lua at the refresh boundary. Each dirty output then follows a common declaration, Clay solve and scene reconciliation path.

## Who owns the work

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

The C-to-Lua boundary has explicit dispatch rules. Notifications such as geometry, focus and pointer motion are queued. `some_refresh()` drains them before emitting `refresh` and applying pending updates. This lets their handlers run after the emitting C operation returns. Requests whose answers C needs immediately remain synchronous, as do Lua-emitted signals. [Signals](./signals.md#dispatch) explains the boundary.

## From state changes to a displayed frame

The configuration and libraries update objects and mark affected outputs dirty. At an output's frame boundary, Lua compiles pending layout descriptions. C assembles the output tree, Clay computes the sizes and positions, and the renderer reconciles the resulting commands into `wlr_scene`.

![Lua declarations become one output tree, Clay computes layout in C, and SomeWM reconciles the resulting commands into the wlroots scene.](/img/architecture/clay-frame-pipeline.svg)

Client layouts, bars and widget containers contribute to that same tree. Their geometry is computed in the output pass, and the scene is updated from its completed result. An application still supplies its own surface pixels. wlroots presents the scene after reconciliation.

The architectural boundary is between **declaring what belongs on the output**, **computing its layout**, and **applying the solved result to the scene**. A widget property setter marks pending work; it does not paint a widget surface immediately. [How SomeWM draws](./how-somewm-draws.md) follows these stages through the main loop and explains what Clay computes.

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
