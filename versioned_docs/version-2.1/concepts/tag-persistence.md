---
sidebar_position: 11
title: Tag Persistence
description: Removing a screen destroys its tags. The default config saves each tag's metadata keyed by connector name at request::screen and restores it at request::desktop_decoration when the same connector returns.
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Tag Persistence <SomewmOnly />

On Wayland a monitor comes and goes often: a lid closes, a dock disconnects, a panel powers down. Each time, the `screen` object and its tags are destroyed, and the returning monitor gets a fresh screen. The default config saves what was on the screen and restores it when the same connector comes back: same names, layouts and clients.

## Save and restore

| Step | Signal | Handler | Does |
| --- | --- | --- | --- |
| monitor disconnects | `tag` `request::screen` | `awful.permissions.tag_screen`, connected by default | saves each tag's metadata under the output's connector name (`eDP-1`, `HDMI-A-1`); C moves clients to a surviving screen |
| monitor reconnects | `screen` `request::desktop_decoration` | the handler in `somewmrc.lua` | finds saved state for that connector and recreates the tags from it, or creates the default tags if there is none |

Saved per tag: `name`, `selected`, `layout`, `master_width_factor`, `master_count`, `gap`, and the clients that were on it.

## Limits

- **Connector name only.** The same monitor on a different port gets default tags. Connector names are stable within a boot and can change across reboots, notably with USB-C docks.
- **In memory.** A compositor restart starts fresh.
- **Config feature.** Both handlers are Lua. A config that disconnects the default `request::screen` handler or replaces `request::desktop_decoration` carries its own persistence or has none.

AwesomeWM deletes the tags and dumps the clients on a fallback screen; a reconnected monitor gets default tags.

[Tag Persistence guide](../guides/tag-persistence.md) customises the behaviour; [the reference](../reference/tag-persistence.md) has the signals and the saved-state table.
