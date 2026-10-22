---
sidebar_position: 3
title: Client Stacking
description: One global stack orders clients within a band. Raise and lower change it; focus, swap and tag switches do not. Layouts use creation order, not the stack.
---

# Client Stacking

There is one client stack for the whole compositor, not one per tag or per screen. Switching tags changes what is visible, not the order: raise a window on tag 2, switch away and back, and it is still on top.

## Stack, focus and layout are separate

| Concept | Controls | Ordered by |
| --- | --- | --- |
| Stack | which overlapping client is in front | `c:raise()` and `c:lower()` |
| Focus | which client gets keyboard input | one focused client |
| Layout | position and size of tiled clients | creation order |

Layouts read creation order and ignore the stack, so raising a window never makes it master ([Master and Stack](./master-and-stack.md)).

The stack orders clients within a band. `c.below`, `c.above`, `c.ontop` and `c.fullscreen` move a client to another band, and no stack position puts a normal client above an ontop one ([the bands](./scene-graph.md#bands)). Two exceptions: under `max` and `magnifier`, a floating client is above the layout's clients whatever the raise order, and a transient of such a client is above every client of that layout.

## What changes the stack

| Action | Stack changes | Notes |
| --- | --- | --- |
| a new client maps | yes | added at the top of its band |
| a client closes | yes | removed |
| `c:raise()` | yes | to the top of its band; emits `raised` |
| `c:lower()` | yes | to the bottom of its band; emits `lowered` |
| focusing a client | no | add a `focus` handler that calls `c:raise()` if you want auto-raise |
| `c:swap(other)` | no | swaps positions in the clients array, which layouts read |
| switching tags | no | |

Raising or lowering a client also raises or lowers its transients.

## Two arrays

| Array | Order | Read it |
| --- | --- | --- |
| clients | creation | `client.get(s)`, `awful.client.tiled(s)`; what layouts and the tasklist use |
| stack | back to front | `client.get(s, true)` |

## Signals

```lua
client.connect_signal("raised", function(c) end)
client.connect_signal("lowered", function(c) end)
client.connect_signal("property::ontop", function(c) end)   -- also above, below, fullscreen
```
