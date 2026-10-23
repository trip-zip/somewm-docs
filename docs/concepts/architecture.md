---
sidebar_position: 1
title: Architecture
description: How the C core, Lua libraries, configuration and Clay layout work together.
---

# Architecture

C handles Wayland protocols and core objects. Lua configures their behaviour. Clay calculates layout, and SomeWM's renderer updates the scene that wlroots displays.

## Who owns the work

<span id="how-the-layers-meet" />
<span id="from-state-changes-to-a-displayed-frame" />
<span id="startup" />
<span id="where-things-live" />

| Part | Responsibility |
| --- | --- |
| C core | Protocols, input, outputs and Lua bindings for `client`, `screen`, `tag`, `output`, `awesome` and `root` |
| Lua libraries | Window policy, widgets, rules, themes, signals and layout descriptions |
| Your `rc.lua` and modules | Choose layouts, compose widgets, register bindings and configure rules |
| Clay | Calculate sizes and positions from the declarations |
| Renderer and wlroots | Update scene nodes and present application surfaces and desktop content |

SomeWM's Lua libraries originated in AwesomeWM but have changed in 2.x. Updates replace the installed libraries. Keep customisations in your configuration rather than editing installed files.

| Library | Purpose |
| --- | --- |
| `awful` | Window management, bindings, layouts and spawning |
| `gears` | Timers, shapes, filesystem and table helpers |
| `wibox` | Widgets, containers and widget layouts |
| `beautiful` | Theme values |
| `naughty` | Notifications |
| `ruled` | Rules for clients, notifications and layer surfaces |

## How the parts interact

Lua reads properties, calls methods and connects signal handlers. For example, `c.floating = true` changes client state, `c:move_to_tag(t)` changes tag membership, and a `focus` handler reacts to a focus event. Client geometry is a method, `c:geometry()`, rather than a writable table property.

Selected C notifications wait until the current operation finishes. The main loop delivers them before `refresh` and layout. Lua-emitted signals and requests needing an immediate response run inline. See [signal timing](signals.md#dispatch).

## From state to a displayed frame

A state change marks affected outputs for an update. Lua prepares widget and client descriptions. C assembles the output tree, Clay calculates geometry, and the renderer applies the resulting commands to the wlroots scene.

![Lua declarations feed Clay layout, then SomeWM updates the scene before presentation.](/img/architecture/clay-frame-pipeline.svg)

Applications supply their own pixels. SomeWM places those surfaces alongside widget content, borders and decorations. [How SomeWM draws](how-somewm-draws.md) explains the layout and rendering stages.

## Startup and reload

`rc.lua` runs before existing clients are managed. It loads the theme and registers handlers. Screen-decoration handlers create tags and bars. Client scanning then requests rules and bindings, manages existing clients, and ends with the `startup` signal. See [startup order](signals.md#startup-order).

`awesome.restart()` rebuilds the Lua state in the same compositor process and runs the configuration again. Application connections survive, but Lua objects, timers and module state are recreated. See [debugging and reload](../guides/debugging.md).

[The object model](object-model.md) explains which objects a configuration acts on.
