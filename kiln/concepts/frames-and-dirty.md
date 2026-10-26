---
title: Frames and Dirty State
description: When kiln redraws, which property writes trigger a frame, and how animation rides the frame clock.
sidebar_position: 2
---

# Frames and Dirty State

kiln draws nothing until something marks a screen dirty. A dirty screen gets one fresh declaration, one Clay solve, one reconcile into the scene, and then goes idle again. An idle kiln consumes no CPU on layout; there is no periodic redraw, no polling loop.

## The dirty lists

Most dirtying is automatic. The stdlib listens for the property writes that change what a frame looks like and marks the affected screen.

On a **client**, the writes that redraw are exactly the ones that change something a frame draws: the tiled/floating split, a float's box, a stacking band, a border color, a titlebar's presence or its label. The exact property list is in the [client reference](/kiln/reference/client#which-property-writes-redraw).

On a **tag**, the layout-parameter writes redraw, gated on the tag being selected, because an unselected tag's arrangement is not on screen ([exact list](/kiln/reference/tag)). `name` is the exception with no gate: the taglist draws every tag's name, selected or not, so a rename always redraws.

Beyond the lists, the structural writes dirty too: tagging and untagging clients, changing a screen's `selected_tags`, mapping and unmapping. There is no arrange call; the write is enough.

Any other property write still happens: the value changes and `property::<key>` fires (see [The Object Model](/kiln/concepts/object-model)). It just does not, by itself, produce a frame.

## What deliberately does not dirty

Geometry facts do not redraw. When a client commits a new size, kiln records `width` and `height` on the object, and stops there.

The reason is a feedback loop. kiln configures a client to the box Clay solved; the client answers with a commit, which may be a slightly different size (clients are free to answer honestly). If that answer dirtied the screen, the new frame would configure again, the client would commit again, and the screen would redraw at panel rate forever. So geometry flows one way: declarations tell clients where to be, and what clients actually did is recorded as fact, never as a reason to draw another frame. The same holds for `screen.width` and `screen.height`, which are re-seeded at the top of every frame.

## Marking dirty by hand {#the-manual-lever}

`kiln.dirty()` marks every screen; `kiln.dirty(name)` marks one. You need it exactly when you changed something outside the dirty lists that a declaration reads: a plain Lua table your widget renders from, a custom property your bar displays. Widgets built with `ui.widget` can declare their own triggers (`watch` a signal, or `every` some seconds) and dirty themselves; see the [widgets tutorial](/kiln/tutorials/widgets).

## The frame clock and animation

Sometimes a screen should redraw every frame for a while: an easing tag switch, a sliding master split. For that there is a per-output frame clock. `core.tick(screen_name, true)` arms it; while armed, the core delivers a `frame::tick` event with the screen and the true time delta on every output frame, and the screen re-solves at panel rate. `core.tick(screen_name, false)` disarms it and the screen goes idle again.

Animation is plain Lua state on top of that clock. `kiln.animation.start(screen_name, key, target, dur, from)` begins easing a named value toward a target (ease-out cubic, 0.15 seconds by default), arming the screen's tick if it was idle. `kiln.animation.get(key, default)` returns the eased value mid-flight and the caller's own value once settled. Declarations read `get` where they would read the raw value, so an animated frame is just an ordinary frame that happened to read an in-between number. When the last animation on a screen finishes, its tick disarms automatically.

Easing, durations and animation state are all in `kiln.animation`; the native core provides only the frame clock. The stdlib uses the same machinery for its own effects, like the tag-switch reveal and the master-split slide.

## See also

- [One tree per screen](/kiln/concepts/one-tree)
- [The Object Model](/kiln/concepts/object-model)
- [The Native/Lua Boundary](/kiln/concepts/c-lua-boundary)
- [Widgets tutorial](/kiln/tutorials/widgets)
- [core reference](/kiln/reference/core)
