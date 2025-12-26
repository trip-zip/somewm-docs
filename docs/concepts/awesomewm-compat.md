---
sidebar_position: 4
title: AwesomeWM Compatibility
description: SomeWM's compatibility philosophy and status
---

# AwesomeWM Compatibility

SomeWM's goal is **100% Lua API compatibility** with AwesomeWM.

## Philosophy

1. **Lua libraries are sacred** - The `awful.*`, `gears.*`, and `wibox.*` modules are copied directly from AwesomeWM and never modified.

2. **C code matches AwesomeWM** - Same data structures, function signatures, signal timing, and object lifecycles.

3. **Only deviate for Wayland** - Replace X11 calls with Wayland equivalents, nothing more.

## Compatibility Status

### Fully Compatible

These work exactly as in AwesomeWM:

- Window management (tiling, floating, maximize, minimize)
- Tags and screens
- Keybindings and mouse bindings
- Client rules
- Wibox widgets
- Notifications (naughty)
- Theming (beautiful)
- All awful.* modules
- All gears.* modules

### Stubbed APIs

These exist for compatibility but don't function:

| API | Why |
|-----|-----|
| `awesome.register_xproperty()` | X11 properties don't exist |
| `awesome.get_xproperty()` | Returns nil |
| `awesome.set_xproperty()` | No-op |
| `root.fake_input()` | Requires virtual input protocol |
| `awesome.restart()` | Compositor can't restart |

### Behavioral Differences

| Feature | Difference |
|---------|------------|
| Systray | SNI D-Bus instead of X11 embed |
| Titlebar borders | Inset by border_width |
| Window visibility | Delayed until content ready |

## Testing Compatibility

Run the AwesomeWM test suite:

```bash
make test-integration
```

Tests that require X11-specific features are skipped.

## Reporting Incompatibilities

If you find something that works in AwesomeWM but not in SomeWM:

1. Check [Wayland vs X11](/concepts/wayland-vs-x11) first
2. Search existing [GitHub issues](https://github.com/trip-zip/somewm/issues)
3. Open an issue with your `rc.lua` and steps to reproduce

## See Also

- [Migrating from AwesomeWM](/getting-started/migrating)
- [AwesomeWM API Reference](/reference/awesomewm-apis)
