---
sidebar_position: 2
title: Client Rules
description: Control where windows appear and how they behave
---

# Client Rules

Client rules let you automatically set properties on windows when they open. Use them to place apps on specific tags, force windows to float, set opacity, and more. For the full API, see [AwesomeWM ruled.client docs](https://awesomewm.org/doc/api/libraries/ruled.client.html).

## How Rules Work

A rule has two parts: a **condition** that matches windows, and **properties** to apply:

```lua
local ruled = require("ruled")

ruled.client.append_rule {
    rule = { class = "firefox" },   -- Match condition
    properties = {                   -- What to set
        tag = "web",
    },
}
```

When a window opens, SomeWM checks every rule in order. If the window matches, the properties are applied. Multiple rules can match the same window. Later rules override earlier ones.

## Find a Window's Identity

Before writing rules, you need to know how to identify windows. Every window has properties like `class`, `instance`, `name`, and `type` that you can match against.

### Using somewm-client

The quickest way to see what a window reports:

```bash
# List all open windows with their properties
somewm-client client list
```

This shows `class`, `instance`, `name`, and other properties for each window.

### Using a Lua Snippet

To see properties as windows open, add this temporarily to your `rc.lua`:

```lua
client.connect_signal("manage", function(c)
    naughty.notify {
        title = "New window",
        text = string.format(
            "class: %s\ninstance: %s\nname: %s\ntype: %s",
            c.class or "nil",
            c.instance or "nil",
            c.name or "nil",
            c.type or "nil"
        ),
    }
end)
```

Open the app you want to target, note its `class` value, then remove the snippet.

### Common Class Values

| App | Class |
|-----|-------|
| Firefox | `firefox` |
| Chromium | `Chromium-browser` |
| Alacritty | `Alacritty` |
| Kitty | `kitty` |
| Thunar | `Thunar` |
| Spotify | `Spotify` |
| Discord | `discord` |
| Steam | `Steam` |
| mpv | `mpv` |
| VLC | `vlc` |

:::tip
Class values are case-sensitive. `"firefox"` is not the same as `"Firefox"`. Always check the actual value using the methods above.
:::

## Place a Window on a Specific Tag

The most common use case. Open Firefox on the "web" tag:

```lua
ruled.client.append_rule {
    rule = { class = "firefox" },
    properties = {
        tag = "web",
    },
}
```

Place Spotify on the "music" tag on a specific screen:

```lua
ruled.client.append_rule {
    rule = { class = "Spotify" },
    properties = {
        screen = 1,
        tag = "music",
    },
}
```

:::note
The `tag` value must match an existing tag name. If the tag doesn't exist, the property is ignored and the window opens on the current tag.
:::

## Make a Window Float

Some windows work better floating: dialogs, media players, settings windows.

```lua
-- Float specific apps
ruled.client.append_rule {
    rule = { class = "Pavucontrol" },
    properties = {
        floating = true,
        width = 600,
        height = 400,
        placement = awful.placement.centered,
    },
}
```

Float all dialog windows:

```lua
ruled.client.append_rule {
    rule = { type = "dialog" },
    properties = {
        floating = true,
        placement = awful.placement.centered,
    },
}
```

## Set Window Properties

Rules can set any client property. Here are the most useful ones:

```lua
ruled.client.append_rule {
    rule = { class = "MyApp" },
    properties = {
        -- Placement
        floating = true,
        maximized = false,
        fullscreen = false,
        sticky = false,          -- Show on all tags
        ontop = false,           -- Stay above other windows

        -- Appearance
        opacity = 0.9,           -- 0.0 (transparent) to 1.0 (opaque)
        border_width = 2,
        border_color = "#ff0000",

        -- Size and position
        width = 800,
        height = 600,
        placement = awful.placement.centered,

        -- Tag and screen
        tag = "dev",
        screen = awful.screen.preferred,

        -- Titlebars
        titlebars_enabled = true,
    },
}
```

## Match Multiple Conditions

### Match Any of Several Values

Use `rule_any` to match if any condition is true:

```lua
-- Float any of these apps
ruled.client.append_rule {
    rule_any = {
        class = { "Pavucontrol", "Blueman-manager", "Nm-connection-editor" },
    },
    properties = {
        floating = true,
        placement = awful.placement.centered,
    },
}
```

### Match Multiple Properties

Fields inside `rule` must all match (AND logic):

```lua
-- Match only the Firefox "About" dialog
ruled.client.append_rule {
    rule = {
        class = "firefox",
        type = "dialog",
    },
    properties = {
        floating = true,
    },
}
```

### Exclude Windows

Use `except` or `except_any` to exclude windows from a rule:

```lua
-- All windows get borders, except fullscreen ones
ruled.client.append_rule {
    rule = {},
    except = { fullscreen = true },
    properties = {
        border_width = 2,
    },
}

-- Float all dialogs except ones from these apps
ruled.client.append_rule {
    rule = { type = "dialog" },
    except_any = {
        class = { "firefox", "Chromium-browser" },
    },
    properties = {
        floating = true,
    },
}
```

## Set Defaults for All Windows

A rule with an empty `rule = {}` matches every window. Place it early so later rules can override it:

```lua
-- Default properties for all windows
ruled.client.append_rule {
    rule = {},
    properties = {
        focus = awful.client.focus.filter,
        raise = true,
        screen = awful.screen.preferred,
        placement = awful.placement.no_overlap + awful.placement.no_offscreen,
    },
}
```

This is how the default `rc.lua` sets baseline behavior.

## Order and Precedence

Rules are checked in the order they were added. When multiple rules match, later rules override earlier ones for the same property:

```lua
-- Rule 1: all windows get 2px border
ruled.client.append_rule {
    rule = {},
    properties = { border_width = 2 },
}

-- Rule 2: floating windows get 3px border (overrides rule 1)
ruled.client.append_rule {
    rule_any = { floating = true },
    properties = { border_width = 3 },
}
```

**Structure your rules from general to specific**: defaults first, then category rules (all dialogs, all floating windows), then per-app rules last.

## Using Callbacks

If you need logic beyond static properties, use a `callback`:

```lua
ruled.client.append_rule {
    rule = { class = "Steam" },
    callback = function(c)
        -- Center the main window, but not popups
        if c.name and c.name:match("^Steam$") then
            awful.placement.centered(c)
        end
    end,
}
```

## Complete Example

A realistic set of rules for a development setup:

```lua
local awful = require("awful")
local ruled = require("ruled")

ruled.client.connect_signal("request::rules", function()
    -- Default properties for all windows
    ruled.client.append_rule {
        rule = {},
        properties = {
            focus = awful.client.focus.filter,
            raise = true,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen,
            border_width = 2,
        },
    }

    -- Float all dialogs
    ruled.client.append_rule {
        rule = { type = "dialog" },
        properties = {
            floating = true,
            placement = awful.placement.centered,
        },
    }

    -- Browser on tag "web"
    ruled.client.append_rule {
        rule_any = {
            class = { "firefox", "Chromium-browser" },
        },
        properties = { tag = "web" },
    }

    -- Chat apps on tag "chat"
    ruled.client.append_rule {
        rule_any = {
            class = { "discord", "Slack", "TelegramDesktop" },
        },
        properties = { tag = "chat" },
    }

    -- Float settings and control panels
    ruled.client.append_rule {
        rule_any = {
            class = {
                "Pavucontrol",
                "Blueman-manager",
                "Nm-connection-editor",
            },
        },
        properties = {
            floating = true,
            placement = awful.placement.centered,
        },
    }

    -- Spotify: slightly transparent, on "music" tag
    ruled.client.append_rule {
        rule = { class = "Spotify" },
        properties = {
            tag = "music",
            opacity = 0.95,
        },
    }
end)
```

## Troubleshooting

### Rule Isn't Matching

Check the class name. It's case-sensitive and might not be what you expect:

```bash
somewm-client client list
```

Some apps (notably Spotify) set their class late. If `class` is `nil` at rule evaluation time, the rule won't match. Use a `manage` signal as a workaround:

```lua
client.connect_signal("manage", function(c)
    -- Wait for class to be set
    if c.class == nil then
        c:connect_signal("property::class", function()
            if c.class == "Spotify" then
                c:move_to_tag(awful.tag.find_by_name(c.screen, "music"))
            end
        end)
    end
end)
```

### Rule Applies to Wrong Windows

Your match condition might be too broad. Use more specific conditions:

```lua
-- Too broad: matches all Firefox windows including popups
ruled.client.append_rule {
    rule = { class = "firefox" },
    properties = { tag = "web" },
}

-- More specific: only the main Firefox window
ruled.client.append_rule {
    rule = { class = "firefox", type = "normal" },
    properties = { tag = "web" },
}
```

### Properties Being Overridden

Rules are applied in order. If a later rule sets the same property, it wins. Check if a broader rule is overriding your specific one. Move specific rules after general ones.

## See Also

- **[Notifications](/guides/notifications)** - Uses `ruled.notification` with the same pattern
- **[Multi-Monitor](/guides/multi-monitor)** - Screen-specific placement rules
- **[Shadows](/guides/shadows)** - Per-app shadow rules
- **[AwesomeWM ruled.client docs](https://awesomewm.org/doc/api/libraries/ruled.client.html)** - Full API reference
