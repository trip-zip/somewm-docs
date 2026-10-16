---
sidebar_position: 4
title: AwesomeWM compatibility
description: The compatibility policy for SomeWM 1.4 and how versioned references define supported behaviour.
---

# AwesomeWM compatibility

SomeWM 1.4 mirrors AwesomeWM master and is maintained as the upstream-compatible line. Wayland requires differences in protocols and desktop integration.

<span id="version-targets" />

<span id="philosophy" />

## The 1.4 and 2.x lines

The 1.4 line follows AwesomeWM master. Its purpose is to preserve the upstream configuration API on Wayland. Features developed for 2.x are not routinely backported; parity with AwesomeWM is the reason for an exception.

The 2.x line keeps the Lua configuration model while developing its libraries and compositor independently. Existing configurations are preserved where possible, but a shared name is not a promise of identical arguments, defaults or signal timing.

<span id="documentation-promise" />

<span id="what-compatibility-means" />

<span id="compatibility-status" />

<span id="fully-compatible-modules" />

<span id="stubbed-apis-exist-but-dont-function" />

<span id="why-x-properties-cant-work" />

<span id="working-apis-previously-stubbed" />

<span id="behavioral-differences" />

<span id="systray-details" />

<span id="testing-your-config" />

<span id="before-migrating" />

<span id="quick-migration-checklist" />

<span id="running-awesomewm-tests" />

<span id="reporting-incompatibilities" />

<span id="see-also" />

## The version defines the contract

The [compatibility reference](../reference/deviations.md) records platform differences and unsupported behaviour for this version. Individual API references describe supported properties, methods and signals. Linked AwesomeWM documentation provides background for inherited APIs.

[Upgrade from 1.4 to 2.0](/docs/getting-started/upgrading-from-1.4) describes configuration changes between SomeWM releases. [Migrating from AwesomeWM](../getting-started/migrating.md) covers the move from X11 tools and assumptions to Wayland.

[Wayland vs X11](wayland-vs-x11.md) explains protocol differences. [Architecture](architecture.md) explains the compositor and its Lua libraries.
