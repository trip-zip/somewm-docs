---
sidebar_position: 1
title: Documentation
description: SomeWM documentation index - tutorials, guides, reference, and concepts
---

# SomeWM Documentation

A Wayland compositor that brings AwesomeWM's Lua API to Wayland, built on [wlroots](https://gitlab.freedesktop.org/wlroots/wlroots). These docs cover everything from getting started to the full API reference.

## What These Docs Aim to Be

SomeWM's documentation aims to be **self-sufficient**: a complete reference for SomeWM users, organized so you can find what you need without leaving.

- **Comprehensive.** Every API surface AwesomeWM documents is, or will be, documented here.
- **Organized by task.** We use the [Diátaxis framework](https://diataxis.fr/): tutorials (learning), how-to guides (doing), reference (looking up), and concepts (understanding), each kept separate. AwesomeWM's docs are LDoc-generated and do not draw these distinctions.
- **Honest about Wayland.** Architectural differences from AwesomeWM, stubs, and SomeWM-only extensions are inline on the affected pages and indexed in [Deviations](reference/deviations.md).

We are not self-sufficient on every topic yet. If you hit a gap, file a [discussion](https://github.com/trip-zip/somewm/discussions) and we will prioritize it. See [#532](https://github.com/trip-zip/somewm/discussions/532) for the conversation that started this work.

## How to Use These Docs

This documentation attempts to follow the [Diátaxis framework](https://diataxis.fr/), organizing content into four distinct types:

| Type | Purpose | When to use |
|------|---------|-------------|
| **Tutorials** | Learning through doing | You're new and want to learn step-by-step |
| **How-To Guides** | Solving specific problems | You need to accomplish a particular task |
| **Reference** | Technical specifications | You need exact details about an API or feature |
| **Concepts** | Understanding the "why" | You want deeper knowledge of how things work |

Each section serves a different need. Pick the one that matches what you're trying to do.

## Getting Started

| Module | Description |
|--------|-------------|
| [Installation](getting-started/installation.md) | Build and install SomeWM |
| [First Launch](getting-started/first-launch.md) | Run SomeWM for the first time |
| [Migrating](getting-started/migrating.md) | Coming from AwesomeWM? Start here |

## Tutorials

Step-by-step lessons. The first five are short and standalone: read any one on its own to retrofit a single feature into a config you already have.

| Module | Description |
|--------|-------------|
| [Basics](tutorials/basics.md) | Core concepts and configuration |
| [Keybindings](tutorials/keybindings.md) | Set up keyboard shortcuts |
| [Widgets](tutorials/widgets.md) | Build custom widgets |
| [Wibar](tutorials/wibar.md) | Configure the status bar |
| [Theme](tutorials/theme.md) | Customize colors and appearance |

## How-To Guides

Practical recipes for specific tasks.

| Module | Description |
|--------|-------------|
| [Input Devices](guides/input-devices.md) | Configure touchpad, mouse, and keyboard settings |
| [CLI Control](guides/cli-control.md) | Control SomeWM from external scripts |
| [Multi-Monitor](guides/multi-monitor.md) | Set up multiple displays |
| [Autostart](guides/autostart.md) | Launch applications on startup |
| [Notifications](guides/notifications.md) | Configure the notification system |
| [Screenshots](guides/screenshots.md) | Capture screen content |
| [Fractional Scaling](guides/fractional-scaling.md) | HiDPI and fractional display scaling |

## Reference

Technical specifications and API details. Organized by Lua library, with links to upstream AwesomeWM docs.

| Module | Description |
|--------|-------------|
| [Lua Libraries](reference/lua-libraries.md) | Overview of all libraries with upstream links |
| [awful](reference/awful/index.md) | Window management, keybindings, layouts |
| [beautiful](reference/beautiful/index.md) | Theming and theme variables |
| [wibox](reference/wibox/index.md) | Widgets and the wibar |
| [naughty](reference/naughty/index.md) | Notifications |
| [gears](reference/gears/index.md) | Utilities (timers, shapes, colors) |
| [Key Names](reference/key-names.md) | Modifier keys and key name reference |
| [somewm-client](reference/somewm-client.md) | IPC CLI tool (SomeWM-only) |

## Concepts

Background knowledge and architectural understanding.

| Module | Description |
|--------|-------------|
| [Why SomeWM](concepts/why-somewm.md) | What this project commits to and what is open |
| [Architecture](concepts/architecture.md) | How SomeWM is structured |
| [Object Model](concepts/object-model.md) | Understanding the Lua object system |
| [Wayland vs X11](concepts/wayland-vs-x11.md) | Key differences from X11 |
| [AwesomeWM Compatibility](concepts/awesomewm-compat.md) | What works and what differs |

## Versioning

The default docs match SomeWM 1.4, the current stable release, which tracks the AwesomeWM master branch. Use the version switcher in the navigation bar to view the 2.0 (dev) docs — SomeWM 2.0 is a Wayland-native rework that is not yet released.

The [AwesomeWM apidoc](https://awesomewm.org/apidoc/) remains a useful upstream reference for topics that are not yet self-sufficient here.
