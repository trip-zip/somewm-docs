---
sidebar_position: 3
title: Default Keybindings
description: Complete list of default keyboard shortcuts
---

# Default Keybindings

All keybindings use **Mod4** (Super/Windows key) as the primary modifier.

Source: `somewmrc.lua` in the SomeWM repository. Last synced: `6de5e1ef3`. Press `Mod4 + s` in a running session for the live list.

## Launcher

| Keybinding | Action |
|------------|--------|
| `Mod4 + Return` | Open terminal |
| `Mod4 + r` | Run prompt |
| `Mod4 + x` | Lua execute prompt |
| `Mod4 + p` | Show menubar |
| `Mod4 + w` | Show main menu |
| `Mod4 + s` | Show keybinding help |

## Window Focus

| Keybinding | Action |
|------------|--------|
| `Mod4 + j` | Focus next client |
| `Mod4 + k` | Focus previous client |
| `Mod4 + u` | Focus urgent client |
| `Mod4 + Tab` | Focus previous client (history) |

## Window Movement

| Keybinding | Action |
|------------|--------|
| `Mod4 + Shift + j` | Swap with next client |
| `Mod4 + Shift + k` | Swap with previous client |
| `Mod4 + Ctrl + Return` | Move to master |

## Layout

| Keybinding | Action |
|------------|--------|
| `Mod4 + Space` | Next layout |
| `Mod4 + Shift + Space` | Previous layout |
| `Mod4 + h` | Decrease master width |
| `Mod4 + l` | Increase master width |
| `Mod4 + Shift + h` | Increase master count |
| `Mod4 + Shift + l` | Decrease master count |
| `Mod4 + Ctrl + h` | Increase columns |
| `Mod4 + Ctrl + l` | Decrease columns |

## Tags

| Keybinding | Action |
|------------|--------|
| `Mod4 + 1-9` | View tag 1-9 |
| `Mod4 + Shift + 1-9` | Move client to tag 1-9 |
| `Mod4 + Ctrl + 1-9` | Toggle tag view |
| `Mod4 + Ctrl + Shift + 1-9` | Toggle client on tag |
| `Mod4 + Left/Right` | View previous/next tag |
| `Mod4 + Escape` | Go back to previous tag |
| `Mod4 + Shift + r` | Rename current tag |

## Screens

| Keybinding | Action |
|------------|--------|
| `Mod4 + Ctrl + j` | Focus next screen |
| `Mod4 + Ctrl + k` | Focus previous screen |
| `Mod4 + o` | Move client to next screen |

## Client Actions

| Keybinding | Action |
|------------|--------|
| `Mod4 + Shift + c` | Close client |
| `Mod4 + f` | Toggle fullscreen |
| `Mod4 + m` | Toggle maximize |
| `Mod4 + Ctrl + m` | Toggle maximize vertically |
| `Mod4 + Shift + m` | Toggle maximize horizontally |
| `Mod4 + n` | Minimize |
| `Mod4 + Ctrl + n` | Restore minimized |
| `Mod4 + Ctrl + Space` | Toggle floating |
| `Mod4 + t` | Toggle keep on top |
| `Mod4 + ,` | Toggle sticky (show on all tags) |

## Screenshots

| Keybinding | Action |
|------------|--------|
| `Print` | Screenshot full output |
| `Shift + Print` | Screenshot region |
| `Mod4 + Ctrl + p` | Interactive screenshot (region/window) |

## Media Keys

| Keybinding | Action |
|------------|--------|
| `XF86AudioRaiseVolume` | Raise volume |
| `XF86AudioLowerVolume` | Lower volume |
| `XF86AudioMute` | Mute output |
| `XF86AudioMicMute` | Mute microphone |
| `XF86MonBrightnessUp` | Raise brightness |
| `XF86MonBrightnessDown` | Lower brightness |

## Session

| Keybinding | Action |
|------------|--------|
| `Mod4 + Shift + Escape` | Lock screen |
| `Mod4 + Shift + d` | Toggle do-not-disturb |
| `Mod4 + Ctrl + r` | Reload configuration |
| `Mod4 + Shift + q` | Quit SomeWM |

## Mouse Bindings

| Binding | Action |
|---------|--------|
| `Mod4 + Left Click` (drag) | Move client |
| `Mod4 + Right Click` (drag) | Resize client |
| `Click on tag` | View tag |
| `Scroll on taglist` | Cycle tags |

## See Also

- [Keybindings Tutorial](/docs/tutorials/keybindings)
- [AwesomeWM Key Docs](https://awesomewm.org/doc/api/libraries/awful.key.html)
