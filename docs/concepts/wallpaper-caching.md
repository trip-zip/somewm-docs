---
sidebar_position: 8
title: Wallpaper Caching
description: How SomeWM caches wallpapers for instant switching
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Wallpaper Caching <SomewmOnly />

This page explains how SomeWM caches wallpaper textures and why it matters for performance.

## The Problem

A common configuration is to have different wallpapers per tag. When you switch tags, the wallpaper changes:

```lua
tag.connect_signal("property::selected", function(t)
    gears.wallpaper.maximized(tag_wallpapers[t.index], t.screen, true)
end)
```

Without caching, every tag switch triggers this expensive pipeline:

1. **Load image from disk** - Read file, decompress PNG/JPEG (~5ms)
2. **Create cairo surface** - Allocate memory, decode pixels (~2ms)
3. **Scale to screen size** - Cairo paint operation (~3ms)
4. **Create GPU texture** - Upload to wlroots scene buffer (~5ms)
5. **Destroy old texture** - Free previous wallpaper

Total: **~15-25ms per switch**

At 60fps, a frame is 16.6ms. Wallpaper switching alone can cause dropped frames and visible lag.

## X11 vs Wayland

### X11 (AwesomeWM)

On X11, wallpapers are fast because of how the display server works:

```
App creates pixmap → X Server stores in VRAM → Switch = change property
```

The X Server keeps pixmaps in video memory. "Switching" wallpapers just changes which pixmap is displayed. No re-uploading, no re-decoding.

### Wayland (SomeWM without caching)

Wayland compositors manage their own buffers:

```
Each switch: Load file → Decode → Create buffer → Upload to GPU → Destroy old
```

There's no persistent pixmap storage. Every wallpaper change re-does all the work.

## The Solution: Scene Node Caching

SomeWM caches wallpapers at the GPU texture level:

```
First visit:  Load → Decode → Create scene node → Hide node
Cache hit:    Show cached node (toggle visibility)
```

Instead of destroying wallpaper textures, SomeWM keeps them in a cache and toggles their visibility:

```c
// Cache miss: create new texture (~20ms)
scene_node = wlr_scene_buffer_create(layer, buffer);
wlr_scene_node_set_enabled(&scene_node->node, false);  // Hidden until shown

// Cache hit: just toggle visibility (~0.1ms)
wlr_scene_node_set_enabled(&old_node->node, false);    // Hide current
wlr_scene_node_set_enabled(&cached_node->node, true);  // Show cached
```

### Performance Comparison

| Operation | Without Cache | With Cache |
|-----------|--------------|------------|
| First visit | ~20ms | ~20ms |
| Subsequent visits | ~20ms | **~0.1ms** |
| Speedup | - | **~200x** |

## Short-Circuit at Lua Level

Caching GPU textures alone isn't enough. The Lua code still runs expensive operations:

```lua
-- gears.wallpaper.maximized does all this work:
function wallpaper.maximized(surf, s, ignore_aspect, offset)
    local geom, cr = wallpaper.prepare_context(s)  -- Create cairo context
    surf = surface.load_uncached(surf)              -- Load image from disk!
    -- ... scale, paint, etc.
    root._wallpaper(pattern)                        -- Finally call C
end
```

Even with C-side caching, Lua still loads and decodes the image every time.

SomeWM solves this by patching `gears.wallpaper.maximized` to check the cache first:

```lua
-- Patched version (simplified)
function wallpaper.maximized(surf, s, ...)
    if type(surf) == "string" and root.wallpaper_cache_show(surf) then
        return  -- Cache hit! Skip everything
    end
    -- Cache miss: fall through to original implementation
    return original_maximized(surf, s, ...)
end
```

On cache hit, we skip:
- File I/O
- Image decoding
- Cairo surface creation
- Scaling and painting
- Pattern creation

The entire Lua pipeline is bypassed.

## Cache Structure

The cache is a simple LRU (Least Recently Used) list:

```c
typedef struct wallpaper_cache_entry {
    struct wl_list link;              // Linked list for LRU ordering
    char *path;                       // Filepath as cache key
    struct wlr_scene_buffer *scene_node;  // GPU texture (hidden when not active)
    cairo_surface_t *surface;         // For getter compatibility
} wallpaper_cache_entry_t;
```

### Cache Operations

| Operation | Complexity | Description |
|-----------|------------|-------------|
| Lookup | O(n) | Linear scan by filepath |
| Insert | O(1) | Add to head of list |
| Evict | O(n) | Remove tail (oldest) |
| Show | O(1) | Toggle visibility flags |

With a max of 16 entries, O(n) operations are fast enough.

### LRU Eviction

When the cache is full (16 entries), the least recently used wallpaper is evicted:

```c
void wallpaper_cache_evict_oldest(void) {
    // Find oldest (tail of list, excluding current)
    wallpaper_cache_entry_t *oldest = NULL;
    wl_list_for_each(entry, &cache, link) {
        if (entry != current_wallpaper)
            oldest = entry;
    }

    if (oldest) {
        wlr_scene_node_destroy(&oldest->scene_node->node);
        // ... cleanup
    }
}
```

## Memory Considerations

Each cached wallpaper consumes GPU memory:

```
Memory = width × height × 4 bytes (ARGB32)

1920×1080 = 8,294,400 bytes ≈ 8 MB
3840×2160 = 33,177,600 bytes ≈ 32 MB
```

With 16 cached wallpapers:
- 1080p: ~128 MB GPU memory
- 4K: ~512 MB GPU memory

This is typically acceptable for modern GPUs, but users with many 4K wallpapers should be mindful of memory usage.

## Implementation Details

### Monkey-Patching

SomeWM patches Lua modules at startup without modifying the sacred Lua files:

```c
// In luaA_loadrc(), before loading rc.lua:
luaL_dostring(L,
    "local orig_require = require\n"
    "require = function(name)\n"
    "    local mod = orig_require(name)\n"
    "    if name == 'gears.wallpaper' then\n"
    "        -- Patch maximized to check cache first\n"
    "    end\n"
    "    return mod\n"
    "end\n"
);
```

This intercepts `require('gears.wallpaper')` and wraps the `maximized` function.

### Cache Key

The filepath string is used as the cache key:

```c
static wallpaper_cache_entry_t *wallpaper_cache_lookup(const char *path) {
    wallpaper_cache_entry_t *entry;
    wl_list_for_each(entry, &cache, link) {
        if (strcmp(entry->path, path) == 0)
            return entry;
    }
    return NULL;
}
```

This means:
- Same file path = cache hit
- Different path to same file = cache miss (no inode checking)
- Modified file = stale cache (no mtime checking)

For typical use cases (static wallpaper files), this is sufficient.

## Limitations

### Only `maximized` is Cached

Currently only `gears.wallpaper.maximized()` benefits from caching. Other functions are not patched:

- `gears.wallpaper.centered()` - Not cached
- `gears.wallpaper.tiled()` - Not cached
- `gears.wallpaper.fit()` - Not cached

### File Paths Only

Caching requires a file path string as the cache key:

```lua
-- Cached
gears.wallpaper.maximized("/path/to/image.jpg", s, true)

-- NOT cached (no cache key)
gears.wallpaper.maximized(some_cairo_surface, s, true)
```

### No Invalidation

The cache doesn't detect when files change on disk. If you modify a wallpaper file, you need to either:

1. Restart SomeWM
2. Call `root.wallpaper_cache_clear()` manually

## See Also

- [Wallpaper Caching Guide](/guides/wallpaper-caching) - Practical configuration
- [Wayland vs X11](/concepts/wayland-vs-x11) - Platform differences
- [Scene Graph](/concepts/scene-graph) - How wlroots renders
