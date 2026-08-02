---
sidebar_position: 1
title: Basics
description: A beginner-friendly walkthrough of SomeWM basics
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Basics

<YouWillLearn>

- How tiling differs from floating window managers
- How to start SomeWM and read the default desktop
- Essential keybindings for windows, tags, and layouts
- How to edit and reload your `rc.lua`

</YouWillLearn>

## Prerequisites

- You are logged into a running SomeWM session ([First Launch](/docs/getting-started/first-launch) gets you there)
- A terminal emulator installed (the default config uses `xterm`, but any terminal works)

:::tip
Don't want to log out of your current desktop? The [nested compositor tutorial](/docs/tutorials/try-somewm-without-installing) runs SomeWM in a window, and everything below works the same there.
:::

## What is a Tiling Window Manager?

SomeWM is a **tiling** window manager. This means:

- **Windows don't overlap** - they automatically arrange to fill your screen
- **Keyboard-driven** - most actions use keyboard shortcuts instead of mouse
- **Highly customizable** - everything is configured in Lua

## Understanding the Desktop

{/* TODO: Screenshot needed
   - Full desktop screenshot showing default SomeWM session
   - Should show: empty desktop with top wibar, default wallpaper
   - Annotate with arrows pointing to: taglist (left), tasklist (center), clock/systray (right)
*/}

### The Wibar (Top Bar)

The bar at the top of your screen is called a **wibar** (widget bar). From left to right:

| Component | Description |
|-----------|-------------|
| **Launcher icon** | Click to open the main menu |
| **Tags (1-9)** | Virtual desktops - click to switch |
| **Prompt area** | Shows the run prompt when activated |
| **Tasklist** | Shows windows on current tag (middle section) |
| **Keyboard layout** | Current keyboard layout |
| **System tray** | App indicators (volume, network, etc.) |
| **Clock** | Current time |
| **Layout indicator** | Shows current window layout (rightmost) |

### Tags vs Workspaces

SomeWM uses **tags** instead of fixed workspaces:

- A window can be on **multiple tags at once** (not just one)
- You can **view multiple tags simultaneously**
- Tags are numbered 1-9 by default

Think of tags as labels you attach to windows, rather than containers that hold windows.

## Your First Commands

All shortcuts use **Mod4** (Super/Windows key) as the primary modifier.

### Opening a Terminal

Press **Mod4 + Enter** to open a terminal.

{/* TODO: Screenshot needed
   - Desktop with one terminal window open
   - Show how it fills the entire screen (tiling behavior)
*/}

### Opening More Windows

Open a few more terminals with **Mod4 + Enter**.

{/* TODO: Screenshot needed
   - Desktop with 2-3 terminal windows tiled
   - Show the master-stack layout clearly
*/}

The first window takes the left half (the "master" area), and additional windows stack on the right. See [Master and Stack](/docs/concepts/master-and-stack) to learn how this works and how to customize it.

### Switching Focus

With multiple windows open:

| Keybinding | Action |
|------------|--------|
| **Mod4 + j** | Focus next window |
| **Mod4 + k** | Focus previous window |
| **Mod4 + Tab** | Switch to last focused window |

Try pressing **Mod4 + j** and **Mod4 + k** to move focus between windows.

### Closing Windows

Press **Mod4 + Shift + c** to close the focused window. Notice that the remaining windows immediately re-tile to fill the gap; nothing is left where the closed window was.

### The Run Prompt

Press **Mod4 + r**. A text prompt appears in the wibar where the prompt area sits. Type any command (like `firefox` or `nautilus`) and press Enter; the prompt disappears and the app opens as a new tile.

{/* TODO: Screenshot needed
   - Wibar with run prompt visible
   - Show text entry field
*/}

### Showing Help

Press **Mod4 + s** to show the keybinding help popup.

{/* TODO: Screenshot needed
   - Hotkeys popup showing keybinding groups
*/}

Press any key to dismiss the help popup.

## Working with Tags

Tags are how you organize your windows. By default, you have 9 tags (numbered 1-9).

### Switching Tags

| Keybinding | Action |
|------------|--------|
| **Mod4 + 1-9** | Switch to tag 1-9 |
| **Mod4 + Left** | Switch to previous tag |
| **Mod4 + Right** | Switch to next tag |

Try it: Open a terminal, then press **Mod4 + 2** to switch to tag 2. Open another terminal here.

Now press **Mod4 + 1** to go back to tag 1. The first terminal is still there.

### Moving Windows Between Tags

To move the focused window to another tag:

| Keybinding | Action |
|------------|--------|
| **Mod4 + Shift + 1-9** | Move window to tag 1-9 |

Try it: with a terminal focused, press **Mod4 + Shift + 3**. The window vanishes from this tag. Press **Mod4 + 3** and there it is, alone on tag 3.

### Viewing Multiple Tags

| Keybinding | Action |
|------------|--------|
| **Mod4 + Ctrl + 1-9** | Toggle viewing tag 1-9 |

Press **Mod4 + Ctrl + 2** while on tag 1. Windows from both tags now tile together on screen, and both tag numbers are highlighted in the taglist. Press **Mod4 + Ctrl + 2** again to go back to just tag 1.

## Understanding Layouts

SomeWM supports multiple window layouts. The current layout is shown in the rightmost icon of the wibar.

### Changing Layouts

| Keybinding | Action |
|------------|--------|
| **Mod4 + Space** | Next layout |
| **Mod4 + Shift + Space** | Previous layout |

Common layouts:

| Layout | Description |
|--------|-------------|
| **Tile** | Master on left, stack on right |
| **Fair** | All windows equal size |
| **Max** | Focused window fills screen |
| **Floating** | Traditional overlapping windows |

### Resizing the Master Area

In tiling layouts, you can adjust how much space the master area takes:

| Keybinding | Action |
|------------|--------|
| **Mod4 + l** | Increase master width |
| **Mod4 + h** | Decrease master width |

This works with tile, spiral, and dwindle layouts.

## Using the Mouse

Mouse bindings:

| Action | Effect |
|--------|--------|
| **Click on tag** | Switch to that tag |
| **Scroll on taglist** | Cycle through tags |
| **Mod4 + Left Click** (drag) | Move window (in floating mode or makes window floating) |
| **Mod4 + Right Click** (drag) | Resize window |
| **Right-click on desktop** | Open main menu |

## Your First Customization

### Finding Your Config File

SomeWM looks for configuration in this order:

1. `~/.config/somewm/rc.lua`
2. `~/.config/awesome/rc.lua` (AwesomeWM compatibility)
3. System fallback config

If you don't have a config yet, copy the installed default:

```bash
mkdir -p ~/.config/somewm
cp /etc/xdg/somewm/rc.lua ~/.config/somewm/rc.lua
```

### Changing Your Terminal

Open `~/.config/somewm/rc.lua` in your editor and find this line near the top:

```lua
terminal = "xterm"
```

Change it to your preferred terminal:

```lua
terminal = "alacritty"  -- or "kitty", "foot", "wezterm", etc.
```

Save the file.

### Reloading Your Config

Press **Mod4 + Ctrl + r** to reload your configuration. The wibar rebuilds, and your open windows stay exactly where they were: a reload replaces the Lua state, not your session.

Now press **Mod4 + Enter**. Your new terminal opens instead of xterm. You have made and verified your first configuration change.

:::caution
If there's an error in your config, SomeWM will show a notification and continue with the old config. Check the notification for details about what went wrong.
:::

Forgot a shortcut? Press `Mod4 + s` anytime for the built-in cheat sheet, or see the [Default Keybindings reference](/docs/reference/default-keybindings).

## What's Next?

- **[Theme](/docs/tutorials/theme)** - Change colors, fonts, and appearance
- **[Keybindings](/docs/tutorials/keybindings)** - Add your own keyboard shortcuts
- **[Widgets](/docs/tutorials/widgets)** - Build a custom widget for your wibar
- **[Default Keybindings](/docs/reference/default-keybindings)** - Complete list of all shortcuts

## Troubleshooting

### Nothing happens when I press keys

Make sure you're pressing the correct modifier. By default, `Mod4` is the Super/Windows key. On some keyboards, you may need to check your BIOS settings or use `xmodmap` to configure the modifier keys.

### Terminal won't open

The default config uses `xterm`. If it's not installed, either:
- Install xterm: `sudo apt install xterm` (Debian/Ubuntu) or `sudo pacman -S xterm` (Arch)
- Change the terminal in your config as shown above

### Config changes don't work

After editing `rc.lua`:
1. Save the file
2. Press `Mod4 + Ctrl + r` to reload
3. Check for error notifications

If you see an error, SomeWM will tell you the line number. Common issues:
- Missing comma at end of line
- Mismatched brackets or parentheses
- Typos in variable names

See the [Troubleshooting](/docs/troubleshooting) guide for more help.
