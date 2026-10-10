---
sidebar_position: 24
title: Keybinding patterns
description: Media keys, keygroups, mouse bindings, and organizing bindings as data or modules
---

# Keybinding patterns

Media keys, a whole key row in one binding, mouse buttons, and bindings kept as data or in a module. [Keybindings](/docs/tutorials/keybindings) is the tutorial; [Key Names](/docs/reference/key-names) lists every key and modifier.

## Bind media keys

An empty modifier table binds a key on its own:

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

`keygroup = "numrow"` binds 1 to 9 in one declaration and passes the index to the callback; `"fkeys"` does the same for F1 to F12:

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

## Add mouse bindings

`awful.button` registers through the same signal as client keybindings. Buttons are 1 left, 2 middle, 3 right, 4 and 5 scroll:

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

## Define bindings as data

Past a handful of bindings, a table and a converter are easier to scan than repeated calls:

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

Bindings that share a shape take a helper:

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

A complete `keybindings.lua` next to `rc.lua`. `modkey` and `terminal` are locals in `rc.lua`, so the module defines its own; a bare `modkey` here would silently be an empty modifier table.

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
    { { modkey, "Control"}, "space",  function(c) c.floating = not c.floating end,                 "float",      "client" },
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

[Default Keybindings](/docs/reference/default-keybindings) lists what is already bound; [awful.key upstream](https://awesomewm.org/apidoc/libraries/awful.key.html) is the API.
