---
title: Concepts
description: How SomeWM works and why, for when a guide is not enough.
---

# Concepts

Concept pages explain how a part of SomeWM works and the reasons behind it. None is needed to follow a tutorial or a guide. Read one when you want to know why something behaves the way it does.

## Start here

| Page | Explains |
| --- | --- |
| [Why SomeWM](why-somewm.md) | What SomeWM is for and what it is built from |
| [The object model](object-model.md) | Outputs, screens, tags, clients, wiboxes and widgets, and how they relate |
| [Signals](signals.md) | How events reach Lua and when handlers run |
| [Architecture](architecture.md) | The C core, the Lua libraries, the config and Clay |

## Layout and rendering

In order; each builds on the one before.

| Page | Explains |
| --- | --- |
| [How SomeWM draws](how-somewm-draws.md) | From a property change to pixels |
| [How widgets are laid out](widgets-in-the-tree.md) | What a widget declares, and why an old `draw` widget disappears |
| [Clients and layouts in the same tree](clients-in-the-tree.md) | Window frames and titlebars as part of the layout |
| [Reading the tree](reading-the-tree.md) | Finding which rule gave a widget its size |
| [Scene graph](scene-graph.md) | Drawing order: bands and client stacking |

## Windows and tags

| Page | Explains |
| --- | --- |
| [Client stacking](client-stack.md) | Visual order versus focus and tiling order |
| [Focus history](focus-history.md) | Which window gets focus back |
| [Master and stack](master-and-stack.md) | How tile places clients |
| [Scrollable tiling](scrollable-tiling.md) | How the carousel sizes and scrolls columns |
| [Why tags persist](tag-persistence.md) | What the default config restores after a monitor reconnects |

## Platform

| Page | Explains |
| --- | --- |
| [AwesomeWM compatibility](awesomewm-compat.md) | The policy on keeping an `rc.lua` working |
| [Wayland vs X11](wayland-vs-x11.md) | Display-server differences that reach a config |
| [Display scaling](display-scaling.md) | Output scale, logical geometry and DPI |
| [Session locking](lockscreen.md) | Built-in and external locks, and what happens on failure |
| [Screenshots](screenshots.md) | What a capture contains and in which coordinates |
| [Test mode](test-mode.md) | What nested and headless instances isolate |
