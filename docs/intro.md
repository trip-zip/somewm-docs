---
sidebar_position: 1
title: Documentation
description: SomeWM documentation index - tutorials, guides, reference, and concepts
---

import ModuleTable from '@site/src/components/ModuleTable';

# SomeWM Documentation

A Wayland compositor that brings AwesomeWM's Lua API to Wayland, built on [wlroots](https://gitlab.freedesktop.org/wlroots/wlroots). These docs cover everything from getting started to the full API reference.

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

<ModuleTable modules={[
  { name: 'Installation', description: 'Build and install SomeWM', link: '/docs/getting-started/installation' },
  { name: 'First Launch', description: 'Run SomeWM for the first time', link: '/docs/getting-started/first-launch' },
  { name: 'Migrating', description: 'Coming from AwesomeWM? Start here', link: '/docs/getting-started/migrating' },
]} />

## Tutorials

Step-by-step lessons to learn SomeWM from scratch.

<ModuleTable modules={[
  { name: 'Basics', description: 'Core concepts and configuration', link: '/docs/tutorials/basics' },
  { name: 'Keybindings', description: 'Set up keyboard shortcuts', link: '/docs/tutorials/keybindings' },
  { name: 'Widgets', description: 'Build custom widgets', link: '/docs/tutorials/widgets' },
  { name: 'Wibar', description: 'Configure the status bar', link: '/docs/tutorials/wibar' },
  { name: 'Theme', description: 'Customize colors and appearance', link: '/docs/tutorials/theme' },
]} />

## How-To Guides

Practical recipes for specific tasks.

<ModuleTable modules={[
  { name: 'Input Devices', description: 'Configure touchpad, mouse, and keyboard settings', link: '/docs/guides/input-devices' },
  { name: 'CLI Control', description: 'Control SomeWM from external scripts', link: '/docs/guides/cli-control' },
  { name: 'Multi-Monitor', description: 'Set up multiple displays', link: '/docs/guides/multi-monitor' },
  { name: 'Autostart', description: 'Launch applications on startup', link: '/docs/guides/autostart' },
  { name: 'Notifications', description: 'Configure the notification system', link: '/docs/guides/notifications' },
  { name: 'Screenshots', description: 'Capture screen content', link: '/docs/guides/screenshots' },
  { name: 'Fractional Scaling', description: 'HiDPI and fractional display scaling', link: '/docs/guides/fractional-scaling' },
]} />

## Reference

Technical specifications and API details. Organized by Lua library, with links to upstream AwesomeWM docs.

<ModuleTable modules={[
  { name: 'Lua Libraries', description: 'Overview of all libraries with upstream links', link: '/docs/reference/lua-libraries' },
  { name: 'awful', description: 'Window management, keybindings, layouts', link: '/docs/reference/awful/' },
  { name: 'beautiful', description: 'Theming and theme variables', link: '/docs/reference/beautiful/' },
  { name: 'wibox', description: 'Widgets and the wibar', link: '/docs/reference/wibox/' },
  { name: 'naughty', description: 'Notifications', link: '/docs/reference/naughty/' },
  { name: 'gears', description: 'Utilities (timers, shapes, colors)', link: '/docs/reference/gears/' },
  { name: 'Key Names', description: 'Modifier keys and key name reference', link: '/docs/reference/key-names' },
  { name: 'somewm-client', description: 'IPC CLI tool (SomeWM-only)', link: '/docs/reference/somewm-client' },
]} />

## Concepts

Background knowledge and architectural understanding.

<ModuleTable modules={[
  { name: 'Why SomeWM', description: 'What this project commits to and what is open', link: '/docs/next/concepts/why-somewm' },
  { name: 'Architecture', description: 'How SomeWM is structured', link: '/docs/concepts/architecture' },
  { name: 'Object Model', description: 'Understanding the Lua object system', link: '/docs/concepts/object-model' },
  { name: 'Wayland vs X11', description: 'Key differences from X11', link: '/docs/concepts/wayland-vs-x11' },
  { name: 'AwesomeWM Compatibility', description: 'What works and what differs', link: '/docs/concepts/awesomewm-compat' },
]} />

## About These Docs

SomeWM targets AwesomeWM git (not the v4.3 stable release). The official [AwesomeWM API documentation](https://awesomewm.org/apidoc/) applies directly to SomeWM and remains the primary reference for the Lua API.

These docs focus on getting started with SomeWM, SomeWM-only features, and Wayland-specific differences.
