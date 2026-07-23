---
title: notification
description: The notification object, some.notify, urgency and timeouts, actions, and the replaceable display.
sidebar_position: 6
---

# notification

A notification is a plain object raised by `some.notify{...}` or by any application over DBus (both arrive through the same constructor, there is no privileged path). The `notification` global is the class. Everything about a notification's life is Lua policy: how long it lives, what critical means, where the popups sit, and what a press does.

```lua
some.notify {
  title = "Volume",
  message = "40%",
  id = 9001,       -- calling again with the same id updates in place
  value = 40,      -- progress bar 0..100
  timeout = 2,
}

notification.on("added", function(n)
  if n.app_name == "spotify" then n:dismiss() end
end)
```

## `some.notify{...}`

Creates a notification, or updates one in place when `id` names a live one (a volume popup is exactly this: same id, new value, no flicker). Returns the notification object.

| Property | Type | Default | Description |
|---|---|---|---|
| `id` | number | nil | DBus id. Present for bus notifications; a matching live id makes the call an in-place update. |
| `title` | string | nil | Heading. |
| `message` | string | nil | Body text. |
| `urgency` | string | `"normal"` | `"low"`, `"normal"`, or `"critical"`. Critical is sticky: it ignores the timeout and stays until dismissed. |
| `timeout` | number | `theme.notification_timeout[urgency]` | Seconds until auto-dismiss; 0 is sticky. Writing it on a live notification re-arms the timer. |
| `actions` | list | `{}` | Action buttons, each `{key = ..., label = ...}`. |
| `screen` | screen | the focused screen | Where the popup is drawn. |
| `icon` | string | nil | Icon name or path. |
| `value` | number | nil | Progress 0..100; the stock display draws a progress bar. |

Any other field is kept verbatim on the object: DBus passthrough hints land this way, and your own fields are visible to whatever display reads them. Managed fields set by the constructor: `seq`, `born`, `alive`; the computed getter `n.age` returns seconds since `born`.

All listed properties are live on the object: writing `title`, `message`, `urgency`, `icon`, or `actions` redraws, and writing `timeout` or `urgency` re-arms the expiry timer.

## Methods

| Method | Description |
|---|---|
| `n:dismiss(reason)` | The one way a notification ends. `reason` is `"expired"`, `"user"` (the default), `"action"`, or `"closed"`; bus notifications report it to the sender. |
| `n:invoke(key)` | Fire an action button: reports ActionInvoked for bus notifications, emits `invoked`, then dismisses with reason `"action"`. |

## Class functions and fields

| Method | Description |
|---|---|
| `notification.all()` | The currently visible notifications, in arrival order. |
| `notification.suspended` | Read/write do-not-disturb flag. While true, new notifications queue in `pending`; setting it false shows the queue in arrival order. |
| `notification.pending` | Read only: the suspension queue. |
| `notification.on(name, fn)` / `notification.off(name, fn)` | Class-level signals. |

## Signals

| Signal | Payload | Emitted when |
|---|---|---|
| `added` | none | A notification is created, before it is displayed. Mutate it here (a three-line rule) and the first frame draws what you wrote. |
| `dismissed` | reason | The notification ended, for any reason. |
| `invoked` | action key | An action button fired. |
| `property::<any>` | new value | Any property write that changed the value. |

## The display

The entire presentation is one replaceable function: `some.defaults.notify_display(s)`, called during each screen's declare. Assign your own function to replace the whole UI, or nil to render nothing. The stock display is written entirely in public [ui](/kiln/reference/ui) API: an overlay-band float stacked top-right below the bar, urgency-colored border, icon, title and message, a progress bar from `value`, action buttons, and press-to-dismiss.

## See also

- [Notifications guide](/kiln/guides/notifications)
- [defaults](/kiln/reference/defaults)
- [ui](/kiln/reference/ui)
- [Theme variables](/kiln/reference/theme-variables)
- [Signal index](/kiln/reference/signals)
