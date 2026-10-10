---
sidebar_position: 1
title: Documentation
description: SomeWM is a wlroots compositor that runs AwesomeWM's Lua API on Wayland. Tutorials, how-to guides, reference and concepts for the 2.1 development version.
---

# SomeWM Documentation

SomeWM is a Wayland compositor built on [wlroots](https://gitlab.freedesktop.org/wlroots/wlroots) that runs AwesomeWM's Lua configuration model. These docs follow [Diátaxis](https://diataxis.fr/): tutorials teach, guides solve one task, reference lists, concepts explain. Where SomeWM differs from AwesomeWM, the affected page says so and [Deviations](reference/deviations.md) indexes it. A gap is a [discussion](https://github.com/trip-zip/somewm/discussions) away from being filled.

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

Input devices, CLI control, multi-monitor, autostart, notifications, screenshots, scaling, shadows, lockscreen, client rules, custom layouts, testing in a nested compositor, and the carousel set. The sidebar lists them all.

## Reference

| Page | Covers |
| --- | --- |
| [Lua Libraries](reference/lua-libraries.md) | every library, with upstream links |
| [awful](reference/awful/index.md), [wibox](reference/wibox/index.md), [beautiful](reference/beautiful/index.md), [naughty](reference/naughty/index.md), [gears](reference/gears/index.md) | the libraries |
| [somewm-client](reference/somewm-client.md) | the IPC command line |
| [Key Names](reference/key-names.md) | keys and modifiers |
| [Deviations](reference/deviations.md) | every difference from AwesomeWM |

## Concepts

[How SomeWM draws](concepts/how-somewm-draws.md) and [Reading the tree](concepts/reading-the-tree.md) are the 2.1 model; [The Object Model](concepts/object-model.md), [Architecture](concepts/architecture.md) and [Signals](concepts/signals.md) the Lua side; [Why SomeWM](concepts/why-somewm.md), [AwesomeWM Compatibility](concepts/awesomewm-compat.md) and [Wayland vs X11](concepts/wayland-vs-x11.md) the relationship to AwesomeWM.

## Versions

These pages track 2.1, in development. The version switcher has 2.0, the current release, and 1.4, which mirrors AwesomeWM master and is maintained indefinitely. The [AwesomeWM apidoc](https://awesomewm.org/apidoc/) covers inherited APIs not yet documented here.
