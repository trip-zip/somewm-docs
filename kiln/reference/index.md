---
title: Reference
description: The complete kiln API surface, page by page, objects, modules, and the system underneath.
sidebar_position: 1
---

import ModuleTable from '@site/src/components/ModuleTable';

# Reference

This section documents every symbol a kiln config can touch: the objects the compositor hands you, the `some` stdlib modules, and the system layer under both. Each page opens with a short example, then tables: properties as name, type, default, description; methods with their signatures inline; signals with payload and when they fire.

Two conventions run through everything. A config loads the stdlib once:

```lua
local some = require("somewm")
```

and the classes `client`, `screen`, `tag`, `layer`, `drag`, `notification`, and `core` are globals, available without requiring anything.

## Objects

The live things the compositor manages. Properties are read at declare time, so setting one takes effect on the next frame.

<ModuleTable modules={[
  { name: 'client', description: 'A window: geometry, tags, focus, floating, fullscreen, its methods and signals.', link: '/kiln/reference/client' },
  { name: 'tag', description: 'A workspace: selection, its client list, layout, and layout parameters.', link: '/kiln/reference/tag' },
  { name: 'screen', description: 'An output: geometry, workarea, tags, bars, and the DPI facts.', link: '/kiln/reference/screen' },
  { name: 'layer', description: 'A layer-shell surface: panels, launchers, and lockers from other programs.', link: '/kiln/reference/layer' },
  { name: 'notification', description: 'A desktop notification: urgency, actions, timeout, and its lifecycle.', link: '/kiln/reference/notification' },
]} />

## Modules

The `some` stdlib: everything a config composes with.

<ModuleTable modules={[
  { name: 'some', description: 'The top-level module: spawn, rules, key, button, and what it re-exports.', link: '/kiln/reference/some' },
  { name: 'some.ui', description: 'The declarative UI layer: every constructor, the cfg contract, floats, bands, and menus.', link: '/kiln/reference/ui' },
  { name: 'some.layout', description: 'The layout contract, the nine built-in families, and the tag properties they read.', link: '/kiln/reference/layout' },
  { name: 'Keys, Buttons, and Rules', description: 'Binding keys and pointer buttons, and matching clients with rules.', link: '/kiln/reference/keybindings-and-rules' },
  { name: 'some.defaults', description: 'The replaceable default policies the runtime installs.', link: '/kiln/reference/defaults' },
  { name: 'some.placement', description: 'Placement helpers for floating clients.', link: '/kiln/reference/placement' },
  { name: 'Theme Variables', description: 'Every some.theme key with its default, plus some.modkey.', link: '/kiln/reference/theme-variables' },
]} />

## System

The layer under the stdlib. Everyday configs rarely need these pages; scripting, debugging, and extension work does.

<ModuleTable modules={[
  { name: 'Signal Index', description: 'Every signal on every class, in one table.', link: '/kiln/reference/signals' },
  { name: 'core', description: 'The raw C boundary the stdlib is built on: declare primitives, timers, input.', link: '/kiln/reference/core' },
  { name: 'Origin Events', description: 'The compositor events that drive the runtime, and what each carries.', link: '/kiln/reference/events' },
  { name: 'Environment and IPC', description: 'Environment variables, the IPC socket, and evaluating Lua from outside.', link: '/kiln/reference/environment-and-ipc' },
]} />

## See also

- [Anatomy of a config](/kiln/getting-started/rc-anatomy)
- [The object model](/kiln/concepts/object-model)
- [Limitations](/kiln/concepts/limitations)
