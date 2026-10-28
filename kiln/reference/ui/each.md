---
title: kiln.ui.each
description: Per-item state retained by a stable key function.
---

# kiln.ui.each

Declares a list with a state table for each item key.

```lua
ui.each(items, key, declare)
```

## Example

Define the key function once, outside the frame callback:

```lua
local function item_key(item) return item.name end
```

Inside the declaration:

```lua
ui.each(items, item_key, function(item, id, st)
  ui.box({
    id = "item:" .. id, color = st.over and "#504945" or "#282828",
    on_hover = function(over)
      st.over = over
      kiln.dirty()
    end,
  }, function() ui.text(item.name) end)
end)
```

## Arguments

| Argument | Type | Behaviour |
|---|---|---|
| `items` | array | Visited in `ipairs` order. |
| `key` | function | Returns a stable, unique key for each item. |
| `declare` | function | Called as `(item, key, state)` for each item. |

## Behaviour

State is scoped by the key function's identity, the output and the item key.
Recreating the key function every frame loses retained state. Reordering items
preserves it; an item absent from an accepted frame loses it. A rejected frame
does not publish a replacement key set.

The function returns a table mapping keys to state tables. It creates no
container or element IDs. The callback declares those itself. Removing an
output or reloading the config clears its retained state.
