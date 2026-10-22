---
title: Kiln
description: A Wayland compositor where your entire desktop is one declarative Lua config over a Clay layout tree.
sidebar_position: 1
slug: /
---

# Kiln

Kiln is a Wayland compositor written in Odin and configured in Lua. Windows, bars, widgets, menus and notifications share one
[Clay](https://github.com/nicbarker/clay) layout tree per output. Lua defines
policy; Odin handles the compositor and retained rendering over wlroots.

The maintainer runs Kiln on a real desktop. The API remains experimental;
[known limitations](/kiln/concepts/limitations) distinguish software coverage,
operator-reported physical use and pending hardware checks. Build and run it
with `make` and `make run`, or use `./run-tty` from a free physical TTY.

The screenshots below are historical C Kiln captures. New Odin desktop
captures have not yet replaced them.

![The default kiln desktop: two terminals tiled under the bar](/img/kiln/desktop.png)

<span id="your-desktop-is-a-config" />

## Start here

1. [Install kiln](/kiln/getting-started/installation) from source.
2. [Launch it nested](/kiln/getting-started/first-launch) inside your current session.
3. Edit your config with [the basics tutorial](/kiln/tutorials/basics).

`mod+Return` opens a terminal, `mod+s` shows every binding on one sheet, `mod+shift+q` quits.

## Inspect the desktop {#it-really-is-a-clay-tree}

Press `mod+shift+i` to inspect the desktop’s layout with Clay’s debug inspector.

![Clay's debug inspector open over the kiln desktop](/img/kiln/inspector.png)

## Coming from AwesomeWM or SomeWM

See [kiln vs SomeWM](/kiln/concepts/kiln-vs-somewm) for compatibility and configuration differences.

:::info
The API is not yet stable and may change between releases.
:::

## Where things live

| Section | Open it when |
|---------|--------------|
| [Tutorials](/kiln/tutorials/basics) | You are new and want to build up a config step by step |
| [How-To Guides](/kiln/guides/client-rules) | You have a specific task in hand |
| [Reference](/kiln/reference/) | You need the exact property, method, signal, or default |
| [Concepts](/kiln/concepts/the-clay-bet) | You want to understand how kiln works and why |

Short answers to common questions are in the [FAQ](/kiln/faq). The source lives
at [github.com/trip-zip/kiln](https://github.com/trip-zip/kiln). Kiln is MIT
licensed. The retired C implementation remains in Git history at
`c-baseline-82ad185` for reproducible comparisons.
