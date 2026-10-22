---
sidebar_position: 1
title: Basics
description: The default desktop, the keybindings for windows, tags and layouts, and your first config edit and reload.
---

# Basics

You need a running SomeWM session ([Launch](../getting-started/first-launch.md)) or a nested one in a window ([Try SomeWM without logging out](try-somewm-without-installing.md)), and a terminal. The default config uses `foot`.

## The desktop

The bar at the top is the wibar. Left to right:

| Part | What it is |
| --- | --- |
| launcher icon | opens the main menu |
| taglist | the five tags `dev`, `web`, `chat`, `files`, `media`; click to switch |
| prompt area | where Mod4 + r's run prompt appears |
| tasklist | the windows on the current tag |
| clock | centred over the bar |
| systray | app indicators |
| layout icon | the current layout; rightmost |

A window can belong to several tags, and a screen can display several tags at once.

## Windows

Mod4 is the Super key. Press Mod4 + Return for a terminal; it fills the screen. Press it twice more: the first window keeps the left half, the master area, and the others stack on the right ([Master and Stack](../concepts/master-and-stack.md)).

| Keys | Action |
| --- | --- |
| Mod4 + j, Mod4 + k | focus next, previous |
| Mod4 + Tab | last focused |
| Mod4 + Shift + c | close; the others re-tile at once |
| Mod4 + r | run prompt in the bar: type `firefox`, press Enter |
| Mod4 + s | every keybinding; any key dismisses it |

## Tags

The number keys address tags by position: Mod4 + 1 is `dev`, Mod4 + 2 is `web`.

| Keys | Action |
| --- | --- |
| Mod4 + 1 to 5 | view that tag |
| Mod4 + Left, Right | previous, next tag |
| Mod4 + Shift + 1 to 5 | move the focused window to that tag |
| Mod4 + Ctrl + 1 to 5 | also view that tag |

Open a terminal on `dev`, press Mod4 + 2, and open another on `web`. Return with Mod4 + 1.

With the first terminal focused, Mod4 + Shift + 3 moves it to `chat`; Mod4 + 3 shows it.

Return to `dev` and press Mod4 + Ctrl + 2 to view `dev` and `web` together. Both tags are highlighted. Press the same keys again to hide `web`.

## Layouts

| Keys | Action |
| --- | --- |
| Mod4 + Space, Mod4 + Shift + Space | next, previous layout |
| Mod4 + l, Mod4 + h | master wider, narrower (tile, spiral, dwindle) |

| Layout | Arrangement |
| --- | --- |
| tile | master left, stack right |
| fair | equal sizes |
| max | the focused window fills the screen |
| floating | overlapping windows |

## Mouse

| Action | Effect |
| --- | --- |
| click a tag | view it |
| scroll on the taglist | cycle tags |
| Mod4 + left drag | move a window; a tiled one starts floating |
| Mod4 + right drag | resize |
| right-click the desktop | main menu |

## Your first edit

Copy the bundled config to `~/.config/somewm/rc.lua`:

```bash
mkdir -p ~/.config/somewm
cp /etc/xdg/somewm/rc.lua ~/.config/somewm/rc.lua
```

Near the top of the file:

```lua
local terminal = "foot"
```

Change it to `"alacritty"`, `"kitty"` or whatever you have. Save, press Mod4 + Ctrl + r to reload, then Mod4 + Return. Your terminal opens. The reload rebuilt the bar and the Lua state; your windows stayed where they were.

A broken config falls through to alternate configs; if none loads, the log reports a fatal error. The usual causes are a missing comma, a mismatched bracket, or a misspelled name.

## Next

- [Theme](theme.md): colours, fonts and gaps
- [Keybindings](keybindings.md): your own shortcuts
- [Widgets](widgets.md): a widget in the bar
- [Default Keybindings](../reference/default-keybindings.md): the complete list
