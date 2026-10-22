---
title: Awesome From Scratch
description: Build a complete AwesomeWM/SomeWM desktop in thirteen chapters, one feature at a time.
sidebar_label: Overview
---

import ChapterList from '@site/src/components/FromScratch/ChapterList';

# Awesome(And SomeWM 1.4) From Scratch

Build a desktop configuration in thirteen chapters: theme, widgets, bar, notifications, menus, launcher, dashboard, window switcher, and a SomeWM lockscreen.

**Targets AwesomeWM master and SomeWM 1.4.** AwesomeWM 4.3 is unsupported: the examples require `ruled` and newer `request::` signals. SomeWM 2.x has API changes and is outside this series’ scope.

**Read in order.** Each chapter builds on the previous checkpoint. For individual additions to an existing config, use the [standalone tutorials](../basics.md).

![The finished desktop: tiled terminals under a themed bar, with the dashboard and launcher open](/img/from-scratch/intro-final-desktop.png)

## The Chapters

<ChapterList />

![The notification center and power menu](/img/from-scratch/intro-notifications-menu.png)

## Who This Is For

You should be comfortable reading Lua tables and functions. The chapters introduce window-manager concepts as they are needed.

SomeWM-only features are marked, with alternatives for AwesomeWM users.

## Prerequisites

- [SomeWM 1.4](https://github.com/trip-zip/somewm) or AwesomeWM master
- git and a terminal emulator
- JetBrainsMono Nerd Font, or another Nerd Font
- CLI tools for the widgets you use: `wpctl`, `brightnessctl`, `nmcli`, `bluetoothctl`, `upower`, and `playerctl`

## How the Checkpoint Branches Work

[trip-zip/awesome-from-scratch](https://github.com/trip-zip/awesome-from-scratch) has a checkpoint branch per chapter. Check out a branch for the finished code, or compare adjacent branches:

```bash
git clone https://github.com/trip-zip/awesome-from-scratch.git
cd awesome-from-scratch

git checkout 03-widgets        # the finished code for chapter 3
git diff 02-keybindings 03-widgets   # exactly what chapter 3 added
```

Use the checkpoints to compare your work or catch up.

## Running Your Work Safely

Test edits in a nested window before applying them to your desktop. Run these commands from the checkout.

**SomeWM:**

```bash
somewm-client test start --config "$PWD/rc.lua" --name afs
```

See [nested testing](../../guides/testing-with-nested-compositor.md) and the [Mod4 remapping caveat](../../troubleshooting.md).

**AwesomeWM:** use Xephyr:

```bash
Xephyr :1 -ac -br -noreset -screen 1280x720 &
DISPLAY=:1 awesome -c "$PWD/rc.lua"
```

The config finds its modules relative to the specified `rc.lua`, so both commands work from the checkout.

## How This Relates to the Other Tutorials

Use the standalone tutorials to add [a theme](../theme.md), [widgets](../widgets.md), [keybindings](../keybindings.md), or [a bar](../wibar.md) to an existing config.

## Start

Head to [Chapter 00: The Default Config](00-default.md).

![The native lockscreen](/img/from-scratch/intro-lockscreen.png)
