---
sidebar_position: 24
title: Keybinding patterns
description: Register media keys, tag keygroups and mouse bindings, and move bindings into modules
---

# Keybinding patterns

Add these bindings to `rc.lua` after requiring `awful` and defining `modkey`. Replace existing bindings for the same keys to avoid conflicts. For the basics, start with the [Keybindings Tutorial](../tutorials/keybindings.md).

## Bind media keys

Use an empty modifier table for media keys. These commands require `wpctl` and `brightnessctl`:

```lua
awful.keyboard.append_global_keybindings({
    -- Volume controls
    awful.key({}, "XF86AudioRaiseVolume", function()
        awful.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")
    end, { description = "raise volume", group = "media" }),

    awful.key({}, "XF86AudioLowerVolume", function()
        awful.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
    end, { description = "lower volume", group = "media" }),

    awful.key({}, "XF86AudioMute", function()
        awful.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
    end, { description = "toggle mute", group = "media" }),

    -- Brightness controls
    awful.key({}, "XF86MonBrightnessUp", function()
        awful.spawn("brightnessctl s +5%")
    end, { description = "increase brightness", group = "media" }),

    awful.key({}, "XF86MonBrightnessDown", function()
        awful.spawn("brightnessctl s 5%-")
    end, { description = "decrease brightness", group = "media" }),
})
```

## Bind a whole key row at once

For per-tag bindings (1-9), one declarative `awful.key` with `keygroup = "numrow"` replaces nine copies. The callback receives the index:

```lua
awful.keyboard.append_global_keybindings({
    awful.key({
        modifiers = { modkey },
        keygroup = "numrow",
        description = "view tag",
        group = "tag",
        on_press = function(index)
            local tag = awful.screen.focused().tags[index]
            if tag then
                tag:view_only()
            end
        end,
    }),

    awful.key({
        modifiers = { modkey, "Shift" },
        keygroup = "numrow",
        description = "move client to tag",
        group = "tag",
        on_press = function(index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end,
    }),
})
```

Use `keygroup = "fkeys"` for F1–F12.

## Add mouse bindings

<span id="define-bindings-as-data" />
<span id="factor-out-repeated-callbacks" />

Edit the existing `request::default_mousebindings` handler, or add this one if your config has none:

```lua
client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings({
        -- Left click to focus
        awful.button({}, 1, function(c)
            c:activate({ context = "mouse_click" })
        end),

        -- Mod4 + Left click to move
        awful.button({ modkey }, 1, function(c)
            c:activate({ context = "mouse_click", action = "mouse_move" })
        end),

        -- Mod4 + Right click to resize
        awful.button({ modkey }, 3, function(c)
            c:activate({ context = "mouse_click", action = "mouse_resize" })
        end),
    })
end)
```

Button numbers: `1` left, `2` middle, `3` right, `4` scroll up, `5` scroll down.


## Move bindings into their own module

Save this as `~/.config/somewm/keybindings.lua`. Pass in settings from `rc.lua` because its locals are not visible inside another module:

```lua
local awful = require("awful")
return function(modkey, terminal)
    awful.keyboard.append_global_keybindings({
        awful.key({ modkey }, "Return", function()
            awful.spawn(terminal)
        end, { description = "terminal", group = "launcher" }),
    })
    client.connect_signal("request::default_keybindings", function()
        awful.keyboard.append_client_keybindings({
            awful.key({ modkey }, "f", function(c)
                c.fullscreen = not c.fullscreen
                c:raise()
            end, { description = "fullscreen", group = "client" }),
        })
    end)
end
```

Load it once during `rc.lua`, replacing the equivalent existing bindings:

```lua
require("keybindings")(modkey, terminal)
```

Move the other recipes into this function as needed. Calling it repeatedly appends more bindings and signal handlers.

## See Also

- [Keybindings Tutorial](../tutorials/keybindings.md)
- [Key Names](../reference/key-names.md)
- [Default Keybindings](../reference/default-keybindings.md)
