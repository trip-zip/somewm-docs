---
sidebar_position: 4.5
title: Scrollable Tiling
description: The carousel layout declares a Clay scroll container of columns wider than the screen. Each column has its own width fraction, Clay keeps the scroll offset, and focus moves the viewport.
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Scrollable Tiling <SomewmOnly />

Carousel arranges clients in columns on a scrollable strip. Each column’s `width_fraction` sets its share of the viewport width. [Clay computes the geometry](./clients-in-the-tree.md#a-layout-is-a-tree) and stores the scroll offset, labelled `scroll` in the dump.

| | Master and stack | Carousel |
| --- | --- | --- |
| visible | every client | the columns under the viewport |
| sizing | shares of the workarea | each column its own fraction |
| a new client | the others shrink | a new column; the strip grows |
| navigation | focus moves between visible clients | focus scrolls the viewport |
| `master_count`, `master_width_factor` | used | ignored |

```
                      viewport (screen width)
                     |<---------------------->|
  ┌─────┬───────────┬───────────┬─────┬──────┐
  │ col │   col 2   │   col 3   │ col │ col  │
  │  1  │           │ (focused) │  4  │  5   │
  └─────┴───────────┴───────────┴─────┴──────┘
  |<-- strip (sum of all column widths) ----->|
```

## Columns

Each tag stores ordered columns with `clients` and `width_fraction` fields, plus an index from client to column and row. Clients in a column split its height equally. On each layout pass, removed clients and empty columns are discarded. New clients get a column after the focused one, and the index is rebuilt.

## Scrolling

When focus moves to a column outside the viewport, the carousel reads the solved boxes of the viewport and the column, computes the offset the [centering mode](../reference/awful/carousel.md#centering-modes) asks for, and writes it to Clay's scroll record; the next frame scrolls there.

| `center_mode` | Scrolls |
| --- | --- |
| `on-overflow` (default) | only if the column is not fully visible; then centres it |
| `always` | always centres it; the first and last columns get a margin so they can be |
| `edge` | the least distance that brings it fully into view |
| `never` | only if it is entirely off screen |

The offset is clamped to the strip. With `peek_width` above zero the viewport is padded by `peek_width + useless_gap` on each side, so that many pixels of the neighbouring columns show.

A scroll moves every client's box. With `theme.animation_layout_duration` above 0, client frames animate over that duration; at 0, a scroll snaps. There is no carousel-specific setting.

`carousel.vertical` is the same layout turned 90 degrees: columns scroll vertically and a column's clients sit side by side.

[Carousel reference](../reference/awful/carousel.md) has every property and function; [the tutorial](../tutorials/carousel.md) is a first session.
