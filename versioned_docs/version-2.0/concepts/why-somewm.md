---
sidebar_position: 1
title: Why somewm
description: A Wayland desktop configured and extended with Lua widgets, layouts and rules.
---

# Why somewm

## What somewm is

SomeWM combines a Wayland compositor with AwesomeWM's Lua configuration model. You build the desktop from widgets, layouts, tags, rules and signal handlers in your own configuration.

The widget system supports panels, launchers, popups, titlebars and notifications. Compose existing widgets or write custom widgets with their own measurement, layout and Cairo drawing. SomeWM 2.0 supports both approaches.

## API direction {#the-prime-directive}

SomeWM 2.x develops its API independently of AwesomeWM. The 1.4 line remains focused on AwesomeWM compatibility. Both use libraries such as `awful`, `wibox`, `gears`, `beautiful`, `naughty` and `ruled`.

In 2.0, deprecated APIs such as `naughty.notify` and the bare `manage` and `unmanage` signals are removed. Some compositor-generated signals also change delivery timing. The [upgrade guide](../getting-started/upgrading-from-1.4.md) lists the affected calls and handlers.

## Using the API {#what-this-commits-to}

Use the documentation for your installed release. Linked AwesomeWM references explain inherited APIs but can also describe behaviour SomeWM has changed or removed.

## What's open

Internal helpers, scene layers and library implementation details can change between releases. Build extensions using documented APIs rather than depending on private fields or internal signals.

## Why deviate at all

Keeping every deprecated API means maintaining several interfaces for the same operation. SomeWM 2.0 removes those alternatives so configuration authors have fewer names and compatibility behaviours to account for, and the libraries have less compatibility code to maintain.

Signal timing is another deliberate change. Queuing focus and geometry notifications lets the compositor finish an operation before Lua handlers react. This reduces cases where a handler changes objects while the operation is still using them.

These changes require migration work for existing configurations. The [upgrade guide](../getting-started/upgrading-from-1.4.md) lists the affected APIs and replacements. [Wayland vs X11](wayland-vs-x11.md) covers differences required by the platform.

## See also

- [Widget tutorial](../tutorials/widgets.md)
- [Compatibility reference](../reference/deviations.md)
- [Migrating from AwesomeWM](../getting-started/migrating.md)
