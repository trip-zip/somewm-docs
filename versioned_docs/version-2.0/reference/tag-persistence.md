---
sidebar_position: 5
title: Tag Persistence
description: Signals and state structure for tag save/restore across hotplug
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Tag Persistence <SomewmOnly />

Tag persistence saves and restores tag state across monitor hotplug. The save handler lives in `awful.permissions` (connected automatically), and the restore handler lives in `somewmrc.lua`. Saved state is in memory and is lost when the configuration reloads or the compositor exits.

## Signals

Two signals drive the save/restore cycle:

### `tag` `request::screen`

Fired when a tag's screen is about to be removed.

| Argument | Type | Description |
|----------|------|-------------|
| `t` | tag | The tag losing its screen |
| `reason` | string | Why the screen is being lost (`"removed"` on disconnect) |

The default handler is `awful.permissions.tag_screen`. It checks `reason == "removed"` and saves the tag's metadata into `awful.permissions.saved_tags`, keyed by `t.screen.output.name`.

In 2.0, this handler only saves state. The separate screen-removal handler in `awful.tag` deletes old tags and moves clients to a fallback screen.

### `screen` `request::desktop_decoration`

Fired when a new screen is created and needs tags and wibars.

| Argument | Type | Description |
|----------|------|-------------|
| `s` | screen | The new screen |

The default handler checks for saved state matching `s.output.name`. If found, it restores saved tags. Otherwise, it creates the five default tags: `dev`, `web`, `chat`, `files`, and `media`.

## Saved State Structure

Each tag is saved as a table with these fields:

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Tag name |
| `selected` | boolean | Whether the tag was selected (visible) |
| `layout` | table | Layout algorithm (`awful.layout.suit.*`) |
| `master_width_factor` | number | Master area width ratio (0.0 to 1.0) |
| `master_count` | number | Number of master windows |
| `gap` | number | Spacing between tiled clients in pixels |
| `clients` | table | Array of client objects that were on this tag |

`awful.permissions.saved_tags[connector_name]` is an array of these records, in save order. For example, `awful.permissions.saved_tags["HDMI-A-1"]` holds the disconnected HDMI output’s tags.

## Restore Behavior

The restore handler uses a two-pass approach so that clients on multiple tags keep their full tag list:

1. **Pass 1:** For each saved tag entry, `awful.tag.add()` creates the tag with the saved properties. Valid clients are collected into a per-client tag list.
2. **Pass 2:** Each client is moved to the screen once via `c:move_to_screen(s)`, then assigned all its tags at once via `c:tags(tags)`.

The connector’s saved state is cleared during restoration. Restored memberships replace the client’s current tags, including changes made while the output was disconnected. `column_count` and other properties absent from the saved record are not restored.

## Default Implementation

`awful.permissions.tag_screen` saves tags on `request::screen`. The `request::desktop_decoration` handler in the default `somewmrc.lua` restores them before creating the wibar. A custom config must supply the restore handler.

See [Tag persistence](../guides/tag-persistence.md) for the complete save and restore code.

## Related Properties

The default key is `output.name`. A custom handler can use other identifiers:

| Property | Type | Description |
|----------|------|-------------|
| `output.name` | string | Connector name (e.g. `"HDMI-A-1"`, `"eDP-1"`) |
| `output.make` | string or nil | Monitor manufacturer |
| `output.model` | string or nil | Monitor model |
| `output.serial` | string or nil | Monitor serial number |

See the [output reference](/docs/2.0/reference/output) for the full property list.

## See Also

- **[Tag Persistence Concepts](/docs/2.0/concepts/tag-persistence)** - Why this feature exists and its limitations
- **[Tag Persistence Guide](/docs/2.0/guides/tag-persistence)** - Customize save/restore behavior
- **[Multi-Monitor Setup](/docs/2.0/guides/multi-monitor)** - General multi-monitor configuration
- **[screen Reference](/docs/2.0/reference/screen)** - Screen object API
- **[Signals Reference](/docs/2.0/reference/signals)** - All signal types
