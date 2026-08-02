---
title: Keybindings
description: "Teach kiln.key from scratch: chords and the modkey, press and release, descriptions for the hotkeys popup, ranges, and mouse bindings."
sidebar_position: 2
---

# Keybindings

`kiln.key{}` is how input reaches your config. One call registers one chord,
and the same call carries the description that the hotkeys popup reads back.

## Prerequisites

A running kiln and a config you can edit (see
[Basics](/kiln/tutorials/basics)). Snippets assume the usual header:

```lua
local kiln = require("kiln")
local key, button = kiln.key, kiln.button
```

## 1. Your first binding

```lua
key { mods = { "mod" }, key = "d",
	press = function() kiln.spawn("fuzzel") end }
```

One call, one chord. `mods` is a list of modifier names, `key` is the key
name, `press` runs on the press edge. Reload (or paste this through
`scripts/kiln-eval`) and `mod+d` spawns a launcher.

Bound chords are consumed by the compositor: the press never reaches the
focused client, so a binding cannot half-leak into a terminal.

## 2. Mods and kiln.modkey

Modifier names are `ctrl`, `alt`, `shift`, `super`. The special name `"mod"`
resolves through `kiln.modkey` at bind time, so the whole config retargets
with one line:

```lua
kiln.modkey = "super"
```

Set it before your `key{}` calls. Matching is exact: `{ "mod" }` does not fire
while shift is also held, so `{ "mod" }` and `{ "mod", "shift" }` on the same
key are two distinct bindings.

## 3. Press and release

Both handlers are optional and independent:

```lua
key { mods = { "mod" }, key = "v",
	press = function() kiln.spawn("pactl set-source-mute @DEFAULT_SOURCE@ 0") end,
	release = function() kiln.spawn("pactl set-source-mute @DEFAULT_SOURCE@ 1") end }
```

A push-to-talk key: reload, hold `mod+v`, and the mic is live for exactly as
long as the key is down. A release-only binding works too; the chord is still
consumed on the press edge so the release reliably arrives.

## 4. desc and group: the hotkeys popup

```lua
key { mods = { "mod" }, key = "d", desc = "app launcher", group = "launch",
	press = function() kiln.spawn("fuzzel") end }
```

`desc` and `group` change nothing about dispatch. They are recorded in the
binding registry, which `kiln.key.all()` returns, and the default config's
`mod+s` cheat sheet is built entirely from that registry.

Reload, then press `mod+s`. Your binding is on the sheet: a **launch** group
with an "app launcher" row, next to everything the default config declared.
Press `mod+s` again to dismiss it. Every binding you annotate documents
itself this way. The popup ships in the stdlib (`kiln.hotkeys`), and the
same registry powers a custom one; see the
[hotkeys popup guide](/kiln/guides/hotkeys-popup).

## 5. Ranges

A key of the form `"1-9"` or `"a-z"` expands into one binding per value, and
the handler receives the value: digits arrive as numbers, letters as letters.

```lua
key { mods = { "mod" }, key = "1-9", desc = "view tag", group = "tag",
	press = function(i)
		local t = screen.focused.tags[i]
		if t then t:view() end
	end }

key { mods = { "mod", "ctrl" }, key = "a-z", desc = "mark", group = "demo",
	press = function(letter)
		kiln.notify { title = "pressed", message = letter }
	end }
```

Reload and press `mod+ctrl+m`. A notification pops up with the letter you
pressed; try a few others and the message follows the key. The registry keeps
each range as one entry, so the cheat sheet shows a single `1-9  view tag`
row instead of nine.

## 6. Client verbs with kiln.focused

Handlers that act on "the focused client" all need the same guard. `kiln.focused(fn)`
wraps a function to run with `client.focus` as its first argument, and to do
nothing when no client is focused:

```lua
key { mods = { "mod" }, key = "q", desc = "close client", group = "client",
	press = kiln.focused(function(c) c:close() end) }
key { mods = { "mod" }, key = "f", desc = "fullscreen", group = "client",
	press = kiln.focused(function(c) c:toggle_fullscreen() end) }
```

Reload, focus a window, and press `mod+f`: it fills the screen; again and it
tiles back. Press `mod+q` on an empty tag and nothing happens, quietly: that
is the guard doing its job, not an error being swallowed.

:::warning
`c:close()` is the polite close (the client is asked to quit). `c:kill()`
sends SIGKILL. This is the opposite of AwesomeWM, where `c:kill()` is the
polite one.
:::

## 7. Mouse bindings

`kiln.button{}` is the same shape with a button number instead of a key, plus
an `on` field naming where the press must land: `"client"` (the default) for
presses on a client surface, `"root"` for presses on empty workarea. The
handler receives the client (or nil on the root).

```lua
button { mods = { "mod" }, button = 1, press = function(c) c:grab_move() end }
button { mods = { "mod" }, button = 3,
	press = function(c) c:grab_resize_nearest() end }

button { mods = {}, button = 2, on = "root",
	press = function() kiln.spawn(os.getenv("TERMINAL") or "foot") end }
```

The first two are the default config's move and resize drags: hold `mod` and
drag with the left button and the window follows the pointer; drag with the
right button and it resizes from whichever corner is nearest. Buttons: 1
left, 2 middle, 3 right. A plain unbound click on a client simply focuses it.
Presses on bar cells are handled by the cells' own `on_press` handlers, not
by `button{}`; see the [bar tutorial](/kiln/tutorials/a-bar-from-scratch).

## 8. Clearing and re-registering

`kiln.key.clear()` drops every key binding, `kiln.button.clear()` every mouse
binding. `kiln.reload()` calls both before re-running your config, which is
why editing the file and reloading never duplicates anything.

Re-running a `key{}` call over IPC is safe: rebinding a chord replaces its
registry row in place, so the cheat sheet never shows duplicates. Still,

```bash
scripts/kiln-eval 'require("kiln").reload()'
```

is the cleanest way to apply binding edits from a file. (`require("kiln")`
returns the same module your rc holds as `kiln`; the local itself is not
visible to the socket.)

## Complete example

```lua
local kiln = require("kiln")
local key, button = kiln.key, kiln.button

kiln.modkey = "super"

key { mods = { "mod" }, key = "Return", desc = "terminal", group = "launch",
	press = function() kiln.spawn(os.getenv("TERMINAL") or "foot") end }
key { mods = { "mod" }, key = "d", desc = "app launcher", group = "launch",
	press = function() kiln.spawn("fuzzel") end }

key { mods = { "mod" }, key = "q", desc = "close", group = "client",
	press = kiln.focused(function(c) c:close() end) }
key { mods = { "mod" }, key = "space", desc = "toggle floating", group = "client",
	press = kiln.focused(function(c) c.floating = not c.floating end) }

key { mods = { "mod" }, key = "1-9", desc = "view tag", group = "tag",
	press = function(i)
		local t = screen.focused.tags[i]
		if t then t:view() end
	end }
key { mods = { "mod", "shift" }, key = "1-9", desc = "move to tag", group = "tag",
	press = kiln.focused(function(c, i)
		local t = screen.focused.tags[i]
		if t then c.tags = { t } end
	end) }

key { mods = { "mod" }, key = "Escape", desc = "quit", group = "system",
	press = kiln.quit }

button { mods = { "mod" }, button = 1, press = function(c) c:grab_move() end }
button { mods = { "mod" }, button = 3,
	press = function(c) c:grab_resize_nearest() end }
```

## See also

- [Hotkeys popup guide](/kiln/guides/hotkeys-popup)
- [Keybindings and rules reference](/kiln/reference/keybindings-and-rules)
- [Basics tutorial](/kiln/tutorials/basics)
