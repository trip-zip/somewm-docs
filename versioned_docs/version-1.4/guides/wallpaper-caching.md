---
sidebar_position: 11
title: Wallpaper Caching
description: Speed up tag switching with per-tag wallpapers
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Wallpaper Caching <SomewmOnly />

Use `gears.wallpaper.maximized(path, screen, ...)` with a file path and an explicit screen to cache per-tag wallpapers. The default config's `awful.wallpaper` widget path does not use this cache.

## Automatic Caching

Replace the existing wallpaper handler with this one, using image paths that exist on your machine:

```lua
local gears = require("gears")
local wallpapers = {
    os.getenv("HOME") .. "/wallpapers/mountains.jpg",
    os.getenv("HOME") .. "/wallpapers/forest.png",
    os.getenv("HOME") .. "/wallpapers/ocean.jpg",
}

local function set_wallpaper(s)
    local t = s.selected_tag
    local path = t and wallpapers[t.index]
    if path then gears.wallpaper.maximized(path, s, true) end
end

screen.connect_signal("request::wallpaper", set_wallpaper)
tag.connect_signal("property::selected", function(t)
    if t.selected then set_wallpaper(t.screen) end
end)
for s in screen do set_wallpaper(s) end
```

The first use loads and renders the image. A cache hit reuses it. The key includes the path and screen index, so each screen has separate entries. With several selected tags, this example uses `s.selected_tag`.

## Preloading Wallpapers

<span id="multi-monitor-support" />

Preload after screens exist, using the same `wallpapers` list:

```lua
for s in screen do
    local count = root.wallpaper_cache_preload(wallpapers, s)
    print("Preloaded wallpapers:", count)
end
```

Without the screen argument, preloading uses the primary screen. Preloading performs work immediately, so a large list can delay startup.

## Cache API

### Check if Cached

```lua
local cached = root.wallpaper_cache_has(wallpapers[1], screen.primary)
```

### Show Cached Wallpaper

<span id="preload-multiple-wallpapers" />

```lua
local shown = root.wallpaper_cache_show(wallpapers[1], screen.primary)
```

`show` returns `false` on a miss. Normally, let `gears.wallpaper.maximized` handle this lookup and load the file when needed.

### Clear Cache

The key does not include file modification time, screen geometry or rendering options. After replacing an image or changing output geometry, clear the cache and repaint:

```lua
root.wallpaper_cache_clear()
for s in screen do set_wallpaper(s) end
```

Clearing also removes cached wallpaper scene nodes, including currently displayed ones. Always restore the visible wallpapers afterward.

## Cache Limits

<span id="memory-usage" />

Eviction begins at 32 entries across all screens. It removes the oldest inserted entry that is not currently displayed. Cache hits do not update insertion order, so this is not a least-recently-used cache.

Each entry retains CPU image data as well as renderer resources. A single 3840×2160 RGBA image is about 32 MiB before additional renderer storage. Use fewer unique images if memory use is too high.

## What Gets Cached

The automatic cache applies to file paths passed to `gears.wallpaper.maximized` with an explicit screen. It does not apply to Cairo surfaces, solid colours, `centered`, `tiled`, `fit` or `awful.wallpaper` widget rendering.

## Troubleshooting

<span id="wallpaper-not-caching" />
<span id="cache-not-persisting" />
<span id="high-memory-usage" />

- **File changes do not appear:** clear and repaint as above.
- **No cache hit:** check that the exact path and screen match, and that the entry was not evicted.
- **State survives a reload:** the cache lives in C and survives a Lua reload. Exiting the compositor clears it.
- **Another wallpaper replaces yours:** remove or update the other wallpaper handler.

## See Also

- [Wallpaper Caching](../concepts/wallpaper-caching.md)
- [Wayland and X11](../concepts/wayland-vs-x11.md)
