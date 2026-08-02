---
sidebar_position: 100
title: FAQ
description: Frequently asked questions about SomeWM
---

# Frequently Asked Questions

## General

### What is SomeWM?

SomeWM is AwesomeWM ported to Wayland. It aims for 100% Lua API compatibility with AwesomeWM, letting you use your existing `rc.lua` configuration.

### Why "SomeWM"?

It's a play on "AwesomeWM" - if Awesome is great, Some is... adequate? The name reflects that it's a port, not a reimagining.

### Can I use my existing AwesomeWM config?

Yes! Most configs work with minimal changes. See [Migrating from AwesomeWM](/docs/getting-started/migrating) for details.

### Is SomeWM stable?

SomeWM is in active development. Most AwesomeWM functionality works, but some features are still being implemented. See [Current Limitations](/docs/troubleshooting#current-limitations).

## Configuration

### Where is my config file?

`~/.config/somewm/rc.lua` (with `~/.config/awesome/rc.lua` as an AwesomeWM-compatibility fallback). The [Troubleshooting guide](./troubleshooting.md) has the full search order including the system paths.

### How do I reload my config?

Press `Mod4 + Ctrl + r` to reload your Lua configuration without restarting.

### Can I restart SomeWM like AwesomeWM?

Yes. `awesome.restart()` works: it hot-reloads the Lua state in process, and clients survive. What SomeWM can't do is the X11-style exec-self restart, which would disconnect every client. See [Why SomeWM](/docs/next/concepts/why-somewm) for the mechanism.

## Compatibility

### Will all AwesomeWM widgets work?

Yes, all wibox widgets work because the Lua libraries are identical to AwesomeWM.

### What about third-party libraries like bling?

Most work without changes. Some may need adjustments if they use X11-specific features.

### Why don't X11 tools work?

Tools like `xdotool`, `xrandr`, `xprop` are X11-specific. See [Wayland vs X11](/docs/concepts/wayland-vs-x11) for alternatives.

## Features

### Does the systray work?

Yes, but differently. SomeWM uses the SNI D-Bus protocol instead of X11 embed. Most modern apps support this.

### Can I take screenshots?

Yes! Use `awful.screenshot` or external tools like `grim` and `slurp`. See [Screenshots](/docs/guides/screenshots).

### Does multi-monitor work?

Yes. Screens are detected automatically and you can configure them per-screen in your `rc.lua`.

## Troubleshooting

### SomeWM won't start

See [Troubleshooting](/docs/troubleshooting) for common issues.

### My config isn't loading

Run `somewm --check ~/.config/somewm/rc.lua` to check for errors.

### Widgets aren't rendering

Usually means LGI isn't found. See [Installation - LGI Troubleshooting](/docs/getting-started/installation#lgi-troubleshooting).

### My widget ignores my theme

The widget module was required before `beautiful.init()`. See [Troubleshooting](/docs/troubleshooting#widget-shows-no-theming-unstyled-wrong-font).
