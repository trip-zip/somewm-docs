---
sidebar_position: 1
title: Documentation
description: SomeWM is a wlroots compositor that runs AwesomeWM's Lua API on Wayland. SomeWM 2.1 is the newest release.
---

# SomeWM Documentation

SomeWM is a Wayland compositor configured in Lua. You can build your own bars, widgets, popups and window layouts. In 2.1, widgets describe their content and sizing rules. SomeWM calculates placement and draws them. Your Lua code controls their data and behaviour.

## Start here

| Starting point | Read next |
| --- | --- |
| I want to try SomeWM | [Run it in a window without logging out](tutorials/try-somewm-without-installing.md), or [install](getting-started/installation.md) and [launch](getting-started/first-launch.md) it. |
| I have a running session and want to build something | [Build a clock widget](tutorials/widgets.md). Create a Lua module, see it on screen, add interaction, then put it in your bar. |
| I have a SomeWM 2.0 configuration | [Upgrade to 2.1](getting-started/upgrading-from-2.0.md), including how to port custom widgets. |
| I have an AwesomeWM configuration | [Migrate from AwesomeWM](getting-started/migrating.md) and check the [widget changes](getting-started/upgrading-from-2.0.md#port-a-custom-widget). |

## Build your desktop {#tutorials}

Start with [configuration basics](tutorials/basics.md) if you have not edited `rc.lua` before. Then follow the widget path:

1. [Build a clock widget](tutorials/widgets.md): a complete example you can see and interact with.
2. [Build a wibar](tutorials/wibar.md): place widgets alongside tags, tasks and the system tray.
3. [Create a custom widget](guides/custom-widgets.md): add your own methods and state, write a Clay description, or display custom Cairo artwork.

[Keybindings](tutorials/keybindings.md), [Theme](tutorials/theme.md) and [Carousel](tutorials/carousel.md) cover other parts of the desktop. You do not need to read the renderer documentation before building widgets.

## Solve a specific task {#guides}

[Update widgets from timers and commands](guides/widget-timers.md), [animate them](guides/animation.md), or [write a client layout](guides/custom-layouts.md). The How-To Guides section in the sidebar lists configuration tasks such as input devices, notifications and multiple monitors.

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
