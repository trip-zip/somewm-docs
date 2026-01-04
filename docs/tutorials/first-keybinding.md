---
sidebar_position: 3
title: Your First Keybinding
description: Add custom keyboard shortcuts to SomeWM
---

# Your First Keybinding

Keybindings are the heart of a tiling window manager. In this tutorial, you'll learn how to add your own custom shortcuts.

## Keybinding Anatomy

Every keybinding in SomeWM has four parts:

```lua
awful.key(
    { "Mod4" },           -- 1. Modifiers (table)
    "Return",             -- 2. Key
    function()            -- 3. Callback function
        awful.spawn(terminal)
    end,
    { description = "open a terminal", group = "launcher" }  -- 4. Metadata
)
```

| Part | Description |
|------|-------------|
| **Modifiers** | Table of modifier keys: `"Mod4"`, `"Shift"`, `"Control"`, `"Mod1"` (Alt) |
| **Key** | The key name: `"Return"`, `"space"`, `"a"`, `"F1"`, etc. |
| **Callback** | Function to execute when pressed |
| **Metadata** | Description and group for the help popup |

## Adding a Global Keybinding

Global keybindings work anywhere, regardless of which window is focused.

Open your `rc.lua` and find the keybindings section. Add a new keybinding:

```lua
awful.keyboard.append_global_keybindings({
    -- Your existing keybindings...

    -- Add a new one:
    awful.key({ modkey }, "b", function()
        awful.spawn("firefox")
    end, { description = "open browser", group = "launcher" }),
})
```

Press **Mod4 + Ctrl + r** to reload, then try **Mod4 + b** to open Firefox!

## Adding a Client Keybinding

Client keybindings only work when a window is focused, and the focused window (`c`) is passed to your callback.

Find the client keybindings section in your rc.lua:

```lua
client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
        -- Existing keybindings...

        -- Toggle window opacity:
        awful.key({ modkey }, "o", function(c)
            if c.opacity == 1 then
                c.opacity = 0.8
            else
                c.opacity = 1
            end
        end, { description = "toggle opacity", group = "client" }),
    })
end)
```

Now **Mod4 + o** will toggle transparency on the focused window.

## Modifier Key Reference

| Modifier | Common Name | Key |
|----------|-------------|-----|
| `"Mod4"` | Super/Windows | The key with the Windows logo |
| `"Mod1"` | Alt | Left or Right Alt |
| `"Shift"` | Shift | Either Shift key |
| `"Control"` | Ctrl | Either Control key |

Combine modifiers in a table:

```lua
{ modkey, "Shift" }     -- Mod4 + Shift
{ modkey, "Control" }   -- Mod4 + Ctrl
{ "Mod1", "Shift" }     -- Alt + Shift
```

## Common Key Names

| Key | Name in Lua |
|-----|-------------|
| Enter | `"Return"` |
| Space | `"space"` |
| Tab | `"Tab"` |
| Escape | `"Escape"` |
| Arrows | `"Left"`, `"Right"`, `"Up"`, `"Down"` |
| Function keys | `"F1"` through `"F12"` |
| Letters | `"a"` through `"z"` (lowercase) |
| Numbers | `"1"` through `"0"` |

## Media Keys

Media keys work without modifiers:

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

## Organizing with Tables

As your config grows, keybindings can get messy. Here's a cleaner approach using tables:

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

This makes it easy to scan and edit your keybindings at a glance.

## Helper Functions

For common patterns, create helper functions:

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

-- Use them in keybindings:
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

## The Hotkeys Popup

Press **Mod4 + s** to see all your keybindings organized by group.

{/* TODO: Screenshot needed
   - Hotkeys popup showing custom keybinding groups
   - Should show the "launcher" group with custom shortcuts
*/}

The popup automatically includes your keybindings if you set the `description` and `group` metadata.

### Customizing the Popup

You can style the popup through theme variables:

```lua
-- In your theme.lua
theme.hotkeys_bg = "#282828"
theme.hotkeys_fg = "#ebdbb2"
theme.hotkeys_border_color = "#fabd2f"
theme.hotkeys_modifiers_fg = "#fe8019"
theme.hotkeys_label_bg = "#b8bb26"
```

## Numrow Keybindings

For tag switching (1-9), use the declarative pattern with `keygroup`:

```lua
awful.keyboard.append_global_keybindings({
    awful.key({
        modifiers = { modkey },
        keygroup = "numrow",
        description = "view tag",
        group = "tag",
        on_press = function(index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
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

The `keygroup = "numrow"` automatically binds to keys 1-9.

## Mouse Bindings

Mouse bindings work similarly, using `awful.button`:

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

Button numbers:
- `1` = Left click
- `2` = Middle click
- `3` = Right click
- `4` = Scroll up
- `5` = Scroll down

## Complete Example

Here's a complete keybindings module you could save as `keybindings.lua`:

```lua
-- keybindings.lua
local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")

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

## Troubleshooting

### Keybinding not working

1. Check for typos in key names (they're case-sensitive for modifiers)
2. Look for conflicts with existing keybindings
3. Make sure you reloaded config with **Mod4 + Ctrl + r**

### Key name not found

Use `xev` (X11) or check the [Default Keybindings](/reference/default-keybindings) reference for correct key names.

### Callback errors

Check the notification for error messages. Common issues:
- Missing `local` for variables
- Typos in function names
- Missing `end` for functions

## Next Steps

- **[Default Keybindings](/reference/default-keybindings)** - Complete list of built-in shortcuts
- **[First Widget](/tutorials/first-widget)** - Create custom widgets
- **[AwesomeWM Key Docs](https://awesomewm.org/doc/api/libraries/awful.key.html)** - Full awful.key reference
