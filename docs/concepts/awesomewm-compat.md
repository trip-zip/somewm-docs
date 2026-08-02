---
sidebar_position: 4
title: AwesomeWM Compatibility
description: SomeWM's compatibility philosophy and status
---

# AwesomeWM Compatibility

SomeWM's goal is **drop-in Lua API compatibility** with AwesomeWM. Your existing rc.lua should work with minimal or no changes. SomeWM's *documentation* goal is to be self-sufficient — a complete reference for SomeWM users — so you don't need to consult AwesomeWM's docs to understand the Lua API on SomeWM. This page covers both.

## Documentation promise

SomeWM's docs aim to be **self-sufficient** — a complete reference for SomeWM users:

- **Comprehensive coverage.** Every API surface a SomeWM user reaches for is, or will be, documented here.
- **Organized by task using Diátaxis.** Tutorials (learning), how-to guides (doing), reference (looking up), and concepts (understanding) are kept distinct, so you can find what you need based on what you're trying to do. AwesomeWM's LDoc-generated docs do not separate these.
- **Wayland-aware examples.** Examples use SomeWM idioms (`output`, `somewm-client`, monitor hotplug semantics) rather than X11-isms.
- **Deviations inline.** Where SomeWM differs from AwesomeWM, the difference is documented on the relevant page (look for a "Deviations from AwesomeWM" section) and indexed at [Deviations](/docs/next/reference/deviations).
- **SomeWM-only features are first-class.** Anything unique to SomeWM gets its own page and is marked with a `<SomewmOnly />` badge inline.

We are not self-sufficient on every topic yet. Gaps are tracked internally; if you hit one, file a [discussion](https://github.com/trip-zip/somewm/discussions) and it will get prioritized. The conversation that started this work is [discussion #532](https://github.com/trip-zip/somewm/discussions/532).

### Version targets

| SomeWM version | Tracks AwesomeWM | Status |
|----------------|-------------------|--------|
| 1.4 (current stable) | master (working toward 4.4) | Default docs |
| 2.0 (dev) | (Wayland-native rework) | Behind the version switcher; not released |
| 1.5 (future) | 4.5 (after upstream ships) | Planned |

## Philosophy

1. **Lua libraries are sacred** - The `awful.*`, `gears.*`, and `wibox.*` modules are copied directly from AwesomeWM and never modified. This ensures configs remain portable.

2. **C code matches AwesomeWM behavior** - Same data structures, function signatures, signal timing, and object lifecycles. If AwesomeWM emits `manage` before `focus`, so does SomeWM.

3. **Only deviate when forced by Wayland** - X11 calls are replaced with Wayland equivalents, but the Lua interface stays identical. No gratuitous changes.

## What "Compatibility" Means

When we say an API is compatible, we mean:

- **Same function/property names** - `c.floating`, `awful.spawn`, etc.
- **Same argument types** - If AwesomeWM takes a table, SomeWM takes a table
- **Same return values** - Functions return the same types
- **Same signal names** - `manage`, `focus`, `property::name`, etc.
- **Same signal timing** - Signals fire in the same order relative to events
- **Same default values** - Properties have the same defaults
- **Same object lifecycles** - Objects are created and destroyed at the same points

## Compatibility Status

The broad picture: the standard library surface (`awful`, `wibox`, `gears`, `beautiful`, `naughty`, `ruled`) works as in AwesomeWM, and the exceptions are small and enumerable. The exceptions live in exactly one place: the [Deviations reference](/docs/reference/deviations) is the canonical list of what is stubbed, what is partial, and what SomeWM adds. This page explains *why* the deviations exist; it does not duplicate the list.

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
   - This page - Might be a known stub

2. **Verify the behavior**:
   - Does the same rc.lua work in AwesomeWM?
   - Is it a config error vs a compatibility issue?

3. **Search existing issues**:
   - [GitHub Issues](https://github.com/trip-zip/somewm/issues)

4. **Open a new issue with**:
   - Minimal rc.lua that reproduces the problem
   - Expected behavior (what AwesomeWM does)
   - Actual behavior (what SomeWM does)
   - SomeWM version (`somewm-client eval "return awesome.version"`)

## See Also

- **[Migrating from AwesomeWM](/docs/getting-started/migrating)** - Step-by-step migration guide
- **[Wayland vs X11](/docs/concepts/wayland-vs-x11)** - Fundamental protocol differences
- **[Lua Libraries Reference](/docs/reference/lua-libraries)** - Links to upstream docs
