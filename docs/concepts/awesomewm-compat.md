---
sidebar_position: 4
title: AwesomeWM Compatibility
description: SomeWM's compatibility philosophy and status
---

# AwesomeWM Compatibility

SomeWM's goal is **drop-in Lua API compatibility** with AwesomeWM. Your existing rc.lua should work with minimal or no changes.

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

### Fully Compatible Modules

These work exactly as in AwesomeWM:

| Category | Modules |
|----------|---------|
| **Window Management** | `awful.client`, `awful.tag`, `awful.screen`, `awful.layout` |
| **Input** | `awful.key`, `awful.button`, `awful.keyboard`, `awful.mouse` |
| **Spawning** | `awful.spawn`, `awful.rules`, `ruled.client` |
| **Widgets** | All `wibox.*` modules |
| **Utilities** | All `gears.*` modules |
| **Theming** | `beautiful` |
| **Notifications** | `naughty`, `ruled.notification` |

### Stubbed APIs (Exist but Don't Function)

These APIs exist so configs don't error, but they don't do anything meaningful:

| API | What It Did in AwesomeWM | Why Stubbed |
|-----|--------------------------|-------------|
| `awesome.register_xproperty()` | Register X11 window property | X11 properties don't exist on Wayland |
| `awesome.get_xproperty()` | Read X11 root window property | Always returns nil |
| `awesome.set_xproperty()` | Write X11 root window property | No-op, prints warning |
| `c:get_xproperty()` | Read X11 client property | Always returns nil |
| `c:set_xproperty()` | Write X11 client property | No-op |

#### Why X Properties Can't Work

In X11, windows have arbitrary named properties (atoms) that apps and WMs use to communicate. Examples: `_NET_WM_NAME`, `_MOTIF_WM_HINTS`, custom properties. Wayland has no equivalent - apps communicate via Wayland protocols instead.

### Working APIs (Previously Stubbed)

These were stubs but are now fully implemented:

| API | Status | Notes |
|-----|--------|-------|
| `root.fake_input()` | **Working** | Injects key/button/motion events via wlr_seat |
| `awesome.restart()` | **Working** | Exec's self to restart (clients reconnect) |

`root.fake_input()` supports all event types: `key_press`, `key_release`, `button_press`, `button_release`, and `motion_notify`.

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

### Before Migrating

1. **Check for X11-specific code**:
   - `get_xproperty()` / `set_xproperty()` usage (these are stubs)

2. **Check for external X11 tools**:
   - Replace `xclip` with `wl-copy`/`wl-paste`
   - Replace `scrot`/`import` with `grim`/`slurp`
   - Replace `xdotool` with somewm-client eval

### Quick Migration Checklist

```lua
-- OLD (X11)
awful.spawn("xclip -selection clipboard")
-- NEW (Wayland)
awful.spawn("wl-copy")

-- OLD (X11)
awful.spawn("scrot ~/screenshot.png")
-- NEW (Wayland)
awful.spawn("grim ~/screenshot.png")

-- These X property APIs are no-ops on Wayland
c:set_xproperty("MY_PROP", value)  -- Does nothing

-- These now work on SomeWM!
awesome.restart()  -- Restarts the compositor
root.fake_input("key_press", "a")  -- Injects input
```

### Running AwesomeWM Tests

SomeWM includes AwesomeWM's test suite:

```bash
make test-integration
```

Tests requiring X11-specific features are automatically skipped.

## Reporting Incompatibilities

If you find something that works in AwesomeWM but not in SomeWM:

1. **Check the docs first**:
   - [Wayland vs X11](/concepts/wayland-vs-x11) - Might be a fundamental difference
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

- **[Migrating from AwesomeWM](/getting-started/migrating)** - Step-by-step migration guide
- **[Wayland vs X11](/concepts/wayland-vs-x11)** - Fundamental protocol differences
- **[Lua Libraries Reference](/reference/lua-libraries)** - Links to upstream docs
