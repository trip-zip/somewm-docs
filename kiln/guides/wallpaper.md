---
title: Wallpaper
description: Set a wallpaper with a single image node in the background band, per screen or per tag, with a solid color fallback.
sidebar_position: 10
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Wallpaper

<YouWillLearn>

- How a wallpaper is one declared box, not a compositor feature
- The default config's `KILN_WALLPAPER` recipe
- Per-screen and per-tag wallpaper variants
- A solid color fallback when no image is set

</YouWillLearn>

Snippets assume the standard config preamble:

```lua
local some = require("somewm")
local ui = some.ui
local th = some.theme
```

kiln has no wallpaper object and no wallpaper API. A wallpaper is an image-filled box floated to the root in the `background` band, the lowest z range, so it sits behind every client and every piece of chrome. You declare it in your bar function like everything else on screen.

## The recipe

Declare a `ui.box` with an image fill, floated to the root, sized to the screen:

```lua
ui.box({
  id = "wallpaper",
  image = { path = wp },
  float = { to = "root", band = "background", passthrough = true },
  w = s.width, h = s.height,
})
```

Three things make this work:

- **The band.** `band = "background"` puts the float below the in-flow tree (clients, bar, everything). See [nodes, floats, and bands](/kiln/concepts/nodes-floats-and-bands).
- **The size.** `s.width` and `s.height` are the screen's logical size, so one declaration fills the output at any scale. On a HiDPI panel the image is rasterized to physical pixels per output; give it a source at least as large as your largest panel's physical resolution and it stays sharp.
- **`passthrough = true`.** A full-screen float normally captures pointer hits, which would block clicks on the bar and the desktop. With passthrough it stays visible but never blocks; it can still carry its own handlers (a scroll handler, for example).

The image is decoded once and cached by its path. Declaring it every frame costs one lookup. To change the wallpaper, change the path; the next frame reads the new file. If you overwrite the same file in place, drop the stale cache entry with `some.image_reload(path)`.

## The default config's version

kiln's bundled config reads the path from the `KILN_WALLPAPER` environment variable and declares the box at the top of its bar function, before the bar's own widgets:

```lua
screen.on("added", function(s)
  -- tags ...
  ui.bar(s, { edge = "top", color = th.bg }, function()
    local wp = os.getenv("KILN_WALLPAPER")
    if wp ~= nil and wp ~= "" then
      ui.box({
        id = "wallpaper",
        image = { path = wp },
        float = { to = "root", band = "background", passthrough = true },
        w = s.width, h = s.height,
      })
    end
    -- taglist, tasklist, clock ...
  end)
end)
```

Declaring it inside the bar function does not put it inside the bar: `to = "root"` attaches the float to the root of the screen's tree. The bar function is simply the per-frame declare hook a config owns.

Launch with:

```bash
KILN_WALLPAPER=~/Pictures/wall.png kiln
```

## Solid color fallback

A backdrop does not need an image at all. Give the box a color, and add the image fill only when a path is set:

```lua
local wp = os.getenv("KILN_WALLPAPER")
ui.box({
  id = "backdrop",
  float = { to = "root", band = "background", passthrough = true },
  w = s.width, h = s.height,
  color = th.bg,
  image = (wp ~= nil and wp ~= "") and { path = wp } or nil,
})
```

This is what the full bundled config does: the solid color always renders, and the image covers it when present. A backdrop like this is also a natural place for a desktop scroll handler (`on_scroll` to cycle tags, for example), since it catches events over empty workarea even with passthrough set.

## Per-screen wallpapers

The bar function runs once per screen with `s` in scope, so a per-screen wallpaper is a table keyed by output name:

```lua
local walls = {
  ["eDP-1"] = os.getenv("HOME") .. "/Pictures/laptop.png",
  ["DP-3"]  = os.getenv("HOME") .. "/Pictures/desk.png",
}

-- inside the bar function:
local wp = walls[s.name] or os.getenv("KILN_WALLPAPER")
```

## Per-tag wallpapers

The declare runs every frame, so a wallpaper that follows the selected tag is just a read of `s.selected_tag`:

```lua
local tag_walls = {
  dev = os.getenv("HOME") .. "/Pictures/dev.png",
  web = os.getenv("HOME") .. "/Pictures/web.png",
}

-- inside the bar function:
local t = s.selected_tag
local wp = (t ~= nil and tag_walls[t.name]) or os.getenv("KILN_WALLPAPER")
```

Switching tags redraws the screen, and the next declare picks the new path. There is nothing to invalidate: each path is its own cache entry.

:::note
An external wallpaper daemon (swaybg and friends) still works: a layer-shell surface on the background layer lands in the same band and composites into the same frame. The recipe above is the native alternative, one image node instead of a second process.
:::

## See also

- [Nodes, floats, and bands](/kiln/concepts/nodes-floats-and-bands)
- [ui reference](/kiln/reference/ui)
- [Screenshots](/kiln/guides/screenshots), the same move in reverse: the screen as an image
- [Environment and IPC reference](/kiln/reference/environment-and-ipc)
