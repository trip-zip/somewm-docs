---
sidebar_position: 4.5
title: Scrollable Tiling
description: The carousel layout declares a Clay scroll container of columns wider than the screen. Each column has its own width fraction, Clay keeps the scroll offset, and focus moves the viewport.
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Scrollable Tiling <SomewmOnly />

The carousel layout puts clients in columns on a strip wider than the screen and shows the part under a viewport. In [the tree](./clients-in-the-tree.md#a-layout-is-a-tree) it is a Clay scroll container inside the workarea whose content is a row of columns. Each column is a `percent` of the viewport's width, its `width_fraction`; the clients in a column are a column of equal percents. Clay keeps the scroll offset as its scroll record, printed on the container's line in the dump with the `scroll` source word. Nothing in the layout computes a pixel position.

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

Each tag keeps an ordered list of columns, each with `clients` and `width_fraction` (1.0 is the viewport, 0.5 half of it), plus a reverse index from client to column and row. Clients in one column split its height equally. Each time the layout is described it drops clients no longer tiled on the tag and columns left empty, adds new clients each in its own column after the focused one, and rebuilds the index, so clients added by rules or signals appear at the next frame.

## Scrolling

When focus moves to a column outside the viewport, the carousel reads the solved boxes of the viewport and the column, computes the offset the [centering mode](/docs/reference/awful/carousel#centering-modes) asks for, and writes it to Clay's scroll record; the next frame scrolls there.

| `center_mode` | Scrolls |
| --- | --- |
| `on-overflow` (default) | only if the column is not fully visible; then centres it |
| `always` | always centres it; the first and last columns get a margin so they can be |
| `edge` | the least distance that brings it fully into view |
| `never` | only if it is entirely off screen |

The offset is clamped to the strip. With `peek_width` above zero the viewport is padded by `peek_width + useless_gap` on each side, so that many pixels of the neighbouring columns show.

A scroll moves every client's box. With `somewm.layout_animation` loaded, each client frame carries a Clay transition and slides over its `duration`; without it, a scroll snaps. There is no carousel-specific setting.

`carousel.vertical` is the same layout turned 90 degrees: columns scroll vertically and a column's clients sit side by side.

[Carousel reference](/docs/reference/awful/carousel) has every property and function; [the tutorial](/docs/tutorials/carousel) is a first session.
