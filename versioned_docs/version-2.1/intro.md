---
sidebar_position: 1
title: Documentation
description: SomeWM is a wlroots compositor that runs AwesomeWM's Lua API on Wayland. SomeWM 2.1 is the newest release.
---

# SomeWM Documentation

SomeWM runs AwesomeWM’s Lua configuration model on Wayland, using [wlroots](https://gitlab.freedesktop.org/wlroots/wlroots). The [compatibility reference](reference/deviations.md) lists differences from AwesomeWM.

## Start here

| Page | For |
| --- | --- |
| [Installation](getting-started/installation.md) | build and install |
| [Launch](getting-started/first-launch.md) | first session, config location, the five keys |
| [Migrating from AwesomeWM](getting-started/migrating.md) | an existing `rc.lua` |
| [Upgrading from 2.0 to 2.1](getting-started/upgrading-from-2.0.md) | a 2.0 config |
| [Try SomeWM without logging out](tutorials/try-somewm-without-installing.md) | a nested instance in a window |

## Tutorials

[Basics](tutorials/basics.md), [Keybindings](tutorials/keybindings.md), [Widgets](tutorials/widgets.md), [Wibar](tutorials/wibar.md), [Theme](tutorials/theme.md), [Carousel](tutorials/carousel.md). Each stands alone.

## Guides

Use the sidebar to find guides for specific tasks, such as configuring input devices, client rules, or multiple monitors.

## Reference

| Page | Covers |
| --- | --- |
| [Lua Libraries](reference/lua-libraries.md) | every library, with upstream links |
| [awful](reference/awful/index.md), [wibox](reference/wibox/index.md), [beautiful](reference/beautiful/index.md), [naughty](reference/naughty/index.md), [gears](reference/gears/index.md) | the libraries |
| [somewm-client](reference/somewm-client.md) | the IPC command line |
| [Key Names](reference/key-names.md) | keys and modifiers |
| [Compatibility reference](reference/deviations.md) | platform differences and compatibility limits |

## Concepts

- [How SomeWM draws](concepts/how-somewm-draws.md): layout and rendering
- [Reading the tree](concepts/reading-the-tree.md): inspect layout results
- [The Object Model](concepts/object-model.md), [Architecture](concepts/architecture.md), and [Signals](concepts/signals.md): objects and configuration
- [Why SomeWM](concepts/why-somewm.md), [AwesomeWM Compatibility](concepts/awesomewm-compat.md), and [Wayland vs X11](concepts/wayland-vs-x11.md): design and compatibility

## Versions

2.1 is the newest release. The version switcher has 2.2 in development, 2.0, and 1.4, which mirrors AwesomeWM master and is maintained indefinitely. The [AwesomeWM apidoc](https://awesomewm.org/apidoc/) covers inherited APIs not yet documented here.
