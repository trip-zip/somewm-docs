---
title: Kiln
description: A Wayland compositor where your entire desktop is one declarative Lua config over a Clay layout tree.
sidebar_position: 1
slug: /
---

# Kiln

kiln is a Wayland compositor where everything on screen is a node in one [Clay](https://github.com/nicbarker/clay) layout tree per screen. Windows, bars, widgets, tags, menus, and notifications are all the same kind of thing: Lua declares the tree, the Clay solver lays it out, and a thin C core renders the result. There is no separate widget toolkit, no imperative drawing loop, no special-cased bar. Your entire desktop is a Lua config over a small, general core.

The source lives at [github.com/trip-zip/kiln](https://github.com/trip-zip/kiln).

kiln shares its desktop concepts with SomeWM and AwesomeWM: clients, tags, layouts, rules, a status bar, a theme table. But its API is deliberately its own, declarative rather than imperative, and there is no compatibility layer. Existing AwesomeWM or SomeWM configs and widget libraries do not run on kiln. See [kiln vs SomeWM](/kiln/concepts/kiln-vs-somewm) for the full comparison.

:::info
kiln is a young project. The API is functional and fully documented here, but it is not yet frozen: names and shapes may still change between releases.
:::

## How these docs are organized

These docs follow the [Diátaxis framework](https://diataxis.fr/), separating four kinds of pages:

| Type | Purpose | When to use |
|------|---------|-------------|
| **Tutorials** | Learning through doing | You're new and want to learn step-by-step |
| **How-To Guides** | Solving specific problems | You need to accomplish a particular task |
| **Reference** | Technical specifications | You need exact details about an API or feature |
| **Concepts** | Understanding the "why" | You want deeper knowledge of how things work |

Pick the section that matches what you are trying to do right now.

## Getting Started

| Module | Description |
|--------|-------------|
| [Installation](getting-started/installation.md) | Build kiln from source and install it |
| [First Launch](getting-started/first-launch.md) | Run kiln nested or on a TTY for the first time |
| [Anatomy of rc.lua](getting-started/rc-anatomy.md) | What the default config does, section by section |

## Tutorials

Step-by-step lessons that build your config from scratch.

| Module | Description |
|--------|-------------|
| [Basics](tutorials/basics.md) | Clients, tags, screens, and the declare loop |
| [Keybindings](tutorials/keybindings.md) | Bind keys and mouse buttons with some.key and some.button |
| [A Bar From Scratch](tutorials/a-bar-from-scratch.md) | Build a status bar out of ui nodes |
| [Widgets](tutorials/widgets.md) | Self-updating regions with ui.widget |
| [Theming](tutorials/theming.md) | Colors, fonts, and sizes through the theme table |

## How-To Guides

Practical recipes for specific tasks. A selection of the most useful ones; the sidebar lists all of them.

| Module | Description |
|--------|-------------|
| [Client Rules](guides/client-rules.md) | Match clients and apply properties on map |
| [Multi-Monitor](guides/multi-monitor.md) | Configure outputs: mode, scale, position |
| [Input Devices](guides/input-devices.md) | Keymap, repeat rate, touchpad, and pointer settings |
| [Notifications](guides/notifications.md) | Receive, style, and replace the notification display |
| [Wallpaper](guides/wallpaper.md) | Put an image behind everything |
| [App Launcher](guides/app-launcher.md) | A .desktop application menu in config space |
| [IPC and Scripting](guides/ipc-and-scripting.md) | Drive the live config VM from the shell |
| [Reload and Debugging](guides/reload-and-debugging.md) | Reload the config in place and inspect state |

## Concepts

Background knowledge and architectural understanding.

| Module | Description |
|--------|-------------|
| [The Clay Thesis](concepts/the-clay-thesis.md) | Why one layout tree owns the whole screen |
| [Frames and Dirty](concepts/frames-and-dirty.md) | When kiln redraws, and when it deliberately does not |
| [Object Model](concepts/object-model.md) | One class mixin behind clients, tags, screens, and the rest |
| [Nodes, Floats, and Bands](concepts/nodes-floats-and-bands.md) | How the tree, out-of-flow elements, and z-order fit together |
| [The C/Lua Boundary](concepts/c-lua-boundary.md) | What the C core does and what it refuses to do |
| [kiln vs SomeWM](concepts/kiln-vs-somewm.md) | Shared concepts, different API, no compat layer |
| [Limitations](concepts/limitations.md) | What kiln deliberately does not do |

## Reference

Exact API details: every property, method, signal, and default.

| Module | Description |
|--------|-------------|
| [Reference Index](reference/index.md) | The full API surface in one place |
| [client](reference/client.md) | The client object: properties, methods, signals |
| [some](reference/some.md) | The some module: keys, rules, spawn, defaults |
| [some.ui](reference/ui.md) | The node constructors and the cfg contract |
| [some.layout](reference/layout.md) | Layout functions and their tag parameters |
| [Theme Variables](reference/theme-variables.md) | Every theme key with its default |

## Where to start

[Install kiln](/kiln/getting-started/installation), then [launch it](/kiln/getting-started/first-launch) nested inside your current session so nothing is at stake. Once it opens, work through the [basics tutorial](/kiln/tutorials/basics): it walks the default config and ends with you changing it live.
