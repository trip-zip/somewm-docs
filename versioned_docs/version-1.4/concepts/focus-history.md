---
sidebar_position: 4
title: Focus History
description: How focus history selects a visible client after focus is lost.
---

# Focus History

`awful.client.focus.history` records clients in most-recently-focused order. Focus restoration uses that history to choose an eligible visible client on the relevant screen.

## The Focus History List

Focusing a client removes its old entry and inserts it at the front. Unmanaged clients are removed. There is no fixed history length.

## How It Works

<span id="customizing-the-behavior" />
<span id="note-for-awesomewm-users" />

The history records focus changes, independently of visual stacking and layout order. Raising a window alone does not make it the most recently focused client.

## Example Walkthrough

Assuming all three clients remain visible and focusable on one screen:

| Action | History, newest first |
| --- | --- |
| Focus A, then B, then C | C, B, A |
| Close C | B, A |
| Close B | A |

A hidden, minimised or otherwise ineligible client is not necessarily the next focus target even if it is next in the list.

## Focus History vs Client Stack

| Operation | History | Visual stack |
| --- | --- | --- |
| Focus a client | Moves it to the front | Unchanged unless a handler also raises it |
| Raise a client | Unchanged | Moves it upward within its layer |
| Swap clients | Unchanged | Unchanged, but layout order changes |

## Accessing the Focus History

```lua
local awful = require("awful")
local s = awful.screen.focused()
local previous = awful.client.focus.history.get(s, 1, awful.client.focus.filter)

for i, c in ipairs(awful.client.focus.history.list) do
    print(i, c.name, c.screen.index)
end
```

### Parameters for `focus.history.get()`

| Argument | Meaning |
| --- | --- |
| `s` | Screen object or index. Pass a specific screen for screen-local history. |
| `idx` | Zero-based index among visible matching candidates. `0` is most recent. |
| `filter` | Optional function accepting a client and returning whether to include it |

If no history candidate matches, the function can fall back to a visible client accepted by the filter. Without an explicit filter, that fallback uses `awful.client.focus.filter`. It is not a strict index into the raw history list.

## Common Use Cases

### Alt-Tab Style Switching

`awful.client.focus.history.previous()` requests the previous client on the focused client's screen, or the focused screen when no client is focused. It does not request a raise.

`awful.client.focus.byidx(1)` instead cycles through visible clients in client-list order. It does not cycle through focus history.

### Focus Follows Close

The permissions library schedules a focus check when a client is unmanaged. If focus is absent or no longer visible, it chooses an eligible client from history and emits `request::autoactivate`. The default policy first prefers non-sticky clients, then considers other focusable clients.

### Screen-Aware Focus Fallback

The C compositor also requests restoration through `screen`'s `request::focus_restore`. The default handler, `awful.permissions.focus_restore`, selects a visible focusable client on that screen and requests activation without raising.

### Custom Focus Fallback Logic

Replace a specific default handler if you need another policy. Adding a second handler does not disable the first. See [Signals](signals.md#the-request-pattern) for the distinction.

### Disable Focus History

`awful.client.focus.history.disable_tracking()` pauses updates from focus events. It does not clear history or replace the focus-restoration policy. Pair it with `enable_tracking()`. Calls are counted, so each disable needs a matching enable.

Changing `awful.client.focus.filter` affects candidate selection. It does not prevent focused clients from being recorded in the raw history.

## Debugging Focus Issues

Compare the printed history with each client's screen, visibility and focusability. Also inspect handlers that request activation or raise on focus. The raw list alone does not explain every focus decision.

## Layer Shell Focus Restoration

Layer-shell launchers and panels can hold keyboard focus without being clients. When focus needs restoring after one closes, SomeWM uses `screen`'s `request::focus_restore` and `awful.permissions.focus_restore`.

The older `layer_shell::closed` / `handle_layer_shell_closed` interface is not used by the current 1.4 branch.

## See Also

- [Client Stacking](client-stack.md)
- [Object Model](object-model.md)
- [Signals](signals.md)
