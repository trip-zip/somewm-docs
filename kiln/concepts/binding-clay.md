---
title: Binding Clay (C baseline)
description: "How the retired C implementation drove Clay from Lua: one context per output, declarations over FFI, and a client window as a CUSTOM leaf."
sidebar_position: 9
---

# Binding Clay

:::info
This page describes kiln's earlier C implementation, which has been replaced. The current Odin compositor uses the same model but none of this code; see [One tree per screen](/kiln/concepts/one-tree). The Clay behaviours under [What we learned about Clay](#what-we-learned-about-clay) are upstream Clay facts and still apply.
:::

The C implementation vendored [Clay](https://github.com/nicbarker/clay) v0.14 at `third_party/clay.h`, byte for byte identical to upstream. Nothing in the header was patched, and there was no fork. Everything that would normally have been a patch was done around the header instead.

## One context per output

Each output got its own `Clay_Context`, arena, and render state, created in `ui.c`:

- The arena was `malloc`ed at `Clay_MinMemorySize()`, sized by a one-time `Clay_SetMaxElementCount(32768)`. That worked out to roughly 24 MB per output, against about 6 MB at Clay's default of 8192. Unused elements cost nothing, and the cap was set high so the stress harness could push node counts up.
- The error handler logged and aborted. A Clay error, render command array overflow included, was treated as a bug rather than a condition to ride out.
- The lockscreen got a **second** context per output, built lazily on first lock, so a failed lock declaration could only cost the lock frame and never the desktop.

Solves were dirty-driven, not per-vblank. Marking an output dirty scheduled a frame, and the frame handler returned immediately if nothing had marked it. One solve was:

```
Clay_SetCurrentContext  ->  Clay_SetLayoutDimensions  ->  Clay_BeginLayout
   ->  the Lua frame handler declares the tree  ->  Clay_EndLayout  ->  reconcile
```

If the Lua handler raised, the command array was discarded and the previous scene stayed on screen.

:::note
`Clay_Context` lives *inside* the arena. Clay keeps a global current-context pointer, so the C code nulled it before freeing an arena that it pointed into. Otherwise the next `Clay_MinMemorySize` or `Clay_Initialize` reads freed memory. This still applies to anyone running more than one Clay context in a process.
:::

## Declaring from Lua

The C implementation never used the `CLAY()` macro. The open/configure/close triple was called from Lua over the LuaJIT FFI, in `lua/kiln/cffi.lua`:

- `Clay__OpenElement`
- `Clay__ConfigureOpenElementPtr`, the pointer form, so no struct crossed by value
- `Clay__CloseElement`

There was **one** scratch `Clay_ElementDeclaration` for the entire process. It was `ffi.fill`ed to zero before each element, so an absent field landed on Clay's own default, and it could be reused because Clay copies what it keeps during configure. Nothing was allocated per element per frame.

That made the closure style a thin wrapper over the pair, which was the whole of `ui.row`:

```lua
function ui.row(cfg, children)
    core.open(to_declaration(cfg or {}, "ltr"))
    if children ~= nil then
        children()
    end
    core.close()
end
```

`ui.box` passed no direction and `ui.column` passed `"ttb"`. Calling the child closure between open and close was the equivalent of Clay's `CLAY()` scope.

Only four things stayed in C, because Lua could not do them without boxing a cdata per element per frame: hashing an id, opening a text element (`Clay__StoreTextElementConfig` returns a pointer into Clay's per-frame config array), resolving an image path to a stable cache pointer, and the place-leaf below.

### Two details that only matter from a GC'd language

**Clay borrows pointers into Lua string bytes.** Element `stringId`s and text content are not copied, and the element hashmap keeps those pointers long after the pass ends, because that is what a later `core.hits` reads back. So C installed a fresh anchor table before each declare pass and parked it under the Clay context pointer. Parking this pass's table released the one that same context parked last time, which was exactly when its hashmap stopped pointing at those strings. The key was the context and not the screen name, because a screen had two of them.

**A failed handler can leave elements open.** The Lua side kept a depth counter, but recovery did not use it. C rebalanced by calling `Clay__CloseElement` until Clay's own open-element stack was back to where the pass started, read through a small shim in `clay_impl.c` (`Clay_Context` is only a complete type inside the implementation unit).

## What was exposed {#what-is-exposed}

`core.open` took a table mirroring `Clay_ElementDeclaration` one to one, so the raw Clay shape was reachable from a config. The `ui.*` layer was shorthand over it. This table names which Clay field each prop landed in:

| `ui.*` prop | Clay field |
|---|---|
| `id`, either `"name"` or `{ "name", index }` | `id` |
| `w`, `h`: `"fit"`, `"grow"`, `"25%"`, a number, or a table with `min`/`max` | `layout.sizing` |
| `pad` | `layout.padding` |
| `gap` | `layout.childGap` |
| `align` | `layout.childAlignment` |
| constructor choice (`ui.row` / `ui.column`) | `layout.layoutDirection` |
| `color` | `backgroundColor` |
| `radius` | `cornerRadius` |
| `border`, with `between` for the inter-child rule | `border` |
| `float` | `floating` |
| `aspect` | `aspectRatio` |
| `clip`, including `childOffset` | `clip` |
| `image = { path = ... }` | `image.imageData` |

Every field of the declaration was reachable except `userData`. `floating` was complete, attach points, `clipTo`, `zIndex` and `pointerCaptureMode` included. `custom.customData` was deliberately not settable from Lua, because C claimed it for the next section.

Declaration fields were not validated the way arguments were: a wrong-typed field meant "use the default", silently. The one exception was a table id whose index was not a number, which was rejected because hashing it as 0 would have collapsed every such id onto one hash and tripped `CLAY_ERROR_TYPE_DUPLICATE_ID`.

## A client window was a CUSTOM leaf {#a-client-window-is-a-custom-leaf}

This is where Clay stopped laying out a UI and started laying out a desktop. In `core.c`, the place-leaf set:

- `custom.customData` to the 64-bit client handle, cast through a pointer.
- `id` to `Clay__HashString("core.surface", handle)`, so the retained key was stable frame to frame.

Open, configure and close happened together, because nothing may be a surface's child. Declaring one handle twice in a frame was an error.

At reconcile time, in `render.c`, a `CLAY_RENDER_COMMAND_TYPE_CUSTOM` command cast that pointer back to a handle, resolved it to the client's `wlr_scene_tree`, and:

- reparented that tree under the output's tree on first sight, then asserted the node identity never changed for the toplevel's life
- sent the client an xdg configure when the **size** of the solved box changed
- let position fall out of the same generic node placement every other command got

kiln never drew into a client. A titlebar and the window under it were siblings that differed only in who supplied the pixels.

There was one deliberate asymmetry: `CUSTOM` was exempt from the scissor stack, so a client popup that overhung its box was not cropped. Only rectangles, text and images clipped.

## Reconciling render commands

The renderer was retained and incremental, and the diff key was Clay's own:

```c
uint64_t key = (uint64_t)cmd->commandType << 32 | cmd->id;
```

Change detection was per property, so text re-rastered only when content, solved size, scale, ellipsis bound or style changed, and re-cropped without re-rastering when only the clip moved. An identical frame produced **zero** scene mutations. Any retained node not touched this pass was swept, which returned borrowed client trees home.

Two verifiers ran on every reconcile and aborted on divergence:

- every declared node was enabled, positioned at its clipped box, sized to it, and inside its clip scope
- scene sibling order equalled command order

A third check, that the scene and Clay named the same widget leaf under the cursor, was sampled on pointer motion but only when `KILN_AGREE` was set, since it walked the scene and ran a Clay pointer query on every motion event.

## Measuring text

`Clay_SetMeasureTextFunction` pointed at a Pango callback. The C code kept no measurement cache of its own, because Clay already caches measured words across frames with generational eviction, so the callback only ran on misses and had to stay pure.

- **Measured at device size, reported in logical pixels.** Pango rounds glyph advances to whole device pixels, so dividing the device extent by the scale handed Clay the exact logical size the raster would reproduce. The raster resolved the same way, so wrap and draw agreed to the pixel.
- **Never width-bounded**, whatever the declaration asked for. What a truncated run was bounded *by* was derived from the box the measurement produced, so bounding the measurement would have fed that derivation its own output.
- **Clay carries only a `fontId`**, so the C code kept a write-once font table. Entries were appended and never rewritten, because Clay's measure cache keys on the id and a rewritten entry would have left that cache answering with the old face's widths forever. Entry 0 was `Sans`, because Clay's debug view passes `fontId` 0 for its own text.

## Hit testing

Widget hit testing was Clay's answer, read from the last solve. `ui.c` called `Clay_SetPointerState` and then `Clay_GetPointerOverIds`, and reversed the array, since Clay lists ancestors first and innermost-first is the natural dispatch order. Lua walked that list and fired the first element carrying a handler for the edge in question.

Client surfaces were arbitration territory: the scene overrode Clay there by design, which is what let a client popup overhang its box.

:::warning
`Clay_GetElementData` is not a liveness test. Clay's element hashmap is persistent memory and the lookup never consults generation, so an id that left the tree keeps answering with its final box. The C implementation exposed it as `core.box` and documented absence as something to assert through `core.hits`, which only names what the live tree put under a point.
:::

## The debug panel was Clay's own {#the-debug-panel-is-clays-own}

`Clay_SetDebugModeEnabled` was wired straight through to a keybinding, so the inspector was the one that ships in `clay.h`, not a reimplementation. It drew over the live desktop and walked the tree that had just laid out the screen. The current inspector is described in [Inspect the Live Element Tree](/kiln/guides/inspector).

Two things had to be built around it, both because Clay's debug view assumes it owns the frame:

- Clay's debug palette globals are defined in the implementation but never declared in the header, so `ui.c` re-declared them as externs to expose panel colours and width to a config. They are process-wide, so restyling marked every screen showing the panel dirty.
- The panel can close itself from inside `Clay_EndLayout`, via its own header button. Clay's `debugModeEnabled` was therefore the state of record and the C flag was only a gate, resynced wherever a self-close was observable. `core.inspector` read the answer back from Clay rather than returning a stored copy.

## What we learned about Clay

Three behaviors that cost real debugging time and are not obvious from the API:

**Pointer state is an edge machine, so forcing an absolute state takes two calls.** The transition is a pure function of the previous state and the new `down` flag, so two consecutive `Clay_SetPointerState` calls pin any state regardless of what other callers left behind: `(up, down)` is the only `PRESSED_THIS_FRAME`, `(down, down)` is `PRESSED`, `(up, up)` is `RELEASED`. kiln needs this because its own hit-test queries advance the same machine.

**`Clay_UpdateScrollContainers` must be called exactly once per solve.** It drops every scroll container that has not been declared since the last call, so a second call in the same pass purges the panes of the debug panel that is mid-declaration. kiln accumulates wheel deltas between solves so that once is enough.

**A `SCISSOR_START` naming neither axis means both axes clip, not neither.** Clay emits that command from two places: a clip element, which fills in its own two bools, and a floating element whose `clipTo` names an ancestor clip, which fills in nothing at all and hands over the ancestor's box. Reading the second as "no axis clips" makes the scene draw content Clay says is not there. Clay's own hit test clips such a root on both axes, so scissoring unconditionally is the only reading that matches the solver.

## See also

- [One tree per screen](/kiln/concepts/one-tree)
- [Frames and Dirty State](/kiln/concepts/frames-and-dirty)
- [The Native/Lua Boundary](/kiln/concepts/c-lua-boundary)
- [ui reference](/kiln/reference/ui)
- [core reference](/kiln/reference/core)
