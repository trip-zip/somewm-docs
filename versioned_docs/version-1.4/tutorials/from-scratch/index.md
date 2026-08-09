---
title: Awesome From Scratch
description: Build a complete AwesomeWM/SomeWM desktop in thirteen chapters, one feature at a time.
sidebar_position: 1
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Awesome From Scratch

Build a complete desktop configuration from the stock config to a finished environment: a themed bar with live widgets, a notification system with history and a notification center, an app launcher, a control center, a window switcher, and a native lockscreen. Thirteen chapters, each one adding a single feature, each backed by a git branch holding the finished code.

**100% native.** No rofi, no polybar, no conky. Everything in this series is built from the widget system the window manager already ships.

![The finished desktop: tiled terminals under a themed bar, with the dashboard and launcher open](/img/from-scratch/intro-final-desktop.png)

## What You'll Build

- **Chapters 00-05** are the foundation: the theme system, table-driven keybindings, your first widgets, a bar to put them in, and client rules with titlebars.
- **Chapters 06-11** are the features: a full notification system, then a run of overlay UIs - exit screen, main menu, window switcher, launcher, dashboard - all built on one modal pattern you extract yourself in chapter 07.
- **Chapter 12** is the finale: a native lockscreen on SomeWM's session-lock API. <SomewmOnly />

![The notification center and power menu](/img/from-scratch/intro-notifications-menu.png)

## Who This Is For

You are new to AwesomeWM or SomeWM, and comfortable reading Lua. Every window-manager concept - widgets, signals, timers, theming, rules, keygrabbers - is explained when it first appears. Lua itself is not; if you can read a table constructor and a closure, you're equipped.

The configuration runs on **both** AwesomeWM (X11) and SomeWM (Wayland). The handful of SomeWM-only features are marked with a badge like the one above, always with a note on what AwesomeWM users should do instead.

## Prerequisites

- [SomeWM](https://github.com/trip-zip/somewm) or AwesomeWM 4.3+
- git and a terminal emulator
- JetBrainsMono Nerd Font (or any Nerd Font; you'll learn to change it in one line)
- Optional CLI tools the widgets shell out to: `wpctl` (volume), `brightnessctl`, `nmcli`, `bluetoothctl`, `upower`, `playerctl`

## How the Checkpoint Branches Work

The companion repository is [trip-zip/awesome-from-scratch](https://github.com/trip-zip/awesome-from-scratch). It has one branch per chapter, and every branch is exactly one commit on top of the previous one:

```bash
git clone https://github.com/trip-zip/awesome-from-scratch.git
cd awesome-from-scratch

git checkout 03-widgets        # the finished code for chapter 3
git diff 02-keybindings 03-widgets   # exactly what chapter 3 added
```

The recommended way to follow along: **type the code yourself** as you read, and use the branches to catch up, compare, or un-stick yourself. Checking out a branch and reading it works too - both are legitimate.

## Running Your Work Safely

Never test a work-in-progress config on your real session. Both compositors can run nested in a window.

**SomeWM:**

```bash
somewm-client test start --config "$PWD/rc.lua" --name afs
```

That opens a nested SomeWM in a window; your real session is untouched. See [testing with a nested compositor](../../guides/testing-with-nested-compositor.md) for the details, and note the [Mod4 remapping caveat](../../troubleshooting.md) for nested sessions.

**AwesomeWM:** use Xephyr:

```bash
Xephyr :1 -ac -br -noreset -screen 1280x720 &
DISPLAY=:1 awesome -c "$PWD/rc.lua"
```

The config resolves its own modules relative to the rc.lua you point it at, so running from a git checkout works on both compositors.

## How This Relates to the Other Tutorials

The [SomeWM tutorials](../basics.md) are short and standalone: if you just want to add [a theme](../theme.md), [widgets](../widgets.md), [keybindings](../keybindings.md), or [a bar](../wibar.md) to your *current* config, start there. This series is a course: each chapter builds on the last, and you end with a complete configuration you understand top to bottom.

## Start

Head to [Chapter 00: The Default Config](00-default.md).

![The native lockscreen](/img/from-scratch/intro-lockscreen.png)
