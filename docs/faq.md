---
sidebar_position: 100
title: FAQ
description: Short answers on what SomeWM is, config location and reload, restart, AwesomeWM configs and libraries, the systray, screenshots and missing widgets.
---

# FAQ

**What is SomeWM?** A Wayland compositor on wlroots running AwesomeWM's Lua configuration model. 2.x develops the API on its own; 1.4 mirrors AwesomeWM master ([AwesomeWM Compatibility](concepts/awesomewm-compat.md)).

**Why the name?** If Awesome is great, Some is adequate.

**Is it stable?** In active development. [Deviations](reference/deviations.md) is the status list.

**Where is the config?** `~/.config/somewm/rc.lua`, then `~/.config/awesome/rc.lua`, then the bundled default ([Launch](getting-started/first-launch.md)).

**How do I reload?** Mod4 + Ctrl + r, which calls `awesome.restart()`: the Lua state is rebuilt in process and every client survives. The X11-style exec-self restart is the one thing it cannot do ([Why SomeWM](concepts/why-somewm.md)).

**Does my AwesomeWM config work?** Usually, after removing X11 tools and the deprecated APIs 2.0 dropped. `somewm --check rc.lua` reports both ([Migrating](getting-started/migrating.md)).

**Do AwesomeWM widgets and libraries like bling work?** Those that use current APIs and do not paint with cairo. A widget with its own `draw` method is left out of the tree with a warning ([Upgrading from 2.0 to 2.1](getting-started/upgrading-from-2.0.md#what-you-will-see)); a library needs its own update for that. Removed APIs are listed in [Migrating](getting-started/migrating.md#deprecated-apis-removed-in-somewm-20).

**Why do xdotool, xrandr and xprop do nothing?** They are X11 ([Wayland vs X11](concepts/wayland-vs-x11.md) has the replacements).

**Does the systray work?** Through StatusNotifierItem over D-Bus. XEmbed-only apps show no icon.

**Screenshots?** `awful.screenshot`, `somewm-client screenshot`, or grim and slurp ([Screenshots](guides/screenshots.md)).

**Multi-monitor?** Each monitor is a screen with its own tags and bar ([Multi-Monitor](guides/multi-monitor.md)).

**A widget is missing.** Read the log for `wibox.clay: <class> ... is left out of the tree`, then `somewm-client clay tree` shows what was drawn ([Reading the tree](concepts/reading-the-tree.md)).

**A widget ignores the theme.** Its module was required before `beautiful.init()` ([Troubleshooting](troubleshooting.md#widget-shows-no-theming-unstyled-wrong-font)).

**It will not start.** [Troubleshooting](troubleshooting.md).
