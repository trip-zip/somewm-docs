---
sidebar_position: 1
title: Basics
description: Open and tile windows, switch tags, and change your terminal in SomeWM 1.4.
---

# Basics

<span id="prerequisites" />
<span id="what-is-a-tiling-window-manager" />
<span id="starting-somewm" />
<span id="from-a-display-manager" />
<span id="from-tty" />
<span id="understanding-the-desktop" />
<span id="the-wibar-top-bar" />
<span id="tags-vs-workspaces" />
<span id="your-first-commands" />
<span id="opening-a-terminal" />
<span id="opening-more-windows" />
<span id="switching-focus" />
<span id="closing-windows" />
<span id="the-run-prompt" />
<span id="showing-help" />
<span id="working-with-tags" />
<span id="switching-tags" />
<span id="moving-windows-between-tags" />
<span id="viewing-multiple-tags" />
<span id="understanding-layouts" />
<span id="changing-layouts" />
<span id="resizing-the-master-area" />
<span id="using-the-mouse" />
<span id="your-first-customization" />
<span id="finding-your-config-file" />
<span id="changing-your-terminal" />
<span id="reloading-your-config" />
<span id="changing-the-modkey" />
<span id="quick-reference-card" />
<span id="whats-next" />
<span id="troubleshooting" />
<span id="nothing-happens-when-i-press-keys" />
<span id="terminal-wont-open" />
<span id="config-changes-dont-work" />

Start with SomeWM 1.4's default config and an installed `xterm`. Open windows, tile them, move between tags, then change the terminal shortcut.

If SomeWM is not running yet, follow [First Launch](../getting-started/first-launch.md). To try it inside your current desktop, use [a nested session](try-somewm-without-installing.md).

## Open two terminals

Press **Mod4+Return** twice. `Mod4` is the Super or Windows key. The default layout is **floating**, so the terminals may overlap.

Press **Mod4+Space** once to select the next layout, **tile**. One terminal occupies the master area on the left, and the other occupies the stack on the right. Open a third terminal to split the right side vertically.

If nothing opens, check that `xterm` is installed or change `terminal` as shown below. In a nested session, use Alt instead of Super if its startup message reports a modifier remap.

## Focus and resize

Press **Mod4+j** and **Mod4+k** to cycle focus. The focused window gets the active border colour.

With tile selected, press **Mod4+h** to shrink the master area and **Mod4+l** to enlarge it. Press **Mod4+Shift+c** to close the focused window.

Press **Mod4+s** to view the configured shortcuts. Press Escape to close the popup.

## Move between tags

The numbered labels in the top bar are **tags**. Each window belongs to one or more tags, and the screen shows windows on the selected tags.

1. Press **Mod4+2**. Tag 2 is empty.
2. Open a terminal there with **Mod4+Return**.
3. Press **Mod4+1** to return to the windows on tag 1.
4. Press **Mod4+Ctrl+2** to display tags 1 and 2 together.
5. Press **Mod4+1** to show only tag 1 again.

To move the focused window to tag 2, press **Mod4+Shift+2**, then **Mod4+2** to follow it.

You can also click a tag in the bar.

## Use the bar

The top **wibar** contains the launcher menu, tags, run prompt, tasklist, keyboard layout, tray, clock, and layout indicator. Click the layout indicator to cycle layouts.

Press **Mod4+r**, type an installed application's command, then press Return. The application opens on the selected tag. Escape cancels the prompt.

## Change the terminal

Use your own copy of the default config, as described in [First Launch](../getting-started/first-launch.md). Edit `~/.config/somewm/rc.lua` unless you chose a different configuration directory.

Find:

```lua
terminal = "xterm"
```

Replace it with an installed terminal, for example:

```lua
terminal = "alacritty"
```

Save the file, then check its syntax:

```bash
somewm --check
```

This parses the file and checks for known compatibility issues. It does not execute the config or prove that callbacks will work.

Press **Mod4+Ctrl+r** to reload, then **Mod4+Return** to check the new terminal. A reload rebuilds the Lua configuration. If loading fails, SomeWM may load its fallback config, so read any error notification before continuing.

## Keep these shortcuts nearby

| Action | Default shortcut |
| --- | --- |
| Open terminal | Mod4+Return |
| Close window | Mod4+Shift+c |
| Focus next / previous window | Mod4+j / Mod4+k |
| Select tag | Mod4+1–9 |
| Move window to tag | Mod4+Shift+1–9 |
| Next / previous layout | Mod4+Space / Mod4+Shift+Space |
| Toggle focused window floating | Mod4+Ctrl+Space |
| Run command | Mod4+r |
| Show shortcut help | Mod4+s |
| Reload config | Mod4+Ctrl+r |
| Quit SomeWM | Mod4+Shift+q |

Continue with [a custom clock widget](widgets.md), [keybindings](keybindings.md), or [a theme](theme.md). The [default keybindings reference](../reference/default-keybindings.md) lists the remaining shortcuts.
