---
title: Kiln
description: A Wayland compositor where your entire desktop is one declarative Lua config over a Clay layout tree.
sidebar_position: 1
slug: /
---

# Kiln

Kiln is a Wayland compositor configured in Lua, with its active development
moving to Odin. Windows, bars, widgets, menus and notifications share one
[Clay](https://github.com/nicbarker/clay) layout tree per output. Lua defines
policy; Odin handles the compositor and retained rendering over wlroots.

The maintainer runs the Odin implementation on a real desktop. Automated
software checks and operator-reported physical use are distinct evidence;
[known limitations](/kiln/concepts/limitations) remain. The C implementation
is the historical reference and comparison baseline. Current installed names
are `kiln-odin` and `kiln-odin-client`; the Lua module and config directory
remain `kiln`.

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

Short answers to common questions are in the [FAQ](/kiln/faq). The [existing public repository](https://github.com/trip-zip/kiln) currently
contains the C baseline. The Odin source destination is awaiting the
maintainer’s migration decision; these local documentation changes are a
publication draft.

Some detailed guides retain C-era shell recipes. For Odin, use
`kiln-odin-client eval` in place of `scripts/kiln-eval` with an explicit Lua
`return` when querying, and `kiln-odin-client` in place of `kiln-client`. The
current [installation](/kiln/getting-started/installation),
[first launch](/kiln/getting-started/first-launch) and
[headless guide](/kiln/guides/testing-headless) supersede old make targets.
Public Lua reference material is retained; C implementation details are
historical where labelled.
