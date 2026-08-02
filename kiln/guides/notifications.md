---
title: Notifications
description: Receive desktop notifications, raise your own, tune timeouts and urgency, and replace the whole display.
sidebar_position: 6
---

# Notifications

Desktop notifications arrive over DBus and are drawn by the compositor itself. Nothing needs installing, the popups take their colors from the theme table, and the entire display is one policy function you can replace.

## 1. kiln is the notification daemon

kiln implements the freedesktop notification service (`org.freedesktop.Notifications`) itself: `notify-send`, browsers, chat apps, and volume scripts deliver straight to the compositor, which draws the popups as part of its own scene. Do not run mako, dunst, or another daemon alongside; they would compete for the same DBus name. The service advertises `body`, `actions`, and `icon-static` capabilities.

There is nothing to enable. A DBus session must exist (the standard `make run` line launches kiln under `dbus-run-session`), and notifications appear stacked at the top-right, colored by urgency.

## 2. Raise your own

`kiln.notify{}` creates a notification from config code; the same constructor the DBus intake uses:

```lua
kiln.notify {
	title = "Battery",
	message = "15% remaining",
	urgency = "critical",
}
```

It returns the notification object. The [notification reference](/kiln/reference/notification) lists every accepted field; the one worth knowing by heart is `id`, whose update-in-place behavior is what makes a volume popup one repeated call rather than a stack of popups.

Critical notifications never expire on their own: dismissing them is the user's (or your code's) job. `n:dismiss()` is the one way any notification ends; `notification.all()` lists the currently visible ones.

## 3. Tune timeouts per urgency

When `timeout` is not given, the per-urgency default from the theme applies:

```lua
kiln.theme.notification_timeout = { low = 3, normal = 5, critical = 0 }
```

The display's size, insets, stacking gap, corner radius, and urgency border colors are all `notification_*` [theme variables](/kiln/reference/theme-variables).

## 4. React to notifications: rules, actions, do-not-disturb

The `notification` global is a class like `client` and `tag`; its four signals are in the [signals reference](/kiln/reference/signals). The one that carries most weight here is `added`: it fires before the first frame that draws the notification, so mutating it there is a rule system in a few lines:

```lua
notification.on("added", function(n)
	if n.app_name == "spotify" then
		n.timeout = 2
	end
end)
```

Live properties really are live: writing `n.timeout` re-arms the expiry, and writing the text or icon redraws. Actions are invoked with `n:invoke(key)`; the stock display wires each action button's press to exactly that.

Do-not-disturb is one flag: `notification.suspended = true` queues arrivals instead of showing them; setting it back to `false` shows the queue in arrival order. `notification.pending` is the read-only queue.

```lua
kiln.key {
	mods = { "mod", "shift" }, key = "d",
	desc = "toggle do-not-disturb", group = "system",
	press = function()
		notification.suspended = not notification.suspended
	end,
}
```

## 5. Replace the display wholesale

The entire presentation is one replaceable function: `kiln.defaults.notify_display(s)` runs inside every screen's frame and declares whatever the notifications should look like. Assign your own, or set it to `nil` to render nothing at all (signals still fire, so a `nil` display plus your own listeners is a valid setup).

A minimal custom display, bottom-right instead of top-right:

```lua
local kiln = require("kiln")
local ui = kiln.ui

kiln.defaults.notify_display = function(s)
	local list = notification.all()
	if #list == 0 then
		return
	end
	local th = kiln.theme
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
