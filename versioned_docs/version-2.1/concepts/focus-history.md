---
sidebar_position: 4
title: Focus History
description: awful.client.focus.history keeps every focused client in most-recent-first order. Every loss of focus goes through one signal, request::focus_restore, whose default handler reads that list.
---

# Focus History

`awful.client.focus.history` is a list of clients in the order they were last focused, most recent first, with no depth limit. Each time a client receives focus it is removed from wherever it was and inserted at the front. When a client closes, the next one in the list that is still visible on its screen gets focus.

| Action | History, front to back |
| --- | --- |
| focus 1, 2, 5, 4 | 4, 5, 2, 1 |
| close 4 | 5, 2, 1; focus goes to 5 |
| close 5 | 2, 1; focus goes to 2, skipping 3, which was never focused |

The history and [the client stack](./client-stack.md) are independent: focusing moves a client to the front of the history and leaves the stack alone; raising does the reverse.

## One restoration path

A client closing, a layer-shell launcher such as rofi dismissing, the session unlocking and a monitor disconnecting all take focus away. The C core routes every one of them through one signal, `request::focus_restore`, emitted on the affected screen. The default handler, `awful.permissions.focus_restore`, activates the most recently focused client still visible on that screen. If no handler focuses anything, C falls back to the topmost client, so a broken handler degrades rather than stranding focus.

AwesomeWM restores focus from several separate code paths and has no layer shell; the single signal is SomeWM's.

[Control where focus goes](../guides/focus.md) has the recipes: alt-tab bindings, a custom fallback policy, filtering and debugging.
