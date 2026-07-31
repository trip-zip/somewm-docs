---
title: Basics
description: "A first hands-on session: run kiln nested, tile some terminals, switch layouts and tags, float a window, and reload an edited config."
sidebar_position: 1
---

# Basics

kiln runs nested inside your existing session as an ordinary window. Nothing
below needs a spare machine or a logout: you tile, retag, float, and reload
against a live compositor running on the desktop you are already using.

## Prerequisites

A built kiln (see [Installation](/kiln/getting-started/installation)) and an
existing Wayland or X session to nest inside. All chords below are the default
`rc.lua`'s; the modkey is `super`.

## 1. Start a nested session

From the source tree:

```bash
make run
```

kiln detects it is inside a session and opens as a window. Click into it so it
has your keyboard. You should see the stock desktop: a top bar with five tags,
the generated wallpaper, and an empty workarea.

:::tip
If you already run kiln as your real session, start a second instance with
`make dev` instead. It gets its own IPC socket and log, so it cannot
interfere with the live one.
:::

## 2. Open some terminals

Press `mod+Return` a few times. Each press spawns `$TERMINAL` (falling back to
foot). Watch the tile layout react: the first client fills the workarea,
the second splits it into master and stack, further ones stack on the right.

Focus moves with the mouse, `mod+j` and `mod+k` walk the clients by index,
and `mod+Tab` jumps back to the previously focused client. Close one with
`mod+shift+c`.

## 3. Switch layouts

The layout belongs to the current tag. Three ways to change it:

- `mod+space` cycles to the next layout (`mod+shift+space` goes back)
- `mod+KP_1` .. `mod+KP_9` jump straight to a slot in the cycle
- click the layout icon in the bar (right of the system tray)

The shipped cycle starts with the tile family (`tile`, `tile.left`,
`tile.bottom`, `tile.top`), then walks `carousel`, `fair`, `max`, and the
rest; watch the same clients reflow as you go. `mod+h` and `mod+l` resize the
master area within the tile layouts. See the
[layout reference](/kiln/reference/layout) for what each one does.

## 4. Use tags

The stock config makes five tags per screen: `dev`, `web`, `chat`, `files`,
`media`.

1. Press `mod+2` to view the second tag. The workarea empties: your terminals
   live on tag 1.
2. Press `mod+Return` to open a terminal here, then `mod+1` and `mod+2` to
   flip between the two populated tags (`mod+Escape` also jumps back).
3. Focus a client and press `mod+shift+1` to move it to tag 1.

A tag is a named group of clients with its own layout; a screen shows its
selected tags. That is the whole model.

## 5. Float a window

Press `mod+ctrl+space` on a focused client. It pops out of the tiled order
into a floating box; the remaining tiles reflow behind it.

- Hold `mod` and drag with the left button to move it.
- Hold `mod` and drag with the right button to resize from the nearest corner.
- Drag its edges directly: floating clients grow invisible resize handles.
- `mod+ctrl+space` again re-tiles it.

Related states: `mod+f` fullscreen, `mod+m` maximize, `mod+n` minimize
(restore with `mod+ctrl+n` or by clicking its tasklist entry in the bar).

## 6. Edit your config and reload

Make the config yours, if you have not yet:

```bash
mkdir -p ~/.config/kiln && cp kilnrc.lua ~/.config/kiln/rc.lua
```

Open it and change something visible, say the accent color (put the line
after the palette block near the top, so the palette does not overwrite it):

```lua
th.accent = "#e0af68"
```

Now press `mod+ctrl+r`. The bar and focus ring change color in place: reload
re-runs your config inside the running session. Clients survive; bindings,
rules, bars, and theme are rebuilt from the new file. If the edited config
has an error, kiln stays up and reports it as a critical notification instead
of dying.

Every kiln also exposes a live Lua socket, so the same reload works from any
terminal, key or no key:

```bash
scripts/kiln-eval 'require("kiln").reload()'
```

(The socket cannot see your rc's `kiln` local; `require("kiln")` returns the
same module.) More on reload semantics and debugging a broken config in
[Reload and debugging](/kiln/guides/reload-and-debugging).

## 7. Quit

`mod+shift+q` ends the session.

## See also

- [Keybindings tutorial](/kiln/tutorials/keybindings)
- [Keybindings and rules reference](/kiln/reference/keybindings-and-rules)
- [IPC and scripting](/kiln/guides/ipc-and-scripting)
