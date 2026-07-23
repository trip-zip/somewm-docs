---
title: Replacing Default Policies
description: Swap any of kiln's ten stock behaviors, from focus succession to fullscreen handling, with your own function.
sidebar_position: 6
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Replacing Default Policies

<YouWillLearn>

- The `some.defaults` model: ten policies, each one plain function
- The two replacement patterns: reassign the field, or swap the listener
- Three worked replacements: focus succession, focus stealing, and fake fullscreen

</YouWillLearn>

Everything kiln decides on your behalf is a function in `some.defaults`, and every one of them is replaceable wholesale. There is no hook registry and no permission system: you write a function with the same signature and put it where the old one was.

## 1. The ten policies

| Policy | Signature | Decides |
|---|---|---|
| `successor` | `(gone) -> client or nil` | who gets focus when the focused client goes away |
| `activate` | `(c, ctx)` | what a client's request to be focused does |
| `layer` | `(l)` | how a layer-shell surface (bars, launchers) is sized and answered |
| `layer_keyboard` | `(l)` | whether a layer surface gets the keyboard |
| `layer_release` | `(l)` | cleanup when a layer surface goes away |
| `notify_display` | `(s)` | the entire notification UI |
| `fullscreen` | `(c, on)` | what a fullscreen request does |
| `maximize` | `(c, on)` | what a maximize request does |
| `minimize` | `(c, on)` | what a minimize request does |
| `close` | `(c)` | what an external close request (a taskbar button) does |

Stock behavior, briefly: `successor` picks the most recently focused living client visible on the same screen. `activate` focuses a user-initiated request (one backed by a valid activation token) and marks anything else urgent. The `layer` trio implements standard layer-shell sizing and keyboard rules. `notify_display` is the stacked top-right popup UI. The four request policies simply honor the ask: `fullscreen`/`maximize`/`minimize` write the matching client property, `close` calls `c:close()`.

## 2. The two replacement patterns

The general recipe is always: understand what the stock function does (the table above, plus the relevant reference page), write your own with the same signature, install it. How you install it depends on how the policy is invoked.

**Called through the table.** `successor` and `notify_display` are looked up on `some.defaults` at call time, so replacing them is one assignment:

```lua
some.defaults.successor = function(gone)
	-- return a client, or nil to clear focus
end
```

**Connected to a signal.** `activate`, `fullscreen`, `maximize`, `minimize`, `close`, and the `layer` trio are registered as signal listeners at boot. Assigning the table field does not touch the listener that is already on the bus, so swap it there:

```lua
client.off("request::fullscreen", some.defaults.fullscreen)
client.on("request::fullscreen", my_fullscreen)
```

The same off/on pair works for each: `request::activate`, `request::maximize`, `request::minimize`, and `request::close` on `client`, and `map`/`commit`/`unmap`/`destroy` on `layer` for the layer policies. Taking a handler off the bus and connecting nothing is also legal: that is how you refuse a request outright, since nothing else acts on it.

Config reload restores the stock listeners and then re-runs your config file, so replacements declared in the config survive reloads automatically.

## 3. Worked example: focus succession

The stock successor walks the global focus history. Suppose you want succession to stay local: prefer the most recent client sharing a tag with the departed one, and only then fall back to anything visible on the screen.

```lua
local function shares_tag(a, b)
	for _, t in ipairs(a.tags or {}) do
		for _, t2 in ipairs(b.tags or {}) do
			if t == t2 then
				return true
			end
		end
	end
	return false
end

some.defaults.successor = function(gone)
	local s = gone.screen
	if s == nil then
		return nil
	end
	local fallback = nil
	for _, c in ipairs(client.history()) do
		if c ~= gone and c.mapped and not c.minimized
				and c.screen == s then
			if shares_tag(c, gone) then
				return c
			end
			fallback = fallback or c
		end
	end
	return fallback
end
```

`client.history()` is a read-only copy of the runtime's most-recent-first focus list, so a custom successor never has to maintain its own bookkeeping. Returning `nil` clears focus.

## 4. Worked example: strict focus stealing

The stock `activate` marks non-user-initiated requests urgent. To deny background apps any effect at all, honoring only requests backed by a real activation token (for example a window you launched with `some.spawn_with_token`):

```lua
client.off("request::activate", some.defaults.activate)
client.on("request::activate", function(c, ctx)
	if ctx.valid then
		c:focus()
	end
	-- Invalid asks: no focus, no urgent flag, nothing.
end)
```

`ctx.valid` is true when the request carries a seat-backed activation token; `ctx.app_id` names who asked, if you want to allowlist specific apps instead.

## 5. Worked example: fake fullscreen

Some apps insist on fullscreening themselves (video players on double-click). This replacement tells the client it is fullscreen, so it hides its own chrome and plays full-surface, but keeps it exactly where the layout put it:

```lua
client.off("request::fullscreen", some.defaults.fullscreen)
client.on("request::fullscreen", function(c, on)
	-- Mirror the state to the client so it draws itself fullscreen,
	-- but never set c.fullscreen: the layout keeps tiling it.
	core.client.set_fullscreen_hint(c.handle, on and true or false)
	c.titlebar = not on
end)
```

`core.client.set_fullscreen_hint` is the low-level verb the stock property listener uses; here it is applied without the band promotion that real fullscreen gets. Hiding the titlebar while "fullscreen" keeps the illusion tidy. Your own `mod+f` binding can still use `c:toggle_fullscreen()` for genuine fullscreen, since that writes the property directly rather than raising a request.

:::tip
This split is the general shape of request policy: the client's ask arrives as a `request::*` signal, your handler decides, and the property write (or its absence) is the whole outcome. A handler that does nothing is a veto.
:::

## See also

- [Defaults reference](/kiln/reference/defaults)
- [Notifications](/kiln/guides/notifications) (replacing `notify_display`)
- [Signals reference](/kiln/reference/signals)
- [The object model](/kiln/concepts/object-model)
