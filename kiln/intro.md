---
title: Kiln
description: A Wayland compositor where your entire desktop is one declarative Lua config over a Clay layout tree.
sidebar_position: 1
slug: /
---

# Kiln

A stripped down Wayland compositor where the entire screen is one [Clay](https://github.com/nicbarker/clay) layout tree. Windows, bars, widgets, tags, menus, and notifications are all nodes in it.

![The default kiln desktop: two terminals tiled under the bar](/img/kiln/desktop.png)

## Your desktop is a config

This is the bar from the default `rc.lua`, unedited:

```lua
ui.bar(s, { edge = "top", color = th.bg }, function()
    taglist(s)
    tasklist(s)
    ui.spacer()
    ui.systray()
    layoutbox(s)

    -- floated to the parent's center, with a tooltip that is just a handler
    ui.box({
        id = "clock",
        float = { to = "parent", anchor = "center" },
        color = th.bg2, radius = 4, pad = { x = 8 }, align = "center",
        on_hover = ui.tooltip(function() return os.date("%A %d %B %Y") end),
    }, ui.clock)
end)
```

What to notice:

- **`ui.spacer()` takes the leftover room** because Clay's solver gives it the leftover room, not because a bar widget has a spacer feature.
- **A bar is a box with children.** So is a menu, a notification, and a tiled window's frame. There is one set of constructors, used everywhere.
- **Nothing here is imperative.** No draw callback, no widget object to construct and wire up. You declare what the screen should look like and the solver does the rest.

## It really is a Clay tree

Clay's own debug inspector works on the live desktop. Not a reimplementation and not a screenshot tool: the actual inspector, walking the actual tree that laid out the screen you are looking at. Toggle it with `mod+shift+i`.

![Clay's debug inspector open over the kiln desktop](/img/kiln/inspector.png)

Why one tree owns the whole screen, and what that deletes: [The Clay Thesis](/kiln/concepts/the-clay-thesis).

## Start here

1. [Install kiln](/kiln/getting-started/installation) from source.
2. [Launch it nested](/kiln/getting-started/first-launch) inside your current session, so nothing is at stake.
3. Work through [the basics](/kiln/tutorials/basics), which walks the default config and ends with you changing it live.

`mod+Return` opens a terminal, `mod+s` shows every binding on one sheet, `mod+shift+q` quits.

## Coming from AwesomeWM or SomeWM

- **The concepts carry over.** Clients, tags, layouts, rules, a status bar, a theme table.
- **The API does not.** It is declarative rather than imperative, with no compatibility layer. Existing configs and widget libraries do not run on kiln.

See [kiln vs SomeWM](/kiln/concepts/kiln-vs-somewm) for the full comparison.

:::info
kiln is a young project. The API is functional and fully documented here, but it is not yet frozen: names and shapes may still change between releases.
:::

## Where things live

These docs follow the [Diátaxis framework](https://diataxis.fr/). The sidebar lists every page; this is which section to open.

| Section | Open it when |
|---------|--------------|
| [Tutorials](/kiln/tutorials/basics) | You are new and want to build up a config step by step |
| [How-To Guides](/kiln/guides/client-rules) | You have a specific task in hand |
| [Reference](/kiln/reference/) | You need the exact property, method, signal, or default |
| [Concepts](/kiln/concepts/the-clay-thesis) | You want to understand how kiln works and why |

Short answers to common questions are in the [FAQ](/kiln/faq). The source lives at [github.com/trip-zip/kiln](https://github.com/trip-zip/kiln).
