---
title: Binding Clay
description: "How kiln drives Clay from Lua: one context per output, declarations over FFI, and a client window as a CUSTOM leaf."
sidebar_position: 2
---

# Binding Clay

kiln vendors [Clay](https://github.com/nicbarker/clay) at `third_party/clay.h`, v0.14, byte for byte identical to upstream. Nothing in the header is patched, and there is no fork. Everything that would normally be a patch is done around the header instead.

This page is the engineering detail: how a Lua config ends up calling Clay's element API, and how solved boxes become windows on a screen. For why the whole screen is one tree in the first place, see [The Clay Bet](/kiln/concepts/the-clay-bet).

## One context per output

Each output gets its own `Clay_Context`, arena, and render state, created in `ui.c`:

- The arena is `malloc`ed at `Clay_MinMemorySize()`, sized by a one-time `Clay_SetMaxElementCount(32768)`. That works out to roughly 24 MB per output, against about 6 MB at Clay's default of 8192. Unused elements cost nothing, and the cap is set high so the stress harness can push node counts up.
- The error handler logs and aborts. A Clay error, render command array overflow included, is treated as a bug rather than a condition to ride out.
- The lockscreen gets a **second** context per output, built lazily on first lock, so a failed lock declaration can only cost the lock frame and never the desktop.

Solves are dirty-driven, not per-vblank. Marking an output dirty schedules a frame, and the frame handler returns immediately if nothing marked it. One solve is:

```
Clay_SetCurrentContext  ->  Clay_SetLayoutDimensions  ->  Clay_BeginLayout
   ->  the Lua frame handler declares the tree  ->  Clay_EndLayout  ->  reconcile
```

If the Lua handler raised, the command array is discarded and the previous scene stays on screen.

:::note
`Clay_Context` lives *inside* the arena. Clay keeps a global current-context pointer, so kiln nulls it before freeing an arena that it points into. Otherwise the next `Clay_MinMemorySize` or `Clay_Initialize` reads freed memory. This is worth knowing for anyone running more than one Clay context in a process.
:::

## Declaring from Lua

kiln never uses the `CLAY()` macro. The open/configure/close triple is called from Lua over the LuaJIT FFI, in `lua/kiln/cffi.lua`:

- `Clay__OpenElement`
- `Clay__ConfigureOpenElementPtr`, the pointer form, so no struct crosses by value
- `Clay__CloseElement`

There is **one** scratch `Clay_ElementDeclaration` for the entire process. It is `ffi.fill`ed to zero before each element, so an absent field lands on Clay's own default, and it can be reused because Clay copies what it keeps during configure. Nothing is allocated per element per frame.

That makes the closure style a thin wrapper over the pair, which is the whole of `ui.row` in `lua/kiln/ui.lua`:

```lua
function ui.row(cfg, children)
    core.open(to_declaration(cfg or {}, "ltr"))
    if children ~= nil then
        children()
    end
    core.close()
end
```

`ui.box` passes no direction and `ui.column` passes `"ttb"`. Calling the child closure between open and close is the equivalent of Clay's `CLAY()` scope.

Only four things stayed in C, because Lua cannot do them without boxing a cdata per element per frame: hashing an id, opening a text element (`Clay__StoreTextElementConfig` returns a pointer into Clay's per-frame config array), resolving an image path to a stable cache pointer, and the place-leaf below.

### Two details that only matter from a GC'd language

**Clay borrows pointers into Lua string bytes.** Element `stringId`s and text content are not copied, and the element hashmap keeps those pointers long after the pass ends, because that is what a later `core.hits` reads back. So C installs a fresh anchor table before each declare pass and parks it under the Clay context pointer. Parking this pass's table releases the one that same context parked last time, which is exactly when its hashmap stopped pointing at those strings. The key is the context and not the screen name, because a screen has two of them.

**A failed handler can leave elements open.** The Lua side keeps a depth counter, but recovery does not use it. C rebalances by calling `Clay__CloseElement` until Clay's own open-element stack is back to where the pass started, read through a small shim in `clay_impl.c` (`Clay_Context` is only a complete type inside the implementation unit).

## What is exposed

`core.open` takes a table mirroring `Clay_ElementDeclaration` one to one, so the raw Clay shape is reachable from a config. The `ui.*` layer is shorthand over it:

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

Every field of the declaration is reachable except `userData`. `floating` is complete, attach points, `clipTo`, `zIndex` and `pointerCaptureMode` included. `custom.customData` is deliberately not settable from Lua, because C claims it for the next section.

Declaration fields are not validated the way arguments are: a wrong-typed field means "use the default", silently. The one exception is a table id whose index is not a number, which is rejected because hashing it as 0 would collapse every such id onto one hash and trip `CLAY_ERROR_TYPE_DUPLICATE_ID`.

## A client window is a CUSTOM leaf

This is where Clay stops laying out a UI and starts laying out a desktop. In `core.c`, the place-leaf sets:

- `custom.customData` to the 64-bit client handle, cast through a pointer.
- `id` to `Clay__HashString("core.surface", handle)`, so the retained key is stable frame to frame.

Open, configure and close happen together, because nothing may be a surface's child. Declaring one handle twice in a frame is an error.

At reconcile time, in `render.c`, a `CLAY_RENDER_COMMAND_TYPE_CUSTOM` command casts that pointer back to a handle, resolves it to the client's `wlr_scene_tree`, and:

- reparents that tree under the output's tree on first sight, then asserts the node identity never changes for the toplevel's life
- sends the client an xdg configure when the **size** of the solved box changed
- lets position fall out of the same generic node placement every other command gets

kiln never draws into a client. A titlebar and the window under it are siblings that differ only in who supplies the pixels.

There is one deliberate asymmetry: `CUSTOM` is exempt from the scissor stack, so a client popup that overhangs its box is not cropped. Only rectangles, text and images clip.

## Reconciling render commands

The renderer is retained and incremental, and the diff key is Clay's own:

```c
uint64_t key = (uint64_t)cmd->commandType << 32 | cmd->id;
```

Change detection is per property, so text re-rasters only when content, solved size, scale, ellipsis bound or style changed, and re-crops without re-rastering when only the clip moved. An identical frame produces **zero** scene mutations. Any retained node not touched this pass is swept, which returns borrowed client trees home.

Two verifiers run on every reconcile and abort on divergence:

- every declared node is enabled, positioned at its clipped box, sized to it, and inside its clip scope
- scene sibling order equals command order

A third check, that the scene and Clay name the same widget leaf under the cursor, is sampled on pointer motion but only when `KILN_AGREE` is set, since it walks the scene and runs a Clay pointer query on every motion event.

## Measuring text

`Clay_SetMeasureTextFunction` points at a Pango callback. kiln keeps no measurement cache of its own, because Clay already caches measured words across frames with generational eviction, so the callback only runs on misses and must stay pure.

- **Measured at device size, reported in logical pixels.** Pango rounds glyph advances to whole device pixels, so dividing the device extent by the scale hands Clay the exact logical size the raster will reproduce. The raster resolves the same way, so wrap and draw agree to the pixel.
- **Never width-bounded**, whatever the declaration asked for. What a truncated run is bounded *by* is derived from the box the measurement produces, so bounding the measurement would feed that derivation its own output.
- **Clay carries only a `fontId`**, so kiln keeps a write-once font table. Entries are appended and never rewritten, because Clay's measure cache keys on the id and a rewritten entry would leave that cache answering with the old face's widths forever. Entry 0 is `Sans`, because Clay's debug view passes `fontId` 0 for its own text.

## Hit testing

Widget hit testing is Clay's answer, read from the last solve. `ui.c` calls `Clay_SetPointerState` and then `Clay_GetPointerOverIds`, and reverses the array, since Clay lists ancestors first and innermost-first is the natural dispatch order. Lua walks that list and fires the first element carrying a handler for the edge in question.

Client surfaces are arbitration territory: the scene overrides Clay there by design, which is what lets a client popup overhang its box.

:::warning
`Clay_GetElementData` is not a liveness test. Clay's element hashmap is persistent memory and the lookup never consults generation, so an id that left the tree keeps answering with its final box. kiln exposes it as `core.box` and documents absence as something to assert through `core.hits`, which only names what the live tree put under a point.
:::

## The debug panel is Clay's own

`Clay_SetDebugModeEnabled` is wired straight through to a keybinding, so the inspector kiln opens is the one that ships in `clay.h`, not a reimplementation. It draws over the live desktop and walks the tree that just laid out the screen. See [Inspect the Live Element Tree](/kiln/guides/inspector).

Two things had to be built around it, both because Clay's debug view assumes it owns the frame:

- Clay's debug palette globals are defined in the implementation but never declared in the header, so `ui.c` re-declares them as externs to expose panel colours and width to a config. They are process-wide, so restyling marks every screen showing the panel dirty.
- The panel can close itself from inside `Clay_EndLayout`, via its own header button. Clay's `debugModeEnabled` is therefore the state of record and kiln's own flag is only a gate, resynced wherever a self-close is observable. `core.inspector` reads the answer back from Clay rather than returning a stored copy.

## What we learned about Clay

Three behaviors that cost real debugging time and are not obvious from the API:

**Pointer state is an edge machine, so forcing an absolute state takes two calls.** The transition is a pure function of the previous state and the new `down` flag, so two consecutive `Clay_SetPointerState` calls pin any state regardless of what other callers left behind: `(up, down)` is the only `PRESSED_THIS_FRAME`, `(down, down)` is `PRESSED`, `(up, up)` is `RELEASED`. kiln needs this because its own hit-test queries advance the same machine.

**`Clay_UpdateScrollContainers` must be called exactly once per solve.** It drops every scroll container that has not been declared since the last call, so a second call in the same pass purges the panes of the debug panel that is mid-declaration. kiln accumulates wheel deltas between solves so that once is enough.

**A `SCISSOR_START` naming neither axis means both axes clip, not neither.** Clay emits that command from two places: a clip element, which fills in its own two bools, and a floating element whose `clipTo` names an ancestor clip, which fills in nothing at all and hands over the ancestor's box. Reading the second as "no axis clips" makes the scene draw content Clay says is not there. Clay's own hit test clips such a root on both axes, so scissoring unconditionally is the only reading that matches the solver.

## See also

- [The Clay Bet](/kiln/concepts/the-clay-bet)
- [Frames and Dirty State](/kiln/concepts/frames-and-dirty)
- [The C/Lua Boundary](/kiln/concepts/c-lua-boundary)
- [ui reference](/kiln/reference/ui)
- [core reference](/kiln/reference/core)
