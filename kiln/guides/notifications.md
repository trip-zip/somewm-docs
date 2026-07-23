---
title: Notifications
description: Receive desktop notifications, raise your own, tune timeouts and urgency, and replace the whole display.
sidebar_position: 5
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Notifications

<YouWillLearn>

- How kiln receives desktop notifications without a separate daemon
- Raising notifications from your config with `some.notify`
- Urgency, timeouts, and the theme keys behind them
- Reacting to notification signals and action buttons
- Replacing the entire display with your own

</YouWillLearn>

## 1. kiln is the notification daemon

kiln implements the freedesktop notification service (`org.freedesktop.Notifications`) itself: `notify-send`, browsers, chat apps, and volume scripts deliver straight to the compositor, which draws the popups as part of its own scene. Do not run mako, dunst, or another daemon alongside; they would compete for the same DBus name. The service advertises `body`, `actions`, and `icon-static` capabilities.

There is nothing to enable. A DBus session must exist (the standard `make run` line launches kiln under `dbus-run-session`), and notifications appear stacked at the top-right, colored by urgency.

## 2. Raise your own

`some.notify{}` creates a notification from config code; the same constructor the DBus intake uses:

```lua
some.notify {
	title = "Battery",
	message = "15% remaining",
	urgency = "critical",
}
```

Accepted fields:

| Field | Meaning |
|---|---|
| `title`, `message` | the text |
| `urgency` | `"low"`, `"normal"` (default), `"critical"` |
| `timeout` | seconds until auto-dismiss; `0` means sticky |
| `icon` | image path |
| `value` | a number 0 to 100; the display draws it as a progress bar |
| `actions` | list of `{ key = "id", label = "text" }` buttons |
| `screen` | where to show it (default: the focused screen) |
| `id` | an id that names a live notification updates it in place |
| anything else | kept verbatim on the object for your display or listeners to read |

It returns the notification object. The update-in-place behavior of `id` is what makes a volume popup one repeated call rather than a stack of popups.

Critical notifications never expire on their own: dismissing them is the user's (or your code's) job. `n:dismiss()` is the one way any notification ends; `notification.all()` lists the currently visible ones.

## 3. Timeouts and theme keys

When `timeout` is not given, the per-urgency default from the theme applies:

```lua
some.theme.notification_timeout = { low = 3, normal = 5, critical = 0 }
```

The display reads a few more [theme variables](/kiln/reference/theme-variables): `notification_width` (default 320), `notification_offset` (inset from the screen edges, 12), `notification_gap` (between stacked popups, 8), and `notification_radius` (0). Urgency shows as the border color: `theme.urgent` for critical, `theme.muted` otherwise.

## 4. Signals and actions

The `notification` global is a class like `client` and `tag`:

| Signal | Payload | Fires |
|---|---|---|
| `added` | none | before the notification is first shown |
| `dismissed` | reason string | when it ends, however it ends |
| `invoked` | action key | when an action button is pressed |
| `property::<name>` | new value | on any property write |

`added` fires before the first frame that draws the notification, so mutating it there is a rule system in a few lines:

```lua
notification.on("added", function(n)
	if n.app_name == "spotify" then
		n.timeout = 2
	end
end)
```

Live properties really are live: writing `n.timeout` re-arms the expiry, and writing `n.title`, `n.message`, `n.urgency`, `n.icon`, or `n.actions` redraws.

Actions are invoked with `n:invoke(key)`; the stock display wires each action button's press to exactly that. Invoking reports the action back to the sending app (for a notification that arrived over DBus) and dismisses the notification.

Do-not-disturb is one flag: `notification.suspended = true` queues arrivals instead of showing them; setting it back to `false` shows the queue in arrival order. `notification.pending` is the read-only queue.

```lua
some.key {
	mods = { "mod", "shift" }, key = "d",
	desc = "toggle do-not-disturb", group = "system",
	press = function()
		notification.suspended = not notification.suspended
	end,
}
```

## 5. Replace the display wholesale

The entire presentation is one replaceable function: `some.defaults.notify_display(s)` runs inside every screen's frame and declares whatever the notifications should look like. Assign your own, or set it to `nil` to render nothing at all (signals still fire, so a `nil` display plus your own listeners is a valid setup).

A minimal custom display, bottom-right instead of top-right:

```lua
local some = require("somewm")
local ui = some.ui

some.defaults.notify_display = function(s)
	local list = notification.all()
	if #list == 0 then
		return
	end
	local th = some.theme
	ui.column({
		id = "notifications",
		float = {
			to = "root", band = "overlay",
			anchor = { parent = "right_bottom", element = "right_bottom" },
			offset = { x = -12, y = -12 },
		},
		gap = 8,
	}, function()
		for _, n in ipairs(list) do
			ui.column({
				id = "notif:" .. n.seq,
				w = 300, color = th.bg, radius = 6, pad = 10, gap = 4,
				border = { width = 1,
					color = n.urgency == "critical" and th.urgent or th.muted },
				on_press = function() n:dismiss() end,
			}, function()
				if n.title ~= nil then
					ui.text(n.title)
				end
				if n.message ~= nil then
					ui.text(n.message, { size = 12 })
				end
			end)
		end
	end)
end
```

Every notification carries a `seq` field, a unique sequence number, which makes a stable element id. Press-to-dismiss is just an `on_press`; add action buttons as inner boxes calling `n:invoke(a.key)`, or a progress bar from `n.value`, exactly as the stock display does. The stock version is itself written in this same public API, so it is a good template for a fuller replacement.

## See also

- [Replacing Default Policies](/kiln/guides/replace-default-policies)
- [Notification reference](/kiln/reference/notification)
- [Theme variables](/kiln/reference/theme-variables)
- [UI reference](/kiln/reference/ui)
