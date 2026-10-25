---
title: Screenshots
description: Capture full outputs with core.screenshot and regions with grim and slurp, all from keybindings.
sidebar_position: 12
---

# Screenshots

kiln has no screenshot object, format menu, or naming scheme. A screenshot is one function call: `core.screenshot(name[, path])` reads back the composed scene of one output, everything the frame holds (clients, widgets, wallpaper). Everything else (which screen, which file, which key) is your config.

Snippets assume the standard config preamble:

```lua
local kiln = require("kiln")
local ui, key = kiln.ui, kiln.key
```

## The primitive

```lua
local shot = core.screenshot(screen.focused.name)
-- shot == "screenshot:3", or nil if the output name is stale
```

The return value is an image-cache key: anywhere a file path works as an image source, this key works too. An unknown or unplugged output name returns `nil`; it never errors. Called during a declare (inside a bar function or a layout), it captures nothing and returns `nil`.

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

The directory, the timestamp format, and the trigger key are all yours to change. Add a `kiln.spawn("notify-send ...")` after the call if you want confirmation, or pipe the path to a clipboard tool.

:::note
`core.screenshot` is the one place these recipes reach below the `kiln` API into the [core boundary](/kiln/reference/core).
:::

## Region capture with grim and slurp

<a id="an-interactive-ish-region-bind"></a>

For a region, use the standard Wayland pair: `slurp` draws an interactive selection, `grim` captures the geometry it prints. Spawn them as one shell pipeline:

```lua
key { mods = { "shift" }, key = "Print", desc = "screenshot region",
  group = "screenshot",
  press = function()
    kiln.spawn("mkdir -p ~/Pictures && slurp | grim -g - " ..
      "~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png")
  end }
```

`kiln.spawn` with a string runs the command through `sh -c`, so the pipe, the `&&`, and the `$(date ...)` stamp all work as written. This is the bundled config's binding; the default config binds the same pipeline to `mod+ctrl+p` as well. The desktop dims under slurp's selection overlay; drag a rectangle and the file appears in `~/Pictures`. Press Escape in slurp to abort, in which case grim never runs and nothing is written.

## The capture as a live image

Because the return value is a cache key, a screenshot is usable as an image with no file at all. Capture from a keybinding or a timer (never from inside a declare), store the key, mark the screen dirty, and declare the stored key as a float's image fill:

```lua
local frozen = nil   -- image key of the last capture, or nil

key { mods = { "mod", "shift" }, key = "Print", desc = "freeze frame",
  group = "screenshot",
  press = function()
    if frozen ~= nil then
      frozen = nil
    else
      frozen = core.screenshot(screen.focused.name)
    end
    kiln.dirty()
  end }

-- inside the bar function:
if frozen ~= nil then
  ui.box({
    id = "freeze",
    image = { path = frozen },
    float = { to = "root", band = "overlay" },
    w = s.width, h = s.height,
    on_press = function()
      frozen = nil
      kiln.dirty()
    end,
  })
end
```

The first press captures and the overlay appears on the next frame; the second press, or a click on it, removes it. Use it as a backdrop for overlays that should show the screen as it was: a dimmed backdrop for a custom lock screen, a zoom loupe, or a transition that holds the old scene while a new one builds. The [wallpaper](/kiln/guides/wallpaper) recipe is the same move in the other direction: an image into a band. Here the image is the screen itself.

## See also

- [core reference](/kiln/reference/core)
- [Wallpaper](/kiln/guides/wallpaper)
- [Keybindings tutorial](/kiln/tutorials/keybindings)
- [Testing headless](/kiln/guides/testing-headless), where screenshots verify what a config drew
