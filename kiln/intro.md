---
title: Kiln
description: A Wayland compositor where your entire desktop is one declarative Lua config over a Clay layout tree.
sidebar_position: 1
---

import ModuleTable from '@site/src/components/ModuleTable';

# Kiln

kiln is a Wayland compositor where everything on screen is a node in one [Clay](https://github.com/nicbarker/clay) layout tree per screen. Windows, bars, widgets, tags, menus, and notifications are all the same kind of thing: Lua declares the tree, the Clay solver lays it out, and a thin C core renders the result. There is no separate widget toolkit, no imperative drawing loop, no special-cased bar. Your entire desktop is a Lua config over a small, general core.

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

<ModuleTable modules={[
  { name: 'Installation', description: 'Build kiln from source and install it', link: '/kiln/getting-started/installation' },
  { name: 'First Launch', description: 'Run kiln nested or on a TTY for the first time', link: '/kiln/getting-started/first-launch' },
  { name: 'Anatomy of rc.lua', description: 'What the default config does, section by section', link: '/kiln/getting-started/rc-anatomy' },
]} />

## Tutorials

Step-by-step lessons that build your config from scratch.

<ModuleTable modules={[
  { name: 'Basics', description: 'Clients, tags, screens, and the declare loop', link: '/kiln/tutorials/basics' },
  { name: 'Keybindings', description: 'Bind keys and mouse buttons with some.key and some.button', link: '/kiln/tutorials/keybindings' },
  { name: 'A Bar From Scratch', description: 'Build a status bar out of ui nodes', link: '/kiln/tutorials/a-bar-from-scratch' },
  { name: 'Widgets', description: 'Self-updating regions with ui.widget', link: '/kiln/tutorials/widgets' },
  { name: 'Theming', description: 'Colors, fonts, and sizes through the theme table', link: '/kiln/tutorials/theming' },
]} />

## How-To Guides

Practical recipes for specific tasks. A selection of the most useful ones; the sidebar lists all of them.

<ModuleTable modules={[
  { name: 'Client Rules', description: 'Match clients and apply properties on map', link: '/kiln/guides/client-rules' },
  { name: 'Multi-Monitor', description: 'Configure outputs: mode, scale, position', link: '/kiln/guides/multi-monitor' },
  { name: 'Input Devices', description: 'Keymap, repeat rate, touchpad, and pointer settings', link: '/kiln/guides/input-devices' },
  { name: 'Notifications', description: 'Receive, style, and replace the notification display', link: '/kiln/guides/notifications' },
  { name: 'Wallpaper', description: 'Put an image behind everything', link: '/kiln/guides/wallpaper' },
  { name: 'App Launcher', description: 'A .desktop application menu in config space', link: '/kiln/guides/app-launcher' },
  { name: 'IPC and Scripting', description: 'Drive the live config VM from the shell', link: '/kiln/guides/ipc-and-scripting' },
  { name: 'Reload and Debugging', description: 'Reload the config in place and inspect state', link: '/kiln/guides/reload-and-debugging' },
]} />

## Concepts

Background knowledge and architectural understanding.

<ModuleTable modules={[
  { name: 'The Clay Thesis', description: 'Why one layout tree owns the whole screen', link: '/kiln/concepts/the-clay-thesis' },
  { name: 'Frames and Dirty', description: 'When kiln redraws, and when it deliberately does not', link: '/kiln/concepts/frames-and-dirty' },
  { name: 'Object Model', description: 'One class mixin behind clients, tags, screens, and the rest', link: '/kiln/concepts/object-model' },
  { name: 'Nodes, Floats, and Bands', description: 'How the tree, out-of-flow elements, and z-order fit together', link: '/kiln/concepts/nodes-floats-and-bands' },
  { name: 'The C/Lua Boundary', description: 'What the C core does and what it refuses to do', link: '/kiln/concepts/c-lua-boundary' },
  { name: 'kiln vs SomeWM', description: 'Shared concepts, different API, no compat layer', link: '/kiln/concepts/kiln-vs-somewm' },
  { name: 'Limitations', description: 'What kiln deliberately does not do', link: '/kiln/concepts/limitations' },
]} />

## Reference

Exact API details: every property, method, signal, and default.

<ModuleTable modules={[
  { name: 'Reference Index', description: 'The full API surface in one place', link: '/kiln/reference/' },
  { name: 'client', description: 'The client object: properties, methods, signals', link: '/kiln/reference/client' },
  { name: 'some', description: 'The some module: keys, rules, spawn, defaults', link: '/kiln/reference/some' },
  { name: 'some.ui', description: 'The node constructors and the cfg contract', link: '/kiln/reference/ui' },
  { name: 'some.layout', description: 'Layout functions and their tag parameters', link: '/kiln/reference/layout' },
  { name: 'Theme Variables', description: 'Every theme key with its default', link: '/kiln/reference/theme-variables' },
]} />

## Where to start

[Install kiln](/kiln/getting-started/installation), then [launch it](/kiln/getting-started/first-launch) nested inside your current session so nothing is at stake. Once it opens, work through the [basics tutorial](/kiln/tutorials/basics): it walks the default config and ends with you changing it live.
