---
sidebar_position: 11
title: Tag Persistence
description: How tags survive monitor hotplug on Wayland
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Tag Persistence <SomewmOnly />

When you unplug a monitor and plug it back in, SomeWM's default config restores the tags that were on it: same names, same layouts, same clients.

## The Problem: Hotplug on Wayland

On X11, monitor hotplug is relatively rare and handled by XRandR. AwesomeWM responds to RandR events, but screen destruction and recreation works differently under the X server. In practice, most X11 users configure their monitors once and leave them.

On Wayland, hotplug is constant:

- Closing a laptop lid disables the internal display
- USB-C docks connect and disconnect external monitors
- Power-saving monitors turn off and reappear
- KVM switches move displays between machines

Each of these events destroys the `screen` object and all its tags. When the monitor returns, a fresh screen is created with no memory of what was there before. Without tag persistence, every reconnect resets your workspace to default tags. Any window arrangement, layout tuning, or tag selection is lost.

## The Save/Restore Cycle

Two signals drive the save/restore cycle. The save handler (`awful.permissions.tag_screen`) lives in `awful.permissions` and is connected automatically. The restore handler lives in `somewmrc.lua`'s `request::desktop_decoration`:

```
Monitor disconnects        Monitor reconnects
        │                          │
        ▼                          ▼
 tag request::screen        screen request::desktop_decoration
        │                          │
        ▼                          ▼
 Save tag metadata          Check for saved state
 keyed by connector         for this connector
 name (e.g. "HDMI-A-1")           │
                            ┌─────┴─────┐
                            │           │
                            ▼           ▼
                        Found:       Not found:
                        Restore      Create default
                        saved tags   tags ("1"-"9")
```

### What Gets Saved

When a screen is removed, each tag's metadata is captured:

| Property | Description |
|----------|-------------|
| `name` | Tag name (e.g. "1", "web", "code") |
| `selected` | Whether the tag was active |
| `layout` | The layout algorithm (tile, fair, floating, etc.) |
| `master_width_factor` | Proportion of screen for the master area |
| `master_count` | Number of windows in the master area |
| `gap` | Spacing between tiled windows |
| `clients` | References to the windows on this tag |

### The Connector Name Key

Saved state is keyed by the output's connector name, such as `eDP-1`, `HDMI-A-1`, or `DP-2`. This is the physical port identifier reported by the hardware.

This means:

- Reconnecting the **same port** restores state correctly
- Reconnecting a **different port** creates fresh tags (the saved state is orphaned)
- Connector names are **stable within a boot** but may change across reboots if hardware enumerates differently (common with USB-C docks)

## Comparison with AwesomeWM

| Scenario | AwesomeWM (X11) | SomeWM (Wayland) |
|----------|-----------------|------------------|
| Monitor disconnected | Tags deleted, clients dumped to fallback screen | Tags saved, clients migrated temporarily |
| Monitor reconnected | Fresh default tags created | Previous tags and layout restored |
| Layout customization | Lost on disconnect | Preserved across reconnect |
| Client placement | Clients stay on fallback screen | Clients return to their original tags |

## Limitations

- **Connector name only.** State is not matched by monitor make/model/serial. If you move a monitor to a different port, the saved state won't follow it.
- **In-memory only.** State does not persist across compositor restarts. Restarting SomeWM starts fresh.
- **Default config feature.** The save handler lives in `awful.permissions` (connected automatically), and the restore handler lives in `somewmrc.lua`. Both are in Lua, not the C core. Custom configs that disconnect the default `request::screen` handler or override `request::desktop_decoration` must implement their own persistence if desired.

## See Also

- **[Tag Persistence Guide](/guides/tag-persistence)** - Customize save/restore behavior
- **[Tag Persistence Reference](/reference/tag-persistence)** - Signals and saved state structure
- **[Multi-Monitor Setup](/guides/multi-monitor)** - General multi-monitor configuration
- **[Wayland vs X11](/concepts/wayland-vs-x11)** - Other platform differences
