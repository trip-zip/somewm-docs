---
title: Awesome From Scratch
description: Build a complete AwesomeWM/SomeWM desktop in thirteen chapters, one feature at a time.
sidebar_label: Overview
---

import ChapterList from '@site/src/components/FromScratch/ChapterList';

# Awesome and SomeWM 1.4 From Scratch

<span id="awesomeand-somewm-14-from-scratch" />

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
git diff origin/02-keybindings origin/03-widgets
```

Each chapter shows excerpts from its checkpoint. They are not complete files unless labelled as such. Keep the full files open while following the steps, and use the branch diff to find omitted imports, layouts, and handlers. Save your own edits on a separate branch before switching checkpoints.

## Running Your Work Safely

<span id="how-this-relates-to-the-other-tutorials" />

Test edits in a nested window before applying them to your desktop. Run these commands from the checkout.

**SomeWM:**

```bash
somewm-client test start --config "$PWD/rc.lua" --name afs
```

After editing, run `somewm-client test reload --name afs`. Before changing checkpoint branches, stop the instance with `somewm-client test stop --name afs`, then start it again. Add `--host x11` when launching from X11. See [nested testing](../../guides/testing-with-nested-compositor.md) for modifier remapping.

**AwesomeWM:** use Xephyr:

```bash
Xephyr :1 -ac -br -noreset -screen 1280x720 &
DISPLAY=:1 awesome -c "$PWD/rc.lua"
```

From chapter 01 onward, the config finds modules relative to the specified `rc.lua`. Stop the Xephyr session before switching branches. Nested sessions share your files and services, so power-menu and dashboard actions can affect your real desktop.

## Start

Head to [Chapter 00: The Default Config](00-default.md).

![The native lockscreen](/img/from-scratch/intro-lockscreen.png)
