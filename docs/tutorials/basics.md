---
sidebar_position: 1
title: Basics
description: The default desktop, the keybindings for windows, tags and layouts, and your first config edit and reload.
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Basics

<YouWillLearn>

- How to read the default desktop
- The keybindings for windows, tags and layouts
- How to edit and reload `rc.lua`

</YouWillLearn>

You need a running SomeWM session ([Launch](/docs/getting-started/first-launch)) or a nested one in a window ([Try SomeWM without logging out](/docs/tutorials/try-somewm-without-installing)), and a terminal. The default config uses `foot`.

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

A tag is a label on a window, not a container: a window can carry several, and a screen can show several at once.

## Windows

Mod4 is the Super key. Press Mod4 + Return for a terminal; it fills the screen. Press it twice more: the first window keeps the left half, the master area, and the others stack on the right ([Master and Stack](/docs/concepts/master-and-stack)).

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

Try it: open a terminal, Mod4 + 2, open another, Mod4 + 1. The first is still there. With it focused, Mod4 + Shift + 3 moves it to `chat`; Mod4 + 3 shows it alone. Mod4 + Ctrl + 2 from `dev` tiles both tags' windows together and highlights both tags; the same keys again go back.

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

SomeWM loads `~/.config/somewm/rc.lua`, then `~/.config/awesome/rc.lua`, then the bundled default. Start from the default:

```bash
mkdir -p ~/.config/somewm
cp /etc/xdg/somewm/rc.lua ~/.config/somewm/rc.lua
```

Near the top of the file:

```lua
local terminal = "foot"
```

Change it to `"alacritty"`, `"kitty"` or whatever you have. Save, press Mod4 + Ctrl + r to reload, then Mod4 + Return. Your terminal opens. The reload rebuilt the bar and the Lua state; your windows stayed where they were.

A config with an error shows a notification with the line number and keeps the previous config running. The usual causes are a missing comma, a mismatched bracket, or a misspelled name.

## Next

- [Theme](/docs/tutorials/theme): colours, fonts and gaps
- [Keybindings](/docs/tutorials/keybindings): your own shortcuts
- [Widgets](/docs/tutorials/widgets): a widget in the bar
- [Default Keybindings](/docs/reference/default-keybindings): the complete list
