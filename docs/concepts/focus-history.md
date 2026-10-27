---
sidebar_position: 4
title: Focus history
description: How recent focus and client eligibility determine focus restoration.
---

# Focus history

<span id="one-restoration-path" />

`awful.client.focus.history` records clients in most-recently-focused order. A delivered `focus` signal moves its client to the front. Closing a client removes it. There is no fixed history length.

Assuming A, B and C remain visible and focusable on one screen, and each focus event has been delivered:

| Action | History, newest first |
| --- | --- |
| Focus A, then B, then C | C, B, A |
| Close C | B, A |
| Close B | A |

The history and [visual stack](client-stack.md) are independent. Focusing updates history without explicitly raising. Raising changes the stack without changing history.

## Signal timing

Compositor-generated focus signals are queued. `client.focus` can therefore change before the history handler runs. Code that needs the updated history must wait until those handlers have run. See [signal dispatch](signals.md#dispatch).

## Restoring focus

The compositor emits `screen`'s `request::focus_restore` after events such as a client closing, a layer-shell launcher dismissing, or the session unlocking. The default handler, `awful.permissions.focus_restore`, chooses a visible, focusable client from that screen's history and requests activation without raising.

If Lua leaves no client focused, C tries the topmost eligible client on that monitor. There may be no eligible client. Activation filters and replacement handlers can also change the outcome.

The permissions library schedules additional checks after unmanage, tag and visibility changes. These restore focus when the current client is absent or no longer visible. The [focus guide](../guides/focus.md) covers configuration and diagnosis.
