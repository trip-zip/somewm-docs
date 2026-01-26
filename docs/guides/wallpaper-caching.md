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
-- Preload all wallpapers into cache
root.wallpaper_cache_preload({
    "/home/user/wallpapers/mountains.jpg",
    "/home/user/wallpapers/forest.png",
    "/home/user/wallpapers/ocean.jpg",
})
```

This loads all images during startup so even the first visit to each tag is instant.

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

## Cache API

SomeWM provides four functions for cache control:

### Check if Cached

```lua
-- Check if wallpaper is cached for a specific screen
if root.wallpaper_cache_has("/path/to/wallpaper.jpg", screen.primary) then
    -- Already in cache for this screen
end
```

### Show Cached Wallpaper

```lua
-- Returns true if cache hit, false if not cached
-- You normally don't need to call this directly
local hit = root.wallpaper_cache_show("/path/to/wallpaper.jpg", screen.primary)
```

This is used internally by the automatic caching.

### Preload Multiple Wallpapers

```lua
-- Preload wallpapers for a specific screen
-- Screen defaults to primary if not specified
local count = root.wallpaper_cache_preload({
    "/path/to/image1.jpg",
    "/path/to/image2.png",
    "/path/to/image3.jpg",
}, screen.primary)
print("Preloaded " .. count .. " wallpapers")

-- For multi-monitor, preload for each screen:
for s in screen do
    root.wallpaper_cache_preload({
        tag_wallpapers[1],
        tag_wallpapers[2],
        -- ...
    }, s)
end
```

### Clear Cache

```lua
-- Free all cached wallpaper textures (all screens)
root.wallpaper_cache_clear()
```

Use this to free GPU memory if needed. The cache will rebuild as you switch tags.

## Cache Limits

The cache holds up to 32 wallpapers total (all screens combined). With a typical 2-screen setup and 9 tags each, that's 18 wallpapers which fits comfortably.

When the cache is full, the least recently used wallpaper is evicted to make room for new ones.

## Memory Usage

Each cached wallpaper uses GPU memory:

| Resolution | Memory per Wallpaper |
|------------|---------------------|
| 1920x1080 | ~8 MB |
| 2560x1440 | ~15 MB |
| 3840x2160 | ~33 MB |

With 16 cached 1080p wallpapers, expect ~128 MB of GPU memory usage. For 4K displays, consider reducing the number of unique wallpapers or clearing the cache when memory is tight.

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

- [Wallpaper Caching Concepts](/concepts/wallpaper-caching) - How caching works under the hood
- [Wayland vs X11](/concepts/wayland-vs-x11) - Why caching is needed on Wayland
