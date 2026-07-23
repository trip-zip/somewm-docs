---
title: Frames and Dirty State
description: When kiln redraws, which property writes trigger a frame, and how animation rides the frame clock.
sidebar_position: 2
---

# Frames and Dirty State

kiln draws nothing until something marks a screen dirty. A dirty screen gets one fresh declaration, one Clay solve, one reconcile into the scene, and then goes idle again. An idle kiln consumes no CPU on layout; there is no periodic redraw, no polling loop. Understanding what dirties a screen, and what deliberately does not, explains almost every "why didn't that redraw" moment.

## The dirty lists

Most dirtying is automatic. The stdlib listens for the property writes that change what a frame looks like and marks the affected screen.

On a **client**, these writes redraw: `floating`, `float`, `ontop`, `urgent`, `titlebar`, `sticky`, `title`, `app_id`, `icon`. That is the literal, complete list. Each of these changes something a frame draws: the tiled/floating split, a float's box, a stacking band, a border color, a titlebar's presence or its label.

On a **tag**, these writes redraw: `layout`, `master_width_factor`, `master_count`, `column_count`, `gap`, `carousel_width`. They are gated on the tag being selected, because an unselected tag's arrangement is not on screen. `name` is the exception with no gate: the taglist draws every tag's name, selected or not, so a rename always redraws.

Beyond the lists, the structural writes dirty too: tagging and untagging clients, changing a screen's `selected_tags`, mapping and unmapping. Writing a tag property is the whole verb; there is no arrange call to make afterward.

Any other property write still happens: the value changes and `property::<key>` fires (see [The Object Model](/kiln/concepts/object-model)). It just does not, by itself, produce a frame.

## What deliberately does not dirty

Geometry facts do not redraw. When a client commits a new size, kiln records `width` and `height` on the object, and stops there.

The reason is a feedback loop. kiln configures a client to the box Clay solved; the client answers with a commit, which may be a slightly different size (clients are free to answer honestly). If that answer dirtied the screen, the new frame would configure again, the client would commit again, and the screen would redraw at panel rate forever. So geometry flows one way: declarations tell clients where to be, and what clients actually did is recorded as fact, never as a reason to draw another frame. The same holds for `screen.width` and `screen.height`, which are re-seeded at the top of every frame.

## The manual lever

`some.dirty()` marks every screen; `some.dirty(name)` marks one. You need it exactly when you changed something outside the dirty lists that a declaration reads: a plain Lua table your widget renders from, a custom property your bar displays. Widgets built with `ui.widget` can declare their own triggers (`watch` a signal, or `every` some seconds) and dirty themselves; see the [widgets tutorial](/kiln/tutorials/widgets).

## The frame clock and animation

Sometimes a screen should redraw every frame for a while: an easing tag switch, a sliding master split. For that there is a per-output frame clock. `core.tick(screen, true)` arms it; while armed, C delivers a `frame::tick` event with the screen and the true time delta on every output frame, and the screen re-solves at panel rate. `core.tick(screen, false)` disarms it and the screen goes idle again.

Animation is plain Lua state on top of that clock. `some.animation.start(screen, key, target, dur, from)` begins easing a named value toward a target (ease-out cubic, 0.15 seconds by default), arming the screen's tick if it was idle. `some.animation.get(key, default)` returns the eased value mid-flight and the caller's own value once settled. Declarations read `get` where they would read the raw value, so an animated frame is just an ordinary frame that happened to read an in-between number. When the last animation on a screen finishes, its tick disarms automatically.

C holds none of this: no easing curves, no animation state, no durations. The clock is the only C mechanism; the motion is your Lua. The stdlib uses the same machinery for its own effects, like the tag-switch reveal and the master-split slide.

## See also

- [The Clay Thesis](/kiln/concepts/the-clay-thesis)
- [The Object Model](/kiln/concepts/object-model)
- [The C/Lua Boundary](/kiln/concepts/c-lua-boundary)
- [Widgets tutorial](/kiln/tutorials/widgets)
- [core reference](/kiln/reference/core)
