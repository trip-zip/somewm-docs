---
title: Reference
description: Kiln objects, libraries and system APIs.
sidebar_position: 1
---

# Reference

A config loads the stdlib once:

```lua
local kiln = require("kiln")
```

`client`, `screen`, `tag`, `layer`, `drag`, `notification` and `core` are globals.

## Objects

Declarations read object properties each frame. See [Frames and Dirty State](/kiln/concepts/frames-and-dirty) for which writes schedule one.

| Module | Description |
|--------|-------------|
| [client](client.md) | A window: geometry, tags, focus, floating, fullscreen, its methods and signals. |
| [tag](tag.md) | A workspace: selection, its client list, layout, and layout parameters. |
| [screen](screen.md) | An output: geometry, workarea, tags, bars, and the DPI facts. |
| [layer](layer.md) | A layer-shell surface: panels, launchers, and lockers from other programs. |
| [notification](notification.md) | A desktop notification: urgency, actions, timeout, and its lifecycle. |

## Libraries {#modules}

| Module | Description |
|--------|-------------|
| [kiln](kiln.md) | The top-level module: spawn, rules, key, button, and what it re-exports. |
| [kiln.ui](ui.md) | Constructors with per-function options and examples. Shared sizing, input, floats and bands. |
| [kiln.widgets](widgets.md) | Form controls, bar cells and client decorations. Options, defaults and callbacks for each function. |
| [kiln.layout](layout.md) | The layout contract, the nine built-in families, and the tag properties they read. |
| [Keys, Buttons, and Rules](keybindings-and-rules.md) | Binding keys and pointer buttons, and matching clients with rules. |
| [kiln.defaults](defaults.md) | The replaceable default policies the runtime installs. |
| [kiln.placement](placement.md) | Placement helpers for floating clients. |
| [kiln.menu](menu.md) | Popup menus: the show cfg, item schema, keyboard navigation, and the client list. |
| [Theme Variables](theme-variables.md) | Every kiln.theme key with its default, plus kiln.modkey. |

## System

Native APIs, signals and commands for scripting and debugging.

| Module | Description |
|--------|-------------|
| [Signal Index](signals.md) | Every signal on every class, in one table. |
| [core](core.md) | The raw native boundary the stdlib is built on: declare primitives, timers, input. |
| [Origin Events](events.md) | The compositor events that drive the runtime, and what each carries. |
| [Environment and IPC](environment-and-ipc.md) | Environment variables, the IPC socket, and evaluating Lua from outside. |
| [kiln-client](kiln-client.md) | The command-line client: every verb, selectors, reflection, JSON output. |

## See also

- [Anatomy of a config](/kiln/getting-started/rc-anatomy)
- [The object model](/kiln/concepts/object-model)
- [Limitations](/kiln/concepts/limitations)
