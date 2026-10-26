---
title: Kiln vs SomeWM
description: How kiln relates to SomeWM and AwesomeWM, what carries over conceptually, and when to choose which.
sidebar_position: 8
---

# Kiln vs SomeWM

kiln and SomeWM share a maintainer. SomeWM brings the AwesomeWM framework and its Lua API to Wayland; kiln is a separate compositor built to test whether the whole screen can be one declarative layout tree. SomeWM 2.1 adopted the same model: one Clay tree per output, declared, solved and drawn per frame. The code is not shared. Same desktop concepts, deliberately different API.

## What is the same

kiln has clients, tags, screens, layouts, rules, keybindings, and a bar, and they mean what an AwesomeWM or SomeWM user expects: tags are per-screen and multi-selectable, layouts arrange the tiled clients of the selected tags, rules apply properties when clients map, a modkey drives the chords.

What has no AwesomeWM counterpart: **a live layout inspector**. Because one solver owns the whole screen, kiln embeds Clay's own debug panel and draws it over the running desktop, giving you the element tree of the last solve with the computed box, sizing mode, padding and alignment for every row, and hover-to-highlight back into the real scene. See [Inspect the Live Element Tree](/kiln/guides/inspector).

## What is deliberately different

There is **no AwesomeWM compatibility layer**. No `awful`, `wibox`, `gears`, `naughty`, or `beautiful` namespaces exist. An existing `rc.lua` does not run on kiln, and neither do AwesomeWM widget libraries. kiln exposes the declarative model through its own API, the `ui.*` calls.

What maps, conceptually rather than literally:

- **Keybindings** become entries in the `kiln.key` registry: one table per chord with `mods`, `key`, a handler, and a description that feeds the hotkeys popup. Ranges like `"1-9"` replace keygroups. See [keybindings](/kiln/tutorials/keybindings).
- **Layouts** are plain Lua functions over the clients and the area, declaring nodes instead of computing geometries. `master_width_factor`, `master_count`, and friends live on the tag, as before. See [Custom layouts](/kiln/guides/custom-layouts).
- **Widgets** are declarations, not objects. Where AwesomeWM composes wibox widget instances with layouts and containers, kiln composes function calls that declare boxes, rows, text, and images each frame. There is no widget lifecycle to manage. Roughly: [`kiln.widgets`](/kiln/reference/widgets) is roughly `awful.widget` territory (taglist, tasklist, layoutbox, the stock compositions), while `ui.*` covers what the `wibox.widget` and `wibox.layout` primitives did. See the [widgets tutorial](/kiln/tutorials/widgets).
- **Rules, menus, notifications, prompts, placement helpers, the systray, the taglist and tasklist**: all present, all with kiln spellings. Most daily-driver capabilities have a direct kiln expression, and the guides cover them one by one.

What does not map at all: the `wibox` API itself, its wiboxes, drawins and widget instances. kiln draws rectangles, borders, text, and images from the solved tree; there is no canvas for a widget to paint on. Code that draws through wibox or cairo has no kiln equivalent. The full list of what kiln's drawing model excludes is in [Limitations](/kiln/concepts/limitations).

:::warning
The close verbs invert between the systems. In AwesomeWM and SomeWM, `c:kill()` is the polite close. In kiln, `c:close()` is the polite close (the xdg close request) and `c:kill()` is the impolite one: SIGKILL. Muscle memory that binds `mod+shift+c` to `kill()` will hard-kill applications on kiln. Bind `c:close()`.
:::

## When to choose which

Choose **SomeWM** if you have an AwesomeWM configuration or depend on its ecosystem: your `rc.lua`, your themes, and the widget libraries you use run there.

Choose **kiln** if you want to write the single-tree model directly: the `ui.*` API, layouts without arithmetic, widgets without lifecycle, and policy as replaceable Lua functions. You will write your configuration fresh: it is a rewrite, not a port.

kiln's API is functional but not frozen; expect breaking changes. SomeWM is the conservative choice.

## See also

- [The Clay Bet](/kiln/concepts/the-clay-bet)
- [Inspect the Live Element Tree](/kiln/guides/inspector)
- [Limitations](/kiln/concepts/limitations)
- [Anatomy of rc.lua](/kiln/getting-started/rc-anatomy)
- [Keybindings tutorial](/kiln/tutorials/keybindings)
- [Widgets tutorial](/kiln/tutorials/widgets)
