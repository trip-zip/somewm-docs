---
sidebar_position: 4
title: AwesomeWM compatibility
description: The compatibility policy for SomeWM 2.0 and how versioned references define supported behaviour.
---

# AwesomeWM compatibility

SomeWM 2.0 develops independently of AwesomeWM. Use this version’s reference for supported arguments, defaults and signal timing.

<span id="version-targets" />

<span id="philosophy" />

## The 1.4 and 2.x lines

The 1.4 line follows AwesomeWM master. Its purpose is to preserve the upstream configuration API on Wayland. Features developed for 2.x are not routinely backported unless needed for that compatibility.

The 2.x line retains Lua widgets, themes, rules and signals while allowing API changes. In 2.0, deprecated APIs are removed and some C-generated signals are queued. Custom widgets still support `fit`, `layout` and Cairo `draw` methods.

<span id="documentation-promise" />

<span id="what-compatibility-means" />

<span id="compatibility-status" />

<span id="behavioral-differences" />

<span id="systray-details" />

<span id="testing-your-config" />

<span id="running-awesomewm-tests" />

<span id="reporting-incompatibilities" />

<span id="see-also" />

## The version defines the contract

The [compatibility reference](../reference/deviations.md) records platform differences and unsupported behaviour for this version. Individual API references describe supported properties, methods and signals. Linked AwesomeWM documentation provides background for inherited APIs.

[Upgrade from 1.4 to 2.0](../getting-started/upgrading-from-1.4.md) describes configuration changes between SomeWM releases. [Migrating from AwesomeWM](../getting-started/migrating.md) covers the move from X11 tools and assumptions to Wayland.

[Wayland vs X11](wayland-vs-x11.md) explains protocol differences. [Architecture](architecture.md) explains the compositor and its Lua libraries.
