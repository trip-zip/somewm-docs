---
title: Reference
description: The complete kiln API surface, page by page, objects, modules, and the system underneath.
sidebar_position: 1
---

# Reference

This section documents every symbol a kiln config can touch: the objects the compositor hands you, the `kiln` stdlib modules, and the system layer under both. Each page opens with a short example, then tables: properties as name, type, default, description; methods with their signatures inline; signals with payload and when they fire.

Two conventions run through everything. A config loads the stdlib once:

```lua
local kiln = require("kiln")
```

and the classes `client`, `screen`, `tag`, `layer`, `drag`, `notification`, and `core` are globals, available without requiring anything.

## Objects

The live things the compositor manages. Properties are read at declare time, so setting one takes effect on the next frame.

| Module | Description |
|--------|-------------|
| [client](client.md) | A window: geometry, tags, focus, floating, fullscreen, its methods and signals. |
| [tag](tag.md) | A workspace: selection, its client list, layout, and layout parameters. |
| [screen](screen.md) | An output: geometry, workarea, tags, bars, and the DPI facts. |
| [layer](layer.md) | A layer-shell surface: panels, launchers, and lockers from other programs. |
| [notification](notification.md) | A desktop notification: urgency, actions, timeout, and its lifecycle. |

## Modules

The `kiln` stdlib: everything a config composes with.

| Module | Description |
|--------|-------------|
| [kiln](kiln.md) | The top-level module: spawn, rules, key, button, and what it re-exports. |
| [kiln.ui](ui.md) | The declarative UI layer: every constructor, the cfg contract, floats, bands, and menus. Maps cfg onto Clay, adds no policy. |
| [kiln.widgets](widgets.md) | The stock widgets: taglist, tasklist, clock, titlebar and their kin. Policy a config could have written in `ui.*`, written once. |
| [kiln.layout](layout.md) | The layout contract, the nine built-in families, and the tag properties they read. |
| [Keys, Buttons, and Rules](keybindings-and-rules.md) | Binding keys and pointer buttons, and matching clients with rules. |
| [kiln.defaults](defaults.md) | The replaceable default policies the runtime installs. |
| [kiln.placement](placement.md) | Placement helpers for floating clients. |
| [kiln.menu](menu.md) | Popup menus: the show cfg, item schema, keyboard navigation, and the client list. |
| [Theme Variables](theme-variables.md) | Every kiln.theme key with its default, plus kiln.modkey. |

## System

The layer under the stdlib. Everyday configs rarely need these pages; scripting, debugging, and extension work does.

| Module | Description |
|--------|-------------|
| [Signal Index](signals.md) | Every signal on every class, in one table. |
| [core](core.md) | The raw C boundary the stdlib is built on: declare primitives, timers, input. |
| [Origin Events](events.md) | The compositor events that drive the runtime, and what each carries. |
| [Environment and IPC](environment-and-ipc.md) | Environment variables, the IPC socket, and evaluating Lua from outside. |
| [kiln-client](kiln-client.md) | The command-line client: every verb, selectors, reflection, JSON output. |

## See also

- [Anatomy of a config](/kiln/getting-started/rc-anatomy)
- [The object model](/kiln/concepts/object-model)
- [Limitations](/kiln/concepts/limitations)
