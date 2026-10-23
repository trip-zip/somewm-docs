---
sidebar_position: 4
title: AwesomeWM compatibility
description: The compatibility policy for SomeWM 2.1 and how versioned references define supported behaviour.
---

# AwesomeWM compatibility

SomeWM 2.1 develops independently of AwesomeWM. Shared Lua names do not guarantee identical behaviour. The reference for this version defines the supported API.

## The 1.4 and 2.x lines

The 1.4 line follows AwesomeWM master. Its purpose is to preserve the upstream configuration API on Wayland. Features developed for 2.x are not routinely backported. Parity with AwesomeWM is the reason for an exception.

The 2.x line retains the Lua configuration model, but may change arguments, defaults and signal timing.

<span id="stubs" />

<span id="behavioural-differences" />

<span id="testing-and-reporting" />

## The version defines the contract

The [compatibility reference](../reference/deviations.md) records platform differences and unsupported behaviour for this version. Individual API references describe supported properties, methods and signals. Linked AwesomeWM documentation provides background for inherited APIs.

[Upgrade from 2.0 to 2.1](../getting-started/upgrading-from-2.0.md) describes configuration changes between SomeWM releases. [Migrating from AwesomeWM](../getting-started/migrating.md) covers the move from X11 tools and assumptions to Wayland.

[Wayland vs X11](wayland-vs-x11.md) explains protocol differences. [How SomeWM draws](how-somewm-draws.md) explains why clients and widgets share one layout tree.
