---
title: Screenshots
description: Capture full outputs with core.screenshot and regions with grim and slurp, all from keybindings.
sidebar_position: 11
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Screenshots

<YouWillLearn>

- Saving a full output to PNG with `core.screenshot`
- Binding Print and Shift+Print for full and region captures
- Region capture with grim and slurp through `some.spawn`
- Using a capture as a live image source, no file involved

</YouWillLearn>

Snippets assume the standard config preamble:

```lua
local some = require("somewm")
local ui, key = some.ui, some.key
```

kiln has no screenshot object, format menu, or naming scheme. A screenshot is one function call: `core.screenshot(name[, path])` reads back the composed scene of one output, everything the frame holds (clients, chrome, wallpaper). Everything else (which screen, which file, which key) is your config.

## The primitive

```lua
local key = core.screenshot(screen.focused.name)
-- key == "screenshot:3", or nil if the output name is stale
```

The return value is an image-cache key: anywhere a file path works as an image source, this key works too. An unknown or unplugged output name returns `nil`; it never errors.

With a second argument, the capture is also written out as a PNG:

```lua
core.screenshot(screen.focused.name, "/tmp/shot.png")
```

Files land exactly where the path points. There is no default directory, so build the path yourself.

## Full output on Print

Bind a key, stamp a filename with `os.date`, and call the save form:

```lua
key { mods = {}, key = "Print", desc = "screenshot", group = "screenshot",
  press = function()
    local dir = os.getenv("HOME") .. "/Pictures"
    local dest = dir .. os.date("/screenshot-%Y%m%d-%H%M%S.png")
    core.screenshot(screen.focused.name, dest)
  end }
```

The directory, the timestamp format, and the trigger key are all yours to change. Add a `some.spawn("notify-send ...")` after the call if you want confirmation, or pipe the path to a clipboard tool.

:::note
`core.screenshot` is the one place these recipes reach below the `some` API into the [core boundary](/kiln/reference/core). That is by design: reading back composed pixels is a compositor fact, and this is its single entry point.
:::

## Region capture with grim and slurp

For a region, use the standard Wayland pair: `slurp` draws an interactive selection, `grim` captures the geometry it prints. Spawn them as one shell pipeline:

```lua
key { mods = { "shift" }, key = "Print", desc = "screenshot region",
  group = "screenshot",
  press = function()
    some.spawn("mkdir -p ~/Pictures && slurp | grim -g - " ..
      "~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png")
  end }
```

`some.spawn` with a string runs the command through `sh -c`, so the pipe, the `&&`, and the `$(date ...)` stamp all work as written. This is the bundled config's binding.

## An interactive-ish region bind

If you prefer a dedicated chord for deliberate, mouse-driven captures (separate from the reflex Shift+Print), bind the same pipeline to something like mod+ctrl+p:

```lua
key { mods = { "mod", "ctrl" }, key = "p", desc = "interactive screenshot",
  group = "screenshot",
  press = function()
    some.spawn("mkdir -p ~/Pictures && slurp | grim -g - " ..
      "~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png")
  end }
```

When it fires, the desktop dims under slurp's selection overlay; drag a rectangle and the file appears in `~/Pictures`. Press Escape in slurp to abort, in which case grim never runs and nothing is written.

## The capture as a live image

Because the return value is a cache key, a screenshot is usable as an image in the very frame it was taken, with no file at all. Capture the screen, then declare the key as a float's image fill:

```lua
local frozen = core.screenshot(s.name)
if frozen ~= nil then
  ui.box({
    id = "freeze",
    image = { path = frozen },
    float = { to = "root", band = "overlay" },
    w = s.width, h = s.height,
  })
end
```

That is the substrate for a freeze-frame to draw over: a dimmed backdrop for a custom lock screen, a zoom loupe, or a transition that holds the old scene while a new one builds. The [wallpaper](/kiln/guides/wallpaper) recipe is the same move in the other direction: an image into a band. Here the image is the screen itself.

## See also

- [core reference](/kiln/reference/core)
- [Wallpaper](/kiln/guides/wallpaper)
- [Keybindings tutorial](/kiln/tutorials/keybindings)
- [Testing headless](/kiln/guides/testing-headless), where screenshots verify what a config drew
