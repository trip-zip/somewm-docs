---
sidebar_position: 3
title: Scene Graph
description: How wlroots renders the desktop
---

# Scene Graph

<!-- TODO: Write scene graph explanation
     - wlroots scene graph basics
     - How SomeWM uses it
     - Layer ordering
     - Why this matters for wibox/drawin
-->

SomeWM uses wlroots' scene graph for rendering.

## What is a Scene Graph?

<!-- TODO: Explain concept -->

A scene graph is a hierarchical data structure that represents all visual elements on screen.

```
root
├── background layer
├── bottom layer
├── tiled windows layer
├── floating windows layer
├── top layer
└── overlay layer
```

## Layers in SomeWM

<!-- TODO: Document layer ordering -->

| Layer | Contents |
|-------|----------|
| Background | Wallpaper |
| Bottom | Background panels |
| Tiled | Regular tiled windows |
| Floating | Floating windows |
| Top | Wibox panels, notifications |
| Overlay | Fullscreen, popups |

## Why This Matters

<!-- TODO: Explain implications -->

- Determines z-ordering
- Affects performance
- Influences how drawins/wiboxes appear

## wlroots Documentation

For more details, see the [wlroots scene graph documentation](https://gitlab.freedesktop.org/wlroots/wlroots/-/blob/master/docs/scene-graph.md).
