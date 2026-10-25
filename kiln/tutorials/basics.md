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
existing Wayland session to nest inside. All chords below are the default
`rc.lua`'s; the modkey is `super`.

## 1. Start a nested session

From the source tree:

```bash
kiln_demo=$(mktemp -d /tmp/kiln-demo.XXXXXX)
cp kilnrc.lua "$kiln_demo/rc.lua"
printf 'Trial config: %s/rc.lua\n' "$kiln_demo"
KILN_RC="$kiln_demo/rc.lua" KILN_SOCK="$kiln_demo/eval.sock" \
  dbus-run-session -- ./build/kiln
```

Because `WAYLAND_DISPLAY` is set, kiln uses its nested backend and opens as a
window titled `kiln`. Click into it so it
has your keyboard. You should see the stock desktop: a top bar with five tags,
the generated wallpaper, and an empty workarea.

This session has its own IPC socket and config copy. Keep the trial directory
path for edits and commands from a second terminal. Your normal config is not
used by this tutorial.

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
selected tags.

## 5. Float a window

Press `mod+ctrl+space` on a focused client. It pops out of the tiled order
into a floating box; the remaining tiles reflow behind it.

- Hold `mod` and drag with the left button to move it.
- Hold `mod` and drag with the right button to resize from the nearest corner.
- Drag its edges directly: floating clients have invisible 6 px resize
  handles on every edge and corner.
- `mod+ctrl+space` again re-tiles it.

Related states: `mod+f` fullscreen, `mod+m` maximize, `mod+n` minimize
(restore with `mod+ctrl+n` or by clicking its tasklist entry in the bar).

## 6. Edit your config and reload

Open the `rc.lua` path printed at startup in an editor.

Change something visible, say the accent color (put the line
after the palette block near the top, so the palette does not overwrite it):

```lua
th.accent = "#e0af68"
```

Now press `mod+ctrl+r`. The launcher square, the selected tag, the focused
task and the focused window's border change color: reload re-runs your config
inside the running session. Clients survive. Tags, bindings, rules and bars
are rebuilt from the file. Theme keys you stop setting keep their last value
until kiln restarts. If the edited config
has an error, kiln stays up and reports it as a critical notification instead
of dying.

Every kiln also exposes a live Lua socket, so the same reload works from any
terminal, key or no key:

```bash
KILN_SOCK="<trial dir>/eval.sock" ./build/kiln-client eval 'require("kiln").reload()'
```

Over the socket, use `require("kiln")`, as
[IPC and scripting](/kiln/guides/ipc-and-scripting) explains. More on reload semantics and debugging a broken config in
[Reload and debugging](/kiln/guides/reload-and-debugging).

## 7. Quit

`mod+shift+q` ends the session.

## See also

- [Keybindings tutorial](/kiln/tutorials/keybindings)
- [Keybindings and rules reference](/kiln/reference/keybindings-and-rules)
- [IPC and scripting](/kiln/guides/ipc-and-scripting)
