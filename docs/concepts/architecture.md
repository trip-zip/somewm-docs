---
sidebar_position: 1
title: Architecture
description: Understanding SomeWM's three-layer design
---

# Architecture

<!-- TODO: Write architecture explanation
     - Three-layer design (C core, Lua libraries, user config)
     - What lives where
     - How layers communicate
     - wlroots scene graph
-->

SomeWM uses a three-layer architecture inherited from AwesomeWM.

## The Three Layers

```
┌─────────────────────────────────────┐
│         User Configuration          │  rc.lua, theme.lua
│         (Customization)             │
├─────────────────────────────────────┤
│         Lua Libraries               │  awful.*, gears.*, wibox.*
│         (Default Behavior)          │
├─────────────────────────────────────┤
│         C Core                      │  Compositor, wlroots
│         (Primitives)                │
└─────────────────────────────────────┘
```

## C Core (Primitives)

<!-- TODO: Explain what C provides -->

- Window management primitives
- Input handling
- wlroots integration
- Wayland protocol implementation

## Lua Libraries (Defaults)

<!-- TODO: Explain awful.*, gears.*, wibox.* -->

- Copied from AwesomeWM
- Provide sensible defaults
- Should not be modified

## User Configuration

<!-- TODO: Explain rc.lua role -->

- Your `rc.lua`
- Customizes behavior
- Uses Lua libraries

## How They Communicate

<!-- TODO: Explain signals, properties, methods -->

## See Also

- [AwesomeWM Architecture](https://awesomewm.org/doc/api/) - Original design
