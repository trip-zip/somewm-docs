---
sidebar_position: 1
title: Basics
description: Open and tile windows, switch tags, and change your terminal in SomeWM 2.1.
---

# Basics

Start with SomeWM 2.1's default config and an installed `foot`. Open windows, tile them, move between tags, then change the terminal shortcut.

If SomeWM is not running yet, follow [First Launch](../getting-started/first-launch.md). To try it inside your current desktop, use [a nested session](try-somewm-without-installing.md).

## Open two terminals

<span id="windows" />

Press **Mod4+Return** twice. `Mod4` is the Super or Windows key. The default layout is **tile**. One terminal occupies the master area on the left, and the other occupies the stack on the right. Open a third terminal to split the right side vertically.

If nothing opens, check that `foot` is installed or change `terminal` as shown below. In a nested session, use Alt instead of Super if its startup message reports a modifier remap.

## Focus and resize

<span id="layouts" />

Press **Mod4+j** and **Mod4+k** to cycle focus. The focused window gets the active border colour.

With tile selected, press **Mod4+h** to shrink the master area and **Mod4+l** to enlarge it. Press **Mod4+Shift+c** to close the focused window.

Press **Mod4+s** to view the configured shortcuts. Press Escape to close the popup.

## Move between tags

<span id="tags" />

The labels `dev`, `web`, `chat`, `files` and `media` in the top bar are **tags**. Number keys select them by position. Each window belongs to one or more tags, and the screen shows windows on the selected tags.

1. Press **Mod4+2**. The second tag, `web`, is empty.
2. Open a terminal there with **Mod4+Return**.
3. Press **Mod4+1** to return to the windows on tag 1.
4. Press **Mod4+Ctrl+2** to display tags 1 and 2 together.
5. Press **Mod4+1** to show only tag 1 again.

To move the focused window to tag 2, press **Mod4+Shift+2**, then **Mod4+2** to follow it.

You can also click a tag in the bar.

## Use the bar

<span id="the-desktop" />
<span id="mouse" />

The top **wibar** contains the launcher menu, tags, run prompt, tasklist, tray, clock and layout indicator. The clock sits at the centre of the screen. Click the layout indicator to cycle layouts.

Press **Mod4+r**, type an installed application's command, then press Return. The application opens on the selected tag. Escape cancels the prompt.

## Change the terminal

<span id="your-first-edit" />

Use your own copy of the default config, as described in [First Launch](../getting-started/first-launch.md). Edit `~/.config/somewm/rc.lua` unless you chose a different configuration directory.

Find:

```lua
local terminal = "foot"
```

Replace it with an installed terminal, for example:

```lua
local terminal = "alacritty"
```

Save the file, then check its syntax:

```bash
somewm --check ~/.config/somewm/rc.lua
```

This parses the file and checks for known compatibility issues. It does not execute the config or prove that callbacks will work.

Press **Mod4+Ctrl+r** to reload, then **Mod4+Return** to check the new terminal. A reload rebuilds the Lua configuration. If loading fails, SomeWM may load its fallback config, so read any error notification before continuing.

## Keep these shortcuts nearby

<span id="next" />

| Action | Default shortcut |
| --- | --- |
| Open terminal | Mod4+Return |
| Close window | Mod4+Shift+c |
| Focus next / previous window | Mod4+j / Mod4+k |
| Select tag | Mod4+1–5 |
| Move window to tag | Mod4+Shift+1–5 |
| Next / previous layout | Mod4+Space / Mod4+Shift+Space |
| Toggle focused window floating | Mod4+Ctrl+Space |
| Run command | Mod4+r |
| Show shortcut help | Mod4+s |
| Reload config | Mod4+Ctrl+r |
| Quit SomeWM | Mod4+Shift+q |

Continue with [a custom clock widget](widgets.md), [keybindings](keybindings.md), or [a theme](theme.md). The [default keybindings reference](../reference/default-keybindings.md) lists the remaining shortcuts.
