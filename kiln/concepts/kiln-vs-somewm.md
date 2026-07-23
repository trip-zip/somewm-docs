---
title: Kiln vs SomeWM
description: How kiln relates to SomeWM and AwesomeWM, what carries over conceptually, and when to choose which.
sidebar_position: 6
---

# Kiln vs SomeWM

kiln and SomeWM share a lineage. SomeWM brings the AwesomeWM framework to Wayland with API compatibility as its goal; kiln is a re-basing experiment grown from the same stock, asking a different question: what does that desktop look like if the entire screen is one declarative layout tree? Same desktop concepts, deliberately different API.

## What is the same

The mental model transfers whole. kiln has clients, tags, screens, layouts, rules, keybindings, and a bar, and they mean what an AwesomeWM or SomeWM user expects: tags are per-screen and multi-selectable, layouts arrange the tiled clients of the selected tags, rules apply properties when clients map, a modkey drives the chords. If you can think in AwesomeWM, you can think in kiln.

## What is deliberately different

There is **no AwesomeWM compatibility layer**. No `awful`, `wibox`, `gears`, `naughty`, or `beautiful` namespaces exist. An existing `rc.lua` does not run on kiln, and neither do AwesomeWM widget libraries. This is by design, not by omission: kiln exists to test the declarative model on its own terms, and a compat layer would reintroduce exactly the imperative machinery the model removes.

What maps, conceptually rather than literally:

- **Keybindings** become entries in the `some.key` registry: one table per chord with `mods`, `key`, a handler, and a description that feeds the hotkeys popup. Ranges like `"1-9"` replace keygroups. See [keybindings](/kiln/tutorials/keybindings).
- **Layouts** are plain Lua functions over the clients and the area, declaring nodes instead of computing geometries. `master_width_factor`, `master_count`, and friends live on the tag, as before. See [Custom layouts](/kiln/guides/custom-layouts).
- **Widgets** are declarations, not objects. Where AwesomeWM composes wibox widget instances with layouts and containers, kiln composes function calls that declare boxes, rows, text, and images each frame. There is no widget lifecycle to manage. See the [widgets tutorial](/kiln/tutorials/widgets).
- **Rules, menus, notifications, prompts, placement helpers, the systray, the taglist and tasklist**: all present, all with kiln spellings. Most daily-driver capabilities have a direct kiln expression, and the guides cover them one by one.

What does not map at all: the imperative widget machinery (`wibox`, drawins, the widget hierarchy) and the cairo draw path. kiln draws rectangles, borders, text, and images through Clay; there is no canvas to paint on. Code built on either has no kiln translation. The full list of what kiln's drawing model excludes is in [Limitations](/kiln/concepts/limitations).

:::warning
The close verbs invert between the systems. In AwesomeWM and SomeWM, `c:kill()` is the polite close. In kiln, `c:close()` is the polite close (the xdg close request) and `c:kill()` is the impolite one: SIGKILL. Muscle memory that binds `mod+shift+c` to `kill()` will hard-kill applications on kiln. Bind `c:close()`.
:::

## When to choose which

Choose **SomeWM** if you have an AwesomeWM configuration or depend on its ecosystem: your `rc.lua`, your themes, and the widget libraries you use are the investment, and SomeWM is built to honor it on Wayland.

Choose **kiln** if the declarative single-tree model is the draw: one tree for windows and chrome, layouts without arithmetic, widgets without lifecycle, policy as replaceable Lua functions. You will write your configuration fresh, and it will be shorter than the one you left, but it is a rewrite, not a port.

kiln is also younger and blunter about it: a proof of concept with an unstable API. SomeWM is the conservative choice; kiln is the experiment. Both are honest about which they are.

## See also

- [The Clay Thesis](/kiln/concepts/the-clay-thesis)
- [Limitations](/kiln/concepts/limitations)
- [Anatomy of rc.lua](/kiln/getting-started/rc-anatomy)
- [Keybindings tutorial](/kiln/tutorials/keybindings)
- [Widgets tutorial](/kiln/tutorials/widgets)
