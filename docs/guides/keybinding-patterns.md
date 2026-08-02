---
sidebar_position: 24
title: Keybinding patterns
description: Media keys, keygroups, mouse bindings, and organizing bindings as data or modules
---

# Keybinding patterns

Recipes for common keybinding work beyond one-off `awful.key` calls: hardware media keys, binding a whole key row at once, mouse buttons, and keeping a growing set of bindings organized. If `awful.key` itself is new to you, start with the [Keybindings tutorial](/docs/tutorials/keybindings); for key and modifier names, see the [Key Names Reference](/docs/reference/key-names).

## Bind media keys

Media keys work without modifiers; pass an empty modifier table. Adjust the commands to your audio and backlight tools:

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

Other keygroups exist (`"fkeys"` for F1-F12, for example); the pattern is the same.

## Add mouse bindings

Mouse bindings use `awful.button` and register through the same signal pattern as client keybindings:

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

## Define bindings as data

Once you have more than a handful of launcher bindings, a table plus a small converter is easier to scan and edit than repeated `awful.key` calls:

```lua
-- Define keybindings as data
local my_global_keys = {
    -- { modifiers,         key,      callback,                        description,       group }
    { { modkey },           "b",      function() awful.spawn("firefox") end, "browser",   "launcher" },
    { { modkey },           "e",      function() awful.spawn("thunar") end,  "file manager", "launcher" },
    { { modkey, "Shift" },  "s",      function() awful.spawn("flameshot gui") end, "screenshot", "utility" },
}

-- Convert table entries to keybindings
local function make_keybindings(definitions)
    local keys = {}
    for _, def in ipairs(definitions) do
        table.insert(keys, awful.key(
            def[1],  -- modifiers
            def[2],  -- key
            def[3],  -- callback
            { description = def[4], group = def[5] }
        ))
    end
    return keys
end

-- Apply them
awful.keyboard.append_global_keybindings(make_keybindings(my_global_keys))
```

## Factor out repeated callbacks

If several bindings share a shape (toggle a property, spawn a command), helper functions keep the table readable:

```lua
local helpers = {
    -- Toggle a client property
    toggle_property = function(property)
        return function(c)
            c[property] = not c[property]
            c:raise()
        end
    end,

    -- Spawn a command
    spawn = function(cmd)
        return function()
            awful.spawn(cmd)
        end
    end,
}

awful.keyboard.append_client_keybindings({
    awful.key({ modkey }, "f", helpers.toggle_property("fullscreen"),
        { description = "toggle fullscreen", group = "client" }),

    awful.key({ modkey }, "m", helpers.toggle_property("maximized"),
        { description = "toggle maximized", group = "client" }),
})

awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, "b", helpers.spawn("firefox"),
        { description = "browser", group = "launcher" }),
})
```

## Move bindings into their own module

A complete keybindings module you could save as `keybindings.lua` next to your `rc.lua`. Note the locals at the top: `modkey` and `terminal` are locals in `rc.lua`, so a separate module must define its own (or receive them as arguments); referencing them bare would silently give you an empty modifier table.

```lua
-- keybindings.lua
local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")

-- rc.lua's modkey and terminal are locals; define our own
local modkey = "Mod4"
local terminal = "foot"

-- Helper to convert table format to keybindings
local function make_keys(definitions)
    local keys = {}
    for _, def in ipairs(definitions) do
        table.insert(keys, awful.key(def[1], def[2], def[3],
            { description = def[4], group = def[5] }))
    end
    return keys
end

-- Global keybindings
local global_keys = {
    -- Launchers
    { { modkey },           "Return", function() awful.spawn(terminal) end,    "terminal",       "launcher" },
    { { modkey },           "b",      function() awful.spawn("firefox") end,   "browser",        "launcher" },
    { { modkey },           "e",      function() awful.spawn("thunar") end,    "file manager",   "launcher" },
    { { modkey },           "r",      function() awful.screen.focused().mypromptbox:run() end, "run prompt", "launcher" },

    -- Awesome
    { { modkey },           "s",      hotkeys_popup.show_help,                  "show help",      "awesome" },
    { { modkey, "Control"}, "r",      awesome.restart,                          "reload",         "awesome" },
    { { modkey, "Shift" },  "q",      awesome.quit,                             "quit",           "awesome" },

    -- Layout
    { { modkey },           "space",  function() awful.layout.inc(1) end,       "next layout",    "layout" },
    { { modkey },           "h",      function() awful.tag.incmwfact(-0.05) end, "shrink master", "layout" },
    { { modkey },           "l",      function() awful.tag.incmwfact(0.05) end,  "grow master",   "layout" },

    -- Focus
    { { modkey },           "j",      function() awful.client.focus.byidx(1) end,  "next window",   "client" },
    { { modkey },           "k",      function() awful.client.focus.byidx(-1) end, "prev window",   "client" },
    { { modkey },           "Tab",    function()
        awful.client.focus.history.previous()
        if client.focus then client.focus:raise() end
    end, "last window", "client" },
}

-- Client keybindings
local client_keys = {
    { { modkey },           "f",      function(c) c.fullscreen = not c.fullscreen; c:raise() end, "fullscreen", "client" },
    { { modkey },           "m",      function(c) c.maximized = not c.maximized; c:raise() end,   "maximize",   "client" },
    { { modkey },           "n",      function(c) c.minimized = true end,                          "minimize",   "client" },
    { { modkey, "Shift" },  "c",      function(c) c:kill() end,                                    "close",      "client" },
    { { modkey, "Control"}, "space",  awful.client.floating.toggle,                                "float",      "client" },
}

-- Apply global keybindings
awful.keyboard.append_global_keybindings(make_keys(global_keys))

-- Apply client keybindings
client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings(make_keys(client_keys))
end)

-- Numrow tag switching (can't use table format for keygroups)
awful.keyboard.append_global_keybindings({
    awful.key({
        modifiers = { modkey },
        keygroup = "numrow",
        description = "view tag",
        group = "tag",
        on_press = function(index)
            local tag = awful.screen.focused().tags[index]
            if tag then tag:view_only() end
        end,
    }),
    awful.key({
        modifiers = { modkey, "Shift" },
        keygroup = "numrow",
        description = "move to tag",
        group = "tag",
        on_press = function(index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then client.focus:move_to_tag(tag) end
            end
        end,
    }),
})
```

Then in your `rc.lua`:

```lua
require("keybindings")
```

## See Also

- [Keybindings tutorial](/docs/tutorials/keybindings) - The `awful.key` basics, step by step
- [Key Names Reference](/docs/reference/key-names) - Key names, modifiers, and mouse buttons
- [Default Keybindings](/docs/reference/default-keybindings) - What is already bound
- [awful.key (AwesomeWM docs)](https://awesomewm.org/apidoc/libraries/awful.key.html) - Upstream API reference
