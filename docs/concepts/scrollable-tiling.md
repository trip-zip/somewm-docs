---
sidebar_position: 4.5
title: Scrollable Tiling
description: How the carousel layout models clients as columns on a scrollable strip
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Scrollable Tiling <SomewmOnly />

The carousel layout uses a different model from traditional tiling layouts. Instead of dividing the screen into fixed regions, it places clients on an infinite scrollable strip and moves a viewport across it.

## How It Differs from Master/Stack

Traditional tiling layouts (tile, fair, spiral) divide the screen into sections and fit all tiled clients within them. The carousel takes a different approach:

| | Master/Stack layouts | Carousel |
|---|---|---|
| **Screen usage** | All clients visible at once | Only clients in the viewport are visible |
| **Client sizing** | Derived from screen division | Each column has an independent width fraction |
| **Adding clients** | Existing clients shrink to fit | New column appears, strip grows |
| **Navigation** | Focus moves between visible clients | Focus scrolls the viewport to reveal the target |
| **Tag properties** | Uses `master_count`, `master_width_factor` | Ignores them; uses its own column widths |

## The Strip and Viewport

The core model has two parts:

```
                      viewport (screen width)
                     |<---------------------->|
  ┌─────┬───────────┬───────────┬─────┬──────┐
  │ col │   col 2   │   col 3   │ col │ col  │
  │  1  │           │  (focused) │  4  │  5   │
  └─────┴───────────┴───────────┴─────┴──────┘
  |<-- strip (sum of all column widths) ----->|
```

- **Strip**: An unbounded horizontal canvas. Each column occupies a pixel width derived from its `width_fraction` multiplied by the effective viewport size. Columns sit side by side in order, left to right.
- **Viewport**: A window the size of the screen's workarea that slides over the strip. Only the portion of the strip inside the viewport is visible.

The viewport's position is stored as `scroll_offset`, a pixel value measuring how far the left edge of the viewport is from the left edge of the strip. When `scroll_offset` is 0, you see the leftmost columns. Increasing it reveals columns further right.

## Column Data Model

Each tag maintains its own column state independently. The state for a tag contains:

- **columns**: An ordered array. Each column has:
  - `clients`: An array of clients stacked vertically in that column
  - `width_fraction`: A number controlling the column's width (1.0 = one full viewport width, 0.5 = half)
- **client_to_column**: A reverse index mapping each client to its column and row position
- **scroll_offset**: The current viewport position (may be mid-animation)
- **target_offset**: Where the viewport is animating toward

When a column contains multiple clients, they split the column's height equally, stacking vertically. This is how you group related windows together.

## Viewport Scrolling

When focus moves to a column outside the viewport, the carousel computes a new `target_offset` and animates toward it. The exact behavior depends on the [centering mode](/reference/awful/carousel#centering-modes):

- **on-overflow** (default): If the focused column is already fully visible, do nothing. Otherwise, center it.
- **always**: Always center the focused column, even if it was already visible.
- **edge**: Scroll the minimum distance to bring the focused column fully into view, aligned to the nearer edge.
- **never**: Only scroll if the focused column is completely offscreen (not even partially visible).

The viewport offset is clamped to strip boundaries so you cannot scroll past the first or last column (except in "always" mode, which allows empty space at the edges when centering an edge column).

## Peek Zones

When `peek_width` is set to a positive number, the carousel reserves that many pixels on each side of the viewport. The configured value represents visible content pixels. When `useless_gap` is configured, the gap is automatically added to the peek inset so the full peek zone is `peek_width + useless_gap` pixels, but only `peek_width` pixels of actual column content are shown. The peek zones let you see the edges of adjacent columns as a visual hint that more content exists in that direction.

```
  peek                              peek
  |<->|                            |<->|
  ┌───┬──────────────────────────┬───┐
  │///│      effective viewport   │///│
  │///│                           │///│
  └───┴──────────────────────────┴───┘
```

## Animation

Scroll animations are frame-synced via the compositor's C-side animation system. Each animation:

1. Records the starting `scroll_offset` and the `target_offset`
2. On each display frame, computes progress using an **ease-out-cubic** curve
3. Interpolates between start and target, then calls `apply_geometry` to reposition all clients
4. On completion, snaps to the exact target value

Setting `scroll_duration` to 0 disables animation entirely and snaps instantly.

If focus changes while an animation is in flight, the current animation is cancelled and a new one starts from the current position toward the new target. This makes rapid focus changes (e.g. holding down a focus key) feel responsive rather than queued.

## Reconciliation

The carousel must keep its internal column state synchronized with the compositor's authoritative client list. On every arrange call, the layout runs a reconciliation step:

1. **Remove dead clients.** Any client in a column that is no longer in the tiled client list is removed.
2. **Remove empty columns.** Columns with no remaining clients are deleted.
3. **Add new clients.** Clients in the tiled list that are not in any column get their own new column, inserted after the currently focused column.
4. **Rebuild index.** The `client_to_column` reverse lookup is rebuilt from scratch.

This means the carousel is resilient to external changes. Client rules, signals, or other code that adds or removes clients will be picked up on the next arrange.

## The Vertical Variant

`carousel.vertical` is the same layout rotated 90 degrees. Columns scroll vertically instead of horizontally, and clients within a column stack side by side horizontally. The same API, properties, and centering modes apply. The scroll axis becomes Y, and the stack axis becomes X.

## How Clients Are Positioned

The carousel does not use the standard `p.geometries` table that other layouts use. Instead, it calls `c:_set_geometry_silent()` directly on each client. This internal method positions the client without triggering geometry-change signals or screen reassignment, which is important because offscreen clients would otherwise be detected as belonging to a different screen or trigger cascading relayout.

## See Also

- **[Carousel API Reference](/reference/awful/carousel)** - Complete function and property reference
- **[Carousel Tutorial](/tutorials/carousel)** - Step-by-step first session
- **[Master and Stack](/concepts/master-and-stack)** - How traditional tiling layouts divide the screen
- **[Layout Protocol Reference](/reference/awful/layout)** - The `arrange(p)` contract
