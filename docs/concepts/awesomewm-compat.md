---
sidebar_position: 4
title: AwesomeWM Compatibility
description: Which SomeWM line tracks which AwesomeWM, what a shared API name does and does not promise, the pattern behind every stub, and the behavioural differences a config meets.
---

# AwesomeWM Compatibility

| SomeWM | Tracks | Status |
| --- | --- | --- |
| 1.4 | AwesomeWM master | maintained indefinitely as the compatible line; 2.x features are not backported except for parity |
| 2.0 | its own line | current release, default docs |
| 2.1 | its own line | in development |

Compatibility is per API, not per library. A familiar name does not mean every function, argument, default or signal behaves as in AwesomeWM; the SomeWM reference for your release is the contract, and the linked upstream docs are background. 2.0 removed the deprecated APIs, among them `naughty.notify()`, `awful.rules` and the bare `manage` and `unmanage` signals ([replacements](../getting-started/migrating.md#deprecated-apis-removed-in-somewm-20)).

## Stubs

Most stubs are APIs whose whole job was X11 machinery Wayland does not have. `awesome.register_xproperty()` and its family exist so configs do not error, and do nothing: Wayland has no per-window named properties; apps talk through protocols. The reverse also happened: `root.fake_input()` and `awesome.restart()` were impossible early and now have Wayland-native implementations, the compositor injecting events through `wlr_seat` and rebuilding the Lua state in process. [Deviations](../reference/deviations.md) tracks each one.

## Behavioural differences

| Feature | AwesomeWM | SomeWM | Effect |
| --- | --- | --- | --- |
| systray | `_NET_SYSTEMTRAY` embeds X11 windows | StatusNotifierItem over D-Bus | modern apps work; XEmbed-only apps show no icon |
| titlebar and border | border drawn outside by the X server | border is a scene rect; titlebars sit inside it | titlebars inset by `border_width` |
| window visibility | `map` shows at once | shown when the first buffer arrives | no smearing |
| clipboard | X selections | Wayland clipboard and primary | `wl-copy`, `wl-paste` |
| screenshots | X11 grabbing | the compositor composes the capture | `somewm-client screenshot`, or grim and slurp |

## Testing and reporting

`make test-integration` runs AwesomeWM's suite against SomeWM; X11-only tests are skipped. `somewm --check rc.lua` scans a config for X11 idioms ([Migrating](/docs/getting-started/migrating)).

Before filing something that works in AwesomeWM and not here, check [Wayland vs X11](./wayland-vs-x11.md) and the affected reference page, then open an [issue](https://github.com/trip-zip/somewm/issues) with a minimal `rc.lua`, expected and actual behaviour, and `somewm-client version`.
