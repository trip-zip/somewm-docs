---
sidebar_position: 4
title: Focus History
description: How recent focus and client eligibility determine focus restoration.
---

# Focus History

`awful.client.focus.history` records clients in most-recently-focused order. Restoration uses that history to choose a visible, focusable client on the affected screen.

## The Focus History List

A delivered `focus` signal moves its client to the front of the list. Unmanaged clients are removed. There is no fixed history length.

## How It Works

History follows focus events, independently of layout order and visual stacking. In 2.0, compositor-generated focus signals are queued. The focused client can therefore change before the history handler runs. See [signal timing](signals.md#dispatch-model).

## Example Walkthrough

Assuming A, B and C remain visible and focusable on one screen, and each focus event has been delivered:

| Action | History, newest first |
| --- | --- |
| Focus A, then B, then C | C, B, A |
| Close C | B, A |
| Close B | A |

A hidden, minimised or otherwise ineligible client is skipped when choosing a restoration target.

## Focus History vs Client Stack

| Operation | History | Visual stack |
| --- | --- | --- |
| Focus a client | Moves it to the front when the signal is delivered | Unchanged unless a handler also raises it |
| Raise a client | Unchanged | Moves it upward within its layer |
| Swap clients | Unchanged | Unchanged, but layout order changes |

## One Restoration Path

The compositor emits `screen`'s `request::focus_restore` when focus needs restoring after events such as closing a client, dismissing a layer-shell launcher or unlocking. `awful.permissions.focus_restore` selects an eligible client from history and requests activation without raising. If Lua leaves no client focused, C falls back to the topmost eligible client on that monitor.

The permissions library also schedules focus checks after unmanage, tag and visibility changes. These checks can restore focus when the current client is absent or no longer visible.

Custom activation filters or replacement handlers can change the outcome. See the [focus guide](../guides/focus.md) for configuration and debugging.

## See Also

- [Client Stacking](client-stack.md)
- [Object Model](object-model.md)
- [Signals](signals.md)
