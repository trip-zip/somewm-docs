---
title: Basics
description: "A first hands-on session: run kiln nested, tile some terminals, switch layouts and tags, float a window, and reload an edited config."
sidebar_position: 1
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Basics

<YouWillLearn>

- Running kiln as a nested window inside your current session
- Opening clients and watching the tiled layout react
- Switching layouts and moving between tags
- Floating, moving, and resizing a window with the mouse
- Editing your config and reloading it without restarting

</YouWillLearn>

## Prerequisites

A built kiln (see [Installation](/kiln/getting-started/installation)) and an
existing Wayland or X session to nest inside. All chords below are the default
`rc.lua`'s; the modkey is `alt`.

## 1. Start a nested session

From the source tree:

```bash
make run
```

kiln detects it is inside a session and opens as a window. Click into it so it
has your keyboard. You should see the stock desktop: a top bar with four tags,
and an empty workarea.

:::tip
If you already run kiln as your real session, start a second instance with
`make dev` instead. It gets its own IPC socket and log, so it cannot
interfere with the live one.
:::

## 2. Open some terminals

Press `alt+Return` a few times. Each press spawns `$TERMINAL` (falling back to
ghostty). Watch the tile layout react: the first client fills the workarea,
the second splits it into master and stack, further ones stack on the right.

Focus moves with the mouse, and `alt+Tab` jumps back to the previously
focused client. Close one with `alt+q`.

## 3. Switch layouts

The layout belongs to the current tag. Three ways to change it:

- `alt+period` cycles to the next layout
- `alt+comma` opens a layout picker menu
- click the layout name in the bar (next to the taglist)

Cycle through `tile`, `fair`, `spiral`, and the rest and watch the same
clients reflow. See the [layout reference](/kiln/reference/layout) for what
each one does.

## 4. Use tags

The stock config makes four tags per screen: `term`, `web`, `chat`, `media`.

1. Press `alt+2` to view the second tag. The workarea empties: your terminals
   live on tag 1.
2. Press `alt+Return` to open a terminal here, then `alt+1` and `alt+2` to
   flip between the two populated tags.
3. Focus a client and press `alt+shift+1` to move it to tag 1.

A tag is a named group of clients with its own layout; a screen shows its
selected tags. That is the whole model.

## 5. Float a window

Press `alt+space` on a focused client. It pops out of the tiled order into a
floating box; the remaining tiles reflow behind it.

- Hold `alt` and drag with the left button to move it.
- Hold `alt` and drag with the right button to resize from the nearest corner.
- Drag its edges directly: floating clients grow invisible resize handles.
- `alt+space` again re-tiles it.

Related states: `alt+f` fullscreen, `alt+m` maximize, `alt+n` minimize
(restore by clicking its tasklist entry in the bar).

## 6. Edit your config and reload

Make the config yours, if you have not yet:

```bash
mkdir -p ~/.config/kiln && cp rc.lua ~/.config/kiln/rc.lua
```

Open it and change something visible, say the accent color near the top:

```lua
th.accent = "#e0af68"
```

Now reload the running compositor. The default rc does not bind a reload key,
but every kiln exposes a live Lua socket, so from any terminal:

```bash
scripts/kiln-eval 'require("somewm").reload()'
```

(The socket cannot see your rc's `some` local; `require("somewm")` returns the
same module.) The bar and focus ring change color in place: reload re-runs your
config inside the running session. Clients survive; bindings, rules, bars,
and theme are rebuilt from the new file. If the edited config has an error,
kiln stays up and reports it instead of dying.

If you prefer a key for it, add one:

```lua
key { mods = { "mod", "shift" }, key = "r", desc = "reload config",
	group = "system", press = some.reload }
```

(You will need one last `kiln-eval 'require("somewm").reload()'` to load that
binding.)
More on reload semantics and debugging a broken config in
[Reload and debugging](/kiln/guides/reload-and-debugging).

## 7. Quit

`alt+Escape` ends the session.

## See also

- [Keybindings tutorial](/kiln/tutorials/keybindings)
- [Keybindings and rules reference](/kiln/reference/keybindings-and-rules)
- [IPC and scripting](/kiln/guides/ipc-and-scripting)
