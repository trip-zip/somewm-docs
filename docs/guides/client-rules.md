---
sidebar_position: 2
title: Client Rules
description: "ruled.client rules set properties on windows as they open: match on class, instance, name or type, place on a tag or screen, float, size, and run a callback. Order matters; later rules win."
---

# Client Rules

A rule pairs a match against a client's properties with properties to set when it opens. Every rule is checked in order; when several match, the later one wins for each property. [ruled.client upstream](https://awesomewm.org/doc/api/libraries/ruled.client.html) has the full API.

```lua
local ruled = require("ruled")

ruled.client.append_rule {
    rule = { class = "firefox" },
    properties = { tag = "web" },
}
```

## Find a window's class

```bash
somewm-client client list
```

prints `id`, `title`, `class`, `tags` and `floating` per window. Or notify as windows open:

```lua
client.connect_signal("request::manage", function(c)
    naughty.notification {
        title = "New window",
        message = string.format("class: %s\ninstance: %s\nname: %s\ntype: %s",
            c.class or "nil", c.instance or "nil", c.name or "nil", c.type or "nil"),
    }
end)
```

Classes are case-sensitive: `firefox` and `Firefox` are different.

## Matching

| Key | Matches when |
| --- | --- |
| `rule = { class = "firefox", type = "dialog" }` | every field matches |
| `rule_any = { class = { "Pavucontrol", "Blueman-manager" } }` | any value of any field matches |
| `except = { fullscreen = true }` | excludes clients where every field matches |
| `except_any = { class = { "firefox", "Chromium-browser" } }` | excludes clients where any matches |
| `rule = {}` | every client; put it first so later rules override it |

## Properties

For a `shape` rule with no square border, see [Rounded Corners](./rounded-corners.md).

```lua
ruled.client.append_rule {
    rule = { class = "MyApp" },
    properties = {
        floating = true, maximized = false, fullscreen = false,
        sticky = false,                      -- on every tag
        ontop = false,
        opacity = 0.9,
        border_width = 2, border_color = "#ff0000",
        width = 800, height = 600,
        placement = awful.placement.centered,
        tag = "dev",                         -- an existing tag name, else ignored
        screen = awful.screen.preferred,     -- or an index, or screen.primary
        titlebars_enabled = true,
        shadow = false,                      -- see Shadows
    },
}
```

A `callback = function(c) ... end` runs after the properties for logic a table cannot express. The common one sends new windows to the stack instead of making them master ([Master and Stack](../concepts/master-and-stack.md)):

```lua
callback = function(c) c:to_secondary_section() end,
```

## A complete set

```lua
local awful = require("awful")
local ruled = require("ruled")

ruled.client.connect_signal("request::rules", function()
    ruled.client.append_rule {
        rule = {},
        properties = {
            focus = awful.client.focus.filter,
            raise = true,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen,
            border_width = 2,
        },
        callback = function(c) c:to_secondary_section() end,
    }
    ruled.client.append_rule {
        rule = { type = "dialog" },
        properties = { floating = true, placement = awful.placement.centered },
    }
    ruled.client.append_rule {
        rule_any = { class = { "firefox", "Chromium-browser" } },
        properties = { tag = "web" },
    }
    ruled.client.append_rule {
        rule_any = { class = { "discord", "Slack", "TelegramDesktop" } },
        properties = { tag = "chat" },
    }
    ruled.client.append_rule {
        rule_any = { class = { "Pavucontrol", "Blueman-manager", "Nm-connection-editor" } },
        properties = { floating = true, placement = awful.placement.centered },
    }
    ruled.client.append_rule {
        rule = { class = "Spotify" },
        properties = { tag = "music", opacity = 0.95 },
    }
end)
```

Defaults first, then category rules (dialogs, floating), then per-app rules.

## When a rule does not match

- Check the class with `somewm-client client list`.
- Some apps, Spotify among them, set their class after mapping, so it is nil when rules run. React to `property::class` instead:

```lua
client.connect_signal("request::manage", function(c)
    if c.class == nil then
        c:connect_signal("property::class", function()
            if c.class == "Spotify" then
                c:move_to_tag(awful.tag.find_by_name(c.screen, "music"))
            end
        end)
    end
end)
```

- A rule that hits too much needs a narrower match: `{ class = "firefox", type = "normal" }` skips Firefox's popups.
- A property that keeps reverting is set again by a later, broader rule. Move the specific rule after it.

[Notifications](notifications.md) uses `ruled.notification` the same way; [Shadows](shadows.md) has per-app shadow rules.
