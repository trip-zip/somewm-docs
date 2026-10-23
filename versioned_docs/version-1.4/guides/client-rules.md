---
sidebar_position: 2
title: Client Rules
description: Control where windows appear and how they behave
---

# Client Rules

<span id="how-rules-work" />

Add rules inside the existing `ruled.client` `request::rules` handler in `rc.lua`. Rules set properties when a window is managed. They do not continuously enforce those properties afterward.

## Find a Window's Identity

<span id="using-somewm-client" />
<span id="using-a-lua-snippet" />
<span id="common-class-values" />

Open the application, then run:

```bash
somewm-client client list
somewm-client client info focused
```

Use the reported `class`, `instance`, `name` or `type`. Values can differ between application builds and between native Wayland and XWayland windows. Matching is case-sensitive, and string values support Lua patterns.

## Place a Window on a Specific Tag

This rule sends Firefox to an existing tag named `web`:

```lua
local ruled = require("ruled")
ruled.client.connect_signal("request::rules", function()
    ruled.client.append_rule {
        rule = { class = "^firefox$" },
        properties = { tag = "web" },
    }
end)
```

When adding this to the default config, put the `append_rule` call in its existing handler. A named tag is looked up on the client's screen first, then on other screens. If no tag matches, SomeWM logs a warning and leaves tag placement to the remaining rules and handlers.

For a specific screen, add `screen = 2` alongside `tag = "web"`. That screen and tag must exist when the rule runs.

## Make a Window Float

The remaining `append_rule` examples belong in the same handler:

```lua
ruled.client.append_rule {
    rule = { class = "^Pavucontrol$" },
    properties = {
        floating = true,
        width = 600,
        height = 400,
        placement = awful.placement.centered,
    },
}
```

For dialogs regardless of application, use `rule = { type = "dialog" }`.

## Set Window Properties

Rules can assign client properties such as `opacity`, `border_width`, `border_color`, `fullscreen`, `maximized`, `sticky` and `ontop`. They also accept placement helpers and properties such as `titlebars_enabled` used by the Lua handlers.

```lua
ruled.client.append_rule {
    rule = { class = "^MyApp$" },
    properties = {
        opacity = 0.9,
        border_width = 2,
        border_color = "#ff0000",
        titlebars_enabled = true,
    },
}
```

## Match Multiple Conditions

<span id="match-any-of-several-values" />
<span id="match-multiple-properties" />
<span id="exclude-windows" />

Fields within `rule` must all match. `rule_any` matches any listed value in any listed field:

```lua
ruled.client.append_rule {
    rule_any = {
        class = { "^Pavucontrol$", "^Blueman%-manager$" },
        type = { "dialog" },
    },
    properties = { floating = true },
}
```

Use lists for `rule_any` alternatives, including boolean alternatives such as `{ true }`. If both `rule` and `rule_any` are present, either can match. They are not an AND combination.

Use `except` to exclude windows matching all its fields, or `except_any` to exclude any listed match:

```lua
ruled.client.append_rule {
    rule = { type = "dialog" },
    except_any = { class = { "^firefox$", "^Chromium%-browser$" } },
    properties = { floating = true },
}
```

## Set Defaults for All Windows

<span id="order-and-precedence" />

An empty `rule = {}` matches every window. Keep the default rule first, followed by more specific rules. Later matching rules replace earlier values for the same property.

```lua
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
```

Rules are matched before their collected properties are applied. A later condition cannot depend on a property that an earlier rule is about to set.

## Using Callbacks

<span id="send-new-windows-to-the-stack" />
<span id="complete-example" />

Use a callback for operations that are not property assignments. For example, add this callback to your existing default rule to move newly managed clients to the end of the tiling order:

```lua
ruled.client.append_rule {
    rule = {},
    callback = function(c)
        c:to_secondary_section()
    end,
}
```

See [Master and Stack](../concepts/master-and-stack.md) for how client order affects layouts.

## Troubleshooting

### Rule Isn't Matching

Check the actual identity with `client info`. Anchor patterns with `^` and `$` for an exact match. Rule evaluation happens at management time. If an application changes its identity later, handle that property's signal explicitly rather than expecting the rule to run again.

### Rule Applies to Wrong Windows

Add conditions within `rule`, such as `class = "^firefox$", type = "normal"`. Do not combine `rule` and `rule_any` when both conditions must hold.

### Properties Being Overridden

Check later rules and signal handlers that assign the same property. Reopen a window when testing a rule intended for newly managed clients.

## See Also

- [Notifications](notifications.md)
- [Multi-Monitor Setup](multi-monitor.md)
- [Shadows](shadows.md)
- [AwesomeWM Rule API](https://awesomewm.org/doc/api/libraries/ruled.client.html)
