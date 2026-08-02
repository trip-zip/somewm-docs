---
sidebar_position: 11
title: Wallpaper Caching
description: Speed up tag switching with per-tag wallpapers
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Wallpaper Caching <SomewmOnly />

SomeWM caches wallpaper textures to make tag switching instant when using per-tag wallpapers.

## Automatic Caching

If you use `gears.wallpaper.maximized()` with file paths, caching works automatically:

```lua
-- rc.lua
local tag_wallpapers = {
    [1] = "/home/user/wallpapers/mountains.jpg",
    [2] = "/home/user/wallpapers/forest.png",
    [3] = "/home/user/wallpapers/ocean.jpg",
}

local function set_wallpaper_for_tag(t)
    if not t or not t.selected then return end
    local wp = tag_wallpapers[t.index]
    if wp then
        gears.wallpaper.maximized(wp, t.screen, true)
    end
end

tag.connect_signal("property::selected", function(t)
    set_wallpaper_for_tag(t)
end)
```

The first time you visit a tag, the wallpaper loads normally (~20ms). Every subsequent visit is instant (~0.1ms) because SomeWM reuses the cached GPU texture.

## Preloading Wallpapers

For instant first-switch too, preload wallpapers at startup:

```lua
-- Preload all wallpapers into cache (screen defaults to primary)
root.wallpaper_cache_preload({
    "/home/user/wallpapers/mountains.jpg",
    "/home/user/wallpapers/forest.png",
    "/home/user/wallpapers/ocean.jpg",
})

-- For multi-monitor, preload per screen:
for s in screen do
    root.wallpaper_cache_preload(my_wallpaper_list, s)
end
```

This loads all images during startup so even the first visit to each tag is instant. `root.wallpaper_cache_has(path, s)` tells you whether a wallpaper is already cached.

## Multi-Monitor Support

The cache is per-screen. Each screen has its own set of cached wallpapers, so switching tags on one screen doesn't affect wallpapers on other screens.

```lua
-- With multiple screens, each gets its own wallpaper cache
tag.connect_signal("property::selected", function(t)
    if not t or not t.selected then return end
    local wp = tag_wallpapers[t.index]
    if wp then
        -- This caches separately for t.screen
        gears.wallpaper.maximized(wp, t.screen, true)
    end
end)
```

## Freeing Memory

Cached wallpapers live in GPU memory. The cache holds up to 32 entries (all screens combined) and evicts the least recently used when full, so a typical multi-tag setup fits comfortably. If memory is tight (many unique 4K wallpapers), free everything and let it rebuild as you switch tags:

```lua
root.wallpaper_cache_clear()
```

The memory arithmetic and eviction design are covered in [Wallpaper Caching Concepts](/docs/concepts/wallpaper-caching).

## What Gets Cached

Only `gears.wallpaper.maximized()` calls with **file paths** are cached:

```lua
-- Cached (file path)
gears.wallpaper.maximized("/path/to/image.jpg", s, true)

-- NOT cached (cairo surface)
local surf = gears.surface.load("/path/to/image.jpg")
gears.wallpaper.maximized(surf, s, true)

-- NOT cached (solid color)
gears.wallpaper.set("#282828")
```

Other wallpaper functions (`centered`, `tiled`, `fit`) are not currently cached.

## Troubleshooting

### Wallpaper Not Caching

Ensure you're passing a file path string directly to `gears.wallpaper.maximized()`:

```lua
-- Works: direct path
gears.wallpaper.maximized("/path/to/wallpaper.jpg", s, true)

-- Doesn't work: loaded surface
local surf = gears.surface("/path/to/wallpaper.jpg")
gears.wallpaper.maximized(surf, s, true)
```

### Cache Not Persisting

The cache only lives in memory. It's cleared when SomeWM restarts. Use `root.wallpaper_cache_preload()` in your rc.lua to rebuild it at startup.

### High Memory Usage

If GPU memory is a concern:

1. Use fewer unique wallpapers
2. Use lower resolution images
3. Call `root.wallpaper_cache_clear()` periodically

## See Also

- [Wallpaper Caching Concepts](/docs/concepts/wallpaper-caching) - How caching works under the hood
- [Wayland vs X11](/docs/concepts/wayland-vs-x11) - Why caching is needed on Wayland
