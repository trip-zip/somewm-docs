---
sidebar_position: 11
title: Tag Persistence
description: How the default configuration saves tags by connector and restores them after hotplug.
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Tag Persistence <SomewmOnly />

The default configuration saves tag settings when a screen disappears and restores them when its connector returns. Clients temporarily moved to another screen can return to their original tags.

## The Problem: Hotplug on Wayland

Disconnecting or disabling an output removes its screen. A later connection creates a new screen object. Without saved state, the screen-decoration handler would create default tags rather than restore the previous workspace.

This concerns screen removal, not every change in display power. Turning off scanout with DPMS is separate from disabling an output.

## The Save/Restore Cycle

1. On removal, each tag emits `request::screen` with context `"removed"`.
2. `awful.permissions.tag_screen` records metadata in `awful.permissions.saved_tags`, keyed by connector name.
3. When the connector returns, the default config's `request::desktop_decoration` handler consumes that saved state.
4. It recreates all tags, then moves still-valid clients and restores their full saved tag lists.

With no saved entry, the default config creates tags `1` through `9`.

### What Gets Saved

| Field | Meaning |
| --- | --- |
| `name` | Tag name |
| `selected` | Whether the tag was visible |
| `layout` | Layout object |
| `master_width_factor` | Master-area proportion |
| `master_count` | Number of master clients |
| `gap` | Tiling gap |
| `clients` | References to clients assigned to the tag |

Other custom tag properties are not automatically included. This mechanism does not save arbitrary layout-internal state, such as carousel column groupings.

### The Connector Name Key

A saved entry for `HDMI-A-1` is restored when that connector returns. Moving the monitor to another connector does not match the entry. Monitor make, model and serial are not used as keys.

## Comparison with AwesomeWM

The connector-keyed save handler and default restore code are SomeWM additions. They retain workspace state across screen destruction instead of relying on the old screen object surviving.

## Limitations

- The save handler is installed by `awful.permissions`, but restoration is part of the default configuration. Custom screen-decoration code must include equivalent restoration if it wants this behaviour.
- Saved entries are Lua memory. They do not survive a full compositor process restart, and pending entries for disconnected screens are not retained through a Lua-state rebuild.
- Active tags and selection have a separate hot-reload restoration path. That is distinct from this disconnected-screen cache.
- Clients that close before reconnection are skipped during restoration.

## See Also

- [Tag Persistence Guide](../guides/tag-persistence.md)
- [Tag Persistence Reference](../reference/tag-persistence.md)
- [Multi-Monitor Setup](../guides/multi-monitor.md)
