---
sidebar_position: 3
title: Keybindings
description: Add a global keybinding and a per-client one, reload, press them, and find them in the help popup.
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Keybindings

<YouWillLearn>

- The four parts of an `awful.key`
- A global keybinding and a per-client keybinding
- How your bindings appear in the help popup

</YouWillLearn>

## A global keybinding

In `rc.lua`, find `append_global_keybindings` and add:

```lua
awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, "b", function()
        awful.spawn("firefox")
    end, { description = "open browser", group = "launcher" }),
})
```

Mod4 + Ctrl + r reloads; Mod4 + b opens Firefox, tiled into the current tag. Every binding has the same four parts:

```lua
awful.key(
    { modkey },                                            -- modifiers; {} for none
    "b",                                                   -- key ([names](../reference/key-names.md))
    function() awful.spawn("firefox") end,                 -- runs on press
    { description = "open browser", group = "launcher" }   -- shown in the help popup
)
```

## A client keybinding

A client binding fires only with a window focused, and that window is passed as `c`. Find `request::default_keybindings`:

```lua
client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
        awful.key({ modkey }, "o", function(c)
            c.opacity = c.opacity == 1 and 0.8 or 1
        end, { description = "toggle opacity", group = "client" }),
    })
end)
```

Reload, focus a terminal, Mod4 + o: it turns translucent, and again solid. With another window focused the same key acts on that one.

## The help popup

Mod4 + s. The `launcher` group now lists "open browser" beside the defaults, and `client` lists "toggle opacity". That is what `description` and `group` are for. Any key dismisses it.

If a binding does nothing: modifier names are case-sensitive, another binding may already use the key, and the config must be reloaded. A callback error shows up as a notification.

## Next

- [Keybinding patterns](../guides/keybinding-patterns.md): media keys, the whole number row at once, mouse bindings, bindings as data
- [Key Names](../reference/key-names.md): every key and modifier name
- [Widgets](widgets.md)
