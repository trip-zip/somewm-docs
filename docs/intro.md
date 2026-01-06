---
slug: /
sidebar_position: 1
title: SomeWM
description: AwesomeWM on Wayland - 100% Lua API compatibility
---

import ModuleTable from '@site/src/components/ModuleTable';

# SomeWM

A Wayland compositor that brings AwesomeWM's Lua API to Wayland, built on [wlroots](https://gitlab.freedesktop.org/wlroots/wlroots). The goal is 100% compatibility with AwesomeWM's Lua configuration.

---

## How to Use These Docs

This documentation follows the [Diátaxis framework](https://diataxis.fr/), organizing content into four distinct types:

| Type | Purpose | When to use |
|------|---------|-------------|
| **Tutorials** | Learning through doing | You're new and want to learn step-by-step |
| **How-To Guides** | Solving specific problems | You need to accomplish a particular task |
| **Reference** | Technical specifications | You need exact details about an API or feature |
| **Concepts** | Understanding the "why" | You want deeper knowledge of how things work |

Each section serves a different need—pick the one that matches what you're trying to do.

---

## Getting Started

<ModuleTable modules={[
  { name: 'Installation', description: 'Build and install SomeWM', link: '/getting-started/installation' },
  { name: 'First Launch', description: 'Run SomeWM for the first time', link: '/getting-started/first-launch' },
  { name: 'Migrating', description: 'Coming from AwesomeWM? Start here', link: '/getting-started/migrating' },
]} />

## Tutorials

Step-by-step lessons to learn SomeWM from scratch.

<ModuleTable modules={[
  { name: 'Basics', description: 'Core concepts and configuration', link: '/tutorials/basics' },
  { name: 'Keybindings', description: 'Set up keyboard shortcuts', link: '/tutorials/keybindings' },
  { name: 'Widgets', description: 'Build custom widgets', link: '/tutorials/widgets' },
  { name: 'Wibar', description: 'Configure the status bar', link: '/tutorials/wibar' },
  { name: 'Theme', description: 'Customize colors and appearance', link: '/tutorials/theme' },
]} />

## How-To Guides

Practical recipes for specific tasks.

<ModuleTable modules={[
  { name: 'Input Devices', description: 'Configure touchpad, mouse, and keyboard settings', link: '/guides/input-devices' },
  { name: 'CLI Control', description: 'Control SomeWM from external scripts', link: '/guides/cli-control' },
  { name: 'Multi-Monitor', description: 'Set up multiple displays', link: '/guides/multi-monitor' },
  { name: 'Autostart', description: 'Launch applications on startup', link: '/guides/autostart' },
  { name: 'Notifications', description: 'Configure the notification system', link: '/guides/notifications' },
  { name: 'Screenshots', description: 'Capture screen content', link: '/guides/screenshots' },
  { name: 'Fractional Scaling', description: 'HiDPI and fractional display scaling', link: '/guides/fractional-scaling' },
]} />

## Reference

Technical specifications and API details.

<ModuleTable modules={[
  { name: 'awful.input', description: 'Input device configuration API (SomeWM-only)', link: '/reference/awful-input' },
  { name: 'somewm-client', description: 'IPC CLI tool for external control (SomeWM-only)', link: '/reference/somewm-client' },
  { name: 'Default Keybindings', description: 'Built-in keyboard shortcuts', link: '/reference/default-keybindings' },
  { name: 'Signals', description: 'Available signals for event handling', link: '/reference/signals' },
  { name: 'AwesomeWM APIs', description: 'Links to upstream API documentation', link: '/reference/awesomewm-apis' },
]} />

## Concepts

Background knowledge and architectural understanding.

<ModuleTable modules={[
  { name: 'Architecture', description: 'How SomeWM is structured', link: '/concepts/architecture' },
  { name: 'Object Model', description: 'Understanding the Lua object system', link: '/concepts/object-model' },
  { name: 'Wayland vs X11', description: 'Key differences from X11', link: '/concepts/wayland-vs-x11' },
  { name: 'AwesomeWM Compatibility', description: 'What works and what differs', link: '/concepts/awesomewm-compat' },
]} />

---

## About These Docs

SomeWM targets AwesomeWM git (not the v4.3 stable release). The official [AwesomeWM API documentation](https://awesomewm.org/apidoc/) applies directly to SomeWM and remains the primary reference for the Lua API.

These docs focus on getting started with SomeWM, SomeWM-only features, and Wayland-specific differences.
