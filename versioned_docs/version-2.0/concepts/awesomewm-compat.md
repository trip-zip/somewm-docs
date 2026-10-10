---
sidebar_position: 4
title: AwesomeWM Compatibility
description: SomeWM's compatibility philosophy and status
---

# AwesomeWM Compatibility

SomeWM 2.x builds on AwesomeWM's Lua configuration model and develops its APIs independently. Existing configurations may require changes. SomeWM 1.4 remains the line focused on upstream AwesomeWM compatibility.

This page explains that relationship and how to assess compatibility for your configuration.

## Documentation promise

SomeWM's docs aim to be **self-sufficient** — a complete reference for SomeWM users:

- **Comprehensive coverage.** Every API surface a SomeWM user reaches for is, or will be, documented here.
- **Organized by task using Diátaxis.** Tutorials (learning), how-to guides (doing), reference (looking up), and concepts (understanding) are kept distinct, so you can find what you need based on what you're trying to do. AwesomeWM's LDoc-generated docs do not separate these.
- **Wayland-aware examples.** Examples use SomeWM idioms (`output`, `somewm-client`, monitor hotplug semantics) rather than X11-isms.
- **Deviations inline.** Where SomeWM differs from AwesomeWM, the difference is documented on the relevant page (look for a "Deviations from AwesomeWM" section) and indexed at [Deviations](../reference/deviations.md).
- **SomeWM-only features are first-class.** Anything unique to SomeWM gets its own page and is marked with a `<SomewmOnly />` badge inline.

We are not self-sufficient on every topic yet. Gaps are tracked internally; if you hit one, file a [discussion](https://github.com/trip-zip/somewm/discussions) and it will get prioritized. The conversation that started this work is [discussion #532](https://github.com/trip-zip/somewm/discussions/532).

### Version targets

| SomeWM version | Tracks AwesomeWM | Status |
|----------------|-------------------|--------|
| 1.4 | master (working toward 4.4) | Stable, actively maintained as the AwesomeWM-compatible line |
| 2.0 | (Wayland-native rework) | Newest release, default docs |
| 2.1 (dev) | (Wayland-native rework) | In development |
| 1.5 (future) | 4.5 (after upstream ships) | Planned |

SomeWM 1.4 follows upstream AwesomeWM. Features developed for 2.x are generally not planned for backporting to 1.4; exceptions are expected to be rare and related to AwesomeWM parity.

## Philosophy

SomeWM 2.x retains AwesomeWM's Lua configuration model while developing its libraries and compositor independently. API changes can follow from Wayland requirements or SomeWM design decisions. Upstream API parity is the focus of the 1.4 line.

## What "Compatibility" Means

Compatibility needs to be assessed for the APIs your configuration uses. Familiar library and property names do not imply that every function, argument, default, or signal behaves identically to AwesomeWM.

Use the SomeWM reference for the selected release when checking an API. Linked upstream documentation explains inherited APIs, but is not a guarantee that every upstream API is supported.

## Compatibility Status

SomeWM 2.0 removed deprecated APIs, including `naughty.notify()`, `awful.rules`, and the bare `manage` and `unmanage` signals. See [Deprecated APIs Removed in SomeWM 2.0](../getting-started/migrating.md#deprecated-apis-removed-in-somewm-20) for replacements, and [client lifecycle](../guides/react-to-client-lifecycle.md) for the supported signals.

The [Deviations reference](../reference/deviations.md) describes differences from AwesomeWM, including stubs, partial implementations, and SomeWM-specific APIs. The affected API pages document behaviour for this release.

The pattern behind most stubs is the same: an API whose entire job was to touch X11 machinery that Wayland deliberately does not have. The clearest case is the X-property family (`register_xproperty` and friends). In X11, windows have arbitrary named properties (atoms) that apps and WMs use to communicate: `_NET_WM_NAME`, `_MOTIF_WM_HINTS`, custom properties. Wayland has no equivalent; apps communicate via Wayland protocols instead. So those APIs exist (configs don't error) but cannot do anything meaningful.

The inverse pattern also exists: APIs that were impossible early on and later got Wayland-native implementations, like `root.fake_input()` (the compositor injects events itself) and `awesome.restart()` (an in-process Lua state rebuild instead of an exec). The reference tracks their current status.

### Behavioral Differences

These work, but behave slightly differently:

| Feature | AwesomeWM (X11) | SomeWM (Wayland) | Impact |
|---------|-----------------|------------------|--------|
| **Systray** | X11 `_NET_SYSTEMTRAY` embed | StatusNotifierItem D-Bus | Most apps work; legacy tray-only apps don't |
| **Titlebar borders** | Drawn outside by X server | Inset by `border_width` | Titlebars positioned differently |
| **Window visibility** | `map` shows immediately | Delayed until content ready | Prevents visual smearing |
| **Clipboard** | X selections | Wayland clipboard + primary | Use wl-copy/wl-paste |
| **Screenshots** | X11 grabbing | wlr-screencopy protocol | Use grim/slurp or somewm-client |

#### Systray Details

AwesomeWM embeds X11 windows directly via the `_NET_SYSTEMTRAY` protocol. SomeWM uses the modern StatusNotifierItem (SNI) D-Bus protocol instead.

**Apps that work**: Most modern apps (NetworkManager, Bluetooth applet, Discord, Steam) support SNI.

**Apps that don't work**: Very old apps that only support XEmbed (some legacy Java apps, very old versions of apps).

## Testing Your Config

The practical migration workflow (scanning your config with `somewm --check`, the X11-to-Wayland tool substitutions, suppressing false positives) lives in the [Migrating guide](/docs/getting-started/migrating).

### Running AwesomeWM Tests

SomeWM includes AwesomeWM's test suite:

```bash
make test-integration
```

Tests requiring X11-specific features are automatically skipped.

## Reporting Incompatibilities

If you find something that works in AwesomeWM but not in SomeWM:

1. **Check the docs first**:
   - [Wayland vs X11](/docs/concepts/wayland-vs-x11) - Might be a fundamental difference
   - The affected SomeWM API reference - Might be a documented change or removal

2. **Verify the behavior**:
   - Does the same rc.lua work in AwesomeWM?
   - Is it a config error vs a compatibility issue?

3. **Search existing issues**:
   - [GitHub Issues](https://github.com/trip-zip/somewm/issues)

4. **Open a new issue with**:
   - Minimal rc.lua that reproduces the problem
   - Expected behaviour and the documentation it is based on
   - AwesomeWM behaviour, if relevant to the comparison
   - Actual behavior (what SomeWM does)
   - SomeWM version (`somewm-client version`)

## See Also

- **[Migrating from AwesomeWM](/docs/getting-started/migrating)** - Step-by-step migration guide
- **[Wayland vs X11](/docs/concepts/wayland-vs-x11)** - Fundamental protocol differences
- **[Lua Libraries Reference](/docs/reference/lua-libraries)** - Links to upstream docs
