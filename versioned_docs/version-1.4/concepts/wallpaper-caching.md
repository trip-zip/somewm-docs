---
sidebar_position: 8
title: Wallpaper Caching
description: What wallpaper caching reuses, how entries are keyed and when to clear it.
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Wallpaper Caching <SomewmOnly />

SomeWM 1.4 caches wallpapers set with `gears.wallpaper.maximized(path, screen, ...)`. Returning to a cached path on the same screen can show an existing scene node without decoding and painting the image again.

## The Problem

<span id="x11-vs-wayland" />
<span id="x11-awesomewm" />
<span id="wayland-somewm-without-caching" />

Changing a wallpaper can involve file reading, image decoding, Cairo painting and creating a scene buffer. Repeating those steps on every tag change adds work to the compositor's main thread.

The benefit depends on image size, storage and renderer. There is no fixed switching time or speedup guaranteed by the cache.

## The Solution: Scene Node Caching

<span id="performance-comparison" />

On a miss, SomeWM creates the wallpaper surface and scene node. On a hit, it hides the previous wallpaper for that screen and enables the cached node. Other screens keep their current wallpapers.

## Short-Circuit at Lua Level

A hook installed in `luaa.c` wraps `gears.wallpaper.maximized`. For a file path and an explicit valid screen, it calls `root.wallpaper_cache_show(path, screen_index)` first. A hit returns before the original Lua function loads or paints the image.

On a miss, the original function runs, and `root.c` records the resulting wallpaper for reuse.

## Per-Screen Caching

The key is the path string and screen index. The same image on two screens has separate entries. Each entry retains the screen-sized surface and its positioned scene node.

### Cache Operations

Lookup scans the cache for a matching path and screen. Showing an entry toggles node visibility. New entries are inserted at the front of the list.

### Eviction {#lru-eviction}

At the 32-entry threshold, insertion removes the oldest inserted entry that is not currently displayed. A cache hit does not move an entry in the list, so this is not least-recently-used eviction. Currently displayed entries are protected.

## Memory Considerations

An ARGB32 image needs approximately `width × height × 4` bytes, before renderer allocations and other overhead:

| Dimensions | Pixel storage per surface |
| --- | --- |
| 1920×1080 | 7.9 MiB |
| 3840×2160 | 31.6 MiB |

Thirty-two 4K surfaces alone use about 1 GiB. Cached surfaces and renderer resources both contribute to total memory use.

## Implementation Details

### Monkey-Patching

The C-installed `require` hook wraps the wallpaper and surface-loading functions when they are loaded. The on-disk Lua module files are not rewritten.

### Cache Key

The cache does not compare file contents, modification times or inodes. Different path strings can produce separate entries for the same file. Replacing a file at the same path leaves the old image cached.

Screen geometry and painting options are not part of the key either. Clear and repaint when changing those inputs if an existing entry would otherwise be reused.

## Limitations

### Only `maximized` is Cached

The shortcut applies to `gears.wallpaper.maximized`. It does not wrap `centered`, `tiled`, `fit` or the default config's `awful.wallpaper` widget renderer.

### File Paths Only

A Cairo surface passed directly has no path key and does not use this shortcut. Pass the screen explicitly when using cached file paths.

### No Invalidation

Call `root.wallpaper_cache_clear()` to remove cached entries, then set the wallpapers again. This also removes currently displayed cached nodes. A full compositor process restart clears the cache. A Lua configuration reload does not reset this C-owned cache.

## See Also

- [Wallpaper Caching Guide](../guides/wallpaper-caching.md)
- [Scene Graph](scene-graph.md)
