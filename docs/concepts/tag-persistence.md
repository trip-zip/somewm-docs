---
sidebar_position: 11
title: Why tags persist
description: How the default config restores tags after a monitor reconnects.
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Why tags persist <SomewmOnly />

The default configuration saves tag settings when a screen disappears and restores them when the same connector returns. Clients temporarily moved to another screen can return to their original tags.

Disconnecting or disabling an output removes its screen. Turning an output off through DPMS does not necessarily remove it. Persistence concerns screen removal, not every display-power change.

## Save and restore

| Event | Handler | Result |
| --- | --- | --- |
| Screen removed | `awful.permissions.tag_screen`, on tag `request::screen` | Save tag state under the connector name |
| Screen created | Default `request::desktop_decoration` handler | Restore saved tags for that connector, or create the default tags |

Each saved tag records `name`, `selected`, `layout`, `master_width_factor`, `master_count`, `gap`, and its clients. This does not include every tag property or layout-internal state such as carousel column groupings.

Restoration recreates all tags first, then assigns each surviving client its saved tag list. This preserves membership in several tags. Restored membership replaces changes made while the screen was disconnected.

## Limits

- The key is the connector name, such as `HDMI-A-1`, not monitor make, model or serial. Moving the monitor to another connector does not match the saved entry.
- Saved entries live in Lua memory. A process restart or Lua-state rebuild loses pending entries for disconnected screens. Active tags have a separate reload restoration path.
- Custom screen-decoration code must include restoration if it wants this behaviour. The permissions library only supplies the save handler.
- Clients that close before reconnection are skipped.

See the [guide](../guides/tag-persistence.md) to customise saving and restoration, or the [reference](../reference/tag-persistence.md) for the saved-state format.
