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

## Getting Started

<ModuleTable modules={[
  { name: 'Installation', description: 'Build and install SomeWM', link: '/getting-started/installation' },
  { name: 'First Launch', description: 'Run SomeWM for the first time', link: '/getting-started/first-launch' },
  { name: 'Migrating', description: 'Coming from AwesomeWM? Start here', link: '/getting-started/migrating' },
]} />

## Tutorials

<ModuleTable modules={[
  { name: 'Basics', description: 'Core concepts and configuration', link: '/tutorials/basics' },
  { name: 'Keybindings', description: 'Set up keyboard shortcuts', link: '/tutorials/keybindings' },
  { name: 'Widgets', description: 'Build custom widgets', link: '/tutorials/widgets' },
  { name: 'Wibar', description: 'Configure the status bar', link: '/tutorials/wibar' },
  { name: 'Theme', description: 'Customize colors and appearance', link: '/tutorials/theme' },
]} />

## SomeWM-Only Features

These features are unique to SomeWM (not available in AwesomeWM):

<ModuleTable modules={[
  { name: 'awful.input', description: 'Runtime input device configuration (tap-to-click, pointer speed, etc.)', link: '/reference/awful-input' },
  { name: 'somewm-client', description: 'IPC CLI tool for external control (~45 commands)', link: '/reference/somewm-client' },
]} />

## Reference

<ModuleTable modules={[
  { name: 'Default Keybindings', description: 'Built-in keyboard shortcuts', link: '/reference/default-keybindings' },
  { name: 'Signals', description: 'Available signals for event handling', link: '/reference/signals' },
  { name: 'AwesomeWM APIs', description: 'Links to upstream API documentation', link: '/reference/awesomewm-apis' },
]} />

## Concepts

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
