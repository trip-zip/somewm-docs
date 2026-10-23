---
sidebar_position: 4.5
title: Scrollable Tiling
description: Columns, viewport movement and animation in the 2.0 carousel layout.
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Scrollable Tiling <SomewmOnly />

Carousel places clients in columns along a scrollable strip. Focusing a column can move the viewport to reveal it, without shrinking every other column to fit the screen.

## How It Differs from Master/Stack

A `tile` layout divides the available workarea among master and secondary clients. Carousel gives columns independent width fractions and lets the strip extend beyond the viewport. It does not use `master_count` or `master_width_factor`.

## The Strip and Viewport

The horizontal strip is the sum of column widths. The viewport is the visible workarea, reduced by any peek insets. A column's width fraction multiplies the effective viewport width.

`scroll_offset` is the current distance along the strip. `target_offset` is the destination of a scroll animation. An offset of zero shows the beginning, and increasing it reveals later columns.

## Column Data Model

Each tag keeps independent state:

| Field | Meaning |
| --- | --- |
| `columns` | Ordered columns, each with a client list and `width_fraction` |
| `client_to_column` | Lookup from client to its column and row |
| `scroll_offset` | Current viewport position |
| `target_offset` | Requested viewport position |

Clients in one horizontal-carousel column share its height equally, after gaps and borders are accounted for.

## Viewport Scrolling

| `center_mode` | Behaviour when focus changes |
| --- | --- |
| `"on-overflow"` (default) | Centre the column if it is not fully visible |
| `"always"` | Centre it even when it is already visible |
| `"edge"` | Scroll enough to bring the nearer clipped edge into view |
| `"never"` | Scroll only when the column is completely outside the viewport |

`beautiful.carousel_center_mode` overrides the layout setting. Offsets are clamped to the strip boundaries except in `"always"` mode, which permits empty space when centring an edge column.

## Peek Zones

`peek_width` reserves space on each side for the edges of neighbouring columns. `beautiful.carousel_peek_width` overrides the layout setting. A positive peek width adds the tiling gap to the inset, so the gap does not consume the requested content width.

Column width fractions use the workarea extent minus both insets, with a minimum of one pixel. `dynamic_peek_width` can adjust the outer inset when the first or last column is focused in `"edge"` or `"never"` mode. Its default, `-1`, disables that adjustment.

## Animation

The C animation system interpolates `scroll_offset` toward `target_offset` with an ease-out-cubic curve. The default `scroll_duration` is zero, so scrolling is immediate. Set a positive duration in seconds to enable animation.

A new scroll request replaces an in-progress animation and starts from the current position.

## Reconciliation

Each arrange call compares the stored columns with the current tiled-client list. It removes clients no longer present, deletes empty columns, inserts new clients after the focused column and rebuilds the lookup table. A client can leave the layout by becoming floating or hidden, as well as by closing.

## The Vertical Variant

`carousel.vertical` swaps the axes. Columns scroll vertically, and clients in a column sit side by side. Width fractions become fractions of the vertical viewport extent. The same centring modes and controls apply.

## How Clients Are Positioned

Carousel calls `c:_set_geometry_silent()` rather than returning all positions through `p.geometries`. This avoids ordinary geometry signals and automatic screen reassignment while clients are positioned outside the visible workarea.

## See Also

- [Carousel Reference](../reference/awful/carousel.md)
- [Carousel Tutorial](../tutorials/carousel.md)
- [Master and Stack](master-and-stack.md)
- [Layout Protocol](../reference/awful/layout.md)
