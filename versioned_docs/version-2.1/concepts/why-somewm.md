---
sidebar_position: 1
title: Why somewm
description: A Wayland desktop built from Lua widgets, layouts, tags and rules.
---

# Why somewm

<span id="not-part-of-the-api" />
<span id="where-wayland-forces-a-difference" />

SomeWM combines a Wayland compositor with AwesomeWM's Lua configuration model. You build the desktop from widgets, layouts, tags, rules and signal handlers in your own configuration.

The widget system supplies the content of panels, launchers, popups, titlebars and notifications. Custom widgets can combine built-in components with their own state, methods, timers and input handling. For new visual content, they can supply a Clay description or an image surface. Start with [a clock widget](../tutorials/widgets.md), or read [how custom widgets work](widgets-in-the-tree.md).

## Why change the drawing model?

In 2.1, widgets describe their content and sizing rules. Clay calculates their sizes and positions, and SomeWM renders the resulting tree. Giving one layout system responsibility for geometry lets changes propagate through parents and neighbours without each widget implementing measurement and drawing callbacks.

This requires migration work for widgets that used `fit`, `layout` or `draw`. Their state and behaviour can remain, while their visual implementation changes. The [upgrade guide](../getting-started/upgrading-from-2.0.md) identifies affected widgets and links to replacements.

## Compatibility and release lines

The 1.4 line focuses on AwesomeWM compatibility. SomeWM 2.x retains the Lua configuration model but develops its APIs independently. Shared names do not guarantee identical arguments, defaults or signal timing.

Use the documentation for your installed release. Linked AwesomeWM documentation explains inherited APIs but can also describe behaviour SomeWM has changed or removed. See the [compatibility policy](awesomewm-compat.md) and [compatibility reference](../reference/deviations.md).

## What Wayland changes

Some differences come from being the display server. SomeWM manages outputs and input, uses StatusNotifierItem for tray icons, and reloads Lua in the existing process to keep application connections alive.

[Wayland vs X11](wayland-vs-x11.md) explains these platform differences. Internal helpers, scene details and undocumented signals can also change between releases. Use documented interfaces when extending the desktop.
