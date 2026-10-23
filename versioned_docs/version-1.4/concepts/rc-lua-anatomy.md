---
sidebar_position: 3.5
title: Anatomy of rc.lua
description: Where to change settings in the default SomeWM 1.4 configuration.
---

# Anatomy of `rc.lua`

The 1.4 default configuration is `somewmrc.lua`. Copy it as described in [Launch](../getting-started/first-launch.md#first-time-setup), then edit your copy. The section comments below identify where each setting lives without depending on line numbers.

## At a glance

| Section | Controls |
| --- | --- |
| [Error handling](#1-error-handling) | Runtime and startup error notifications |
| [Variable definitions](#2-variable-definitions) | Theme, terminal, editor, modifier key and lockscreen |
| [Menu](#3-menu) | Main menu and launcher |
| [Tag layout](#4-tag-layout) | Available layouts and their cycle order |
| [Wallpaper](#5-wallpaper) | Per-screen wallpaper widgets |
| [Tag persistence](#6-tag-persistence) | Saving tags when an output disappears |
| [Wibar](#7-wibar) | Per-screen tags, tag restoration and panel widgets |
| [Mouse bindings](#8-mouse-bindings) | Desktop-background mouse actions |
| [Key bindings](#9-key-bindings) | Global and client shortcuts |
| [Rules](#10-rules) | Client placement and properties |
| [Titlebars](#11-titlebars) | Window title and control widgets |
| [Notifications](#12-notifications) | Notification rules and presentation |
| [Focus behaviour](#13-focus-behavior) | Focus on pointer entry |

## 1. Error handling

The `request::display_error` handler creates a critical notification. Change that handler to alter error presentation. The config also reports `awesome.x11_fallback_info` when present. The compatibility scan itself is advisory, so finding an X11 pattern does not automatically reject the config.

## 2. Variable definitions

`beautiful.init()` loads the theme before widgets are built. `require("lockscreen").init()` configures the SomeWM lockscreen.

The defaults are `terminal = "xterm"`, `$EDITOR` or `nano` for the editor, and `modkey = "Mod4"`. Choose an installed terminal. `xterm` needs XWayland. Set the modifier to `"Mod1"` for Alt if needed. See [Theme](../tutorials/theme.md).

## 3. Menu

`myawesomemenu` contains session actions. `mymainmenu` combines it with the terminal entry, and `mylauncher` displays the menu from the wibar. `menubar.utils.terminal` selects the terminal used for text applications.

## 4. Tag layout

The `request::default_layouts` handler calls `awful.layout.append_default_layouts`. List order controls cycling. The default tag creation code uses the first layout, initially `floating`. Move `tile` to the front to start with tiling, or add [carousel](../tutorials/carousel.md).

## 5. Wallpaper

The `request::wallpaper` handler creates an `awful.wallpaper` containing an imagebox inside a tile container. Change `beautiful.wallpaper` for the image, or the widget tree for another presentation. A wallpaper can be a widget composition, not just a file.

[Wallpaper Caching](wallpaper-caching.md) describes the separate cache used by `gears.wallpaper.maximized`. That cache is not the default `awful.wallpaper` path.

## 6. Tag persistence

The comment in this section shows how to disconnect `awful.permissions.tag_screen`. That handler saves tags on monitor removal. Restoration happens in the following screen-decoration handler. See [Tag Persistence](tag-persistence.md) before changing either half.

## 7. Wibar

The `request::desktop_decoration` handler restores saved tags for the connector, or creates tags `1` through `9`. It then creates the promptbox, layoutbox, taglist, tasklist and wibar for that screen.

The panel uses `wibox.layout.align.horizontal`: launcher, taglist and prompt on the left, tasklist in the middle, and status widgets on the right. Change the tag names in the creation branch and the widget lists in `s.mywibox`. See [Wibar](../tutorials/wibar.md).

## 8. Mouse bindings

`awful.mouse.append_global_mousebindings` defines actions on the desktop background. Right-click toggles the menu, and the wheel changes tags. Client mouse actions are registered separately with the client bindings.

## 9. Key bindings

Global bindings cover launchers, tags, screens and layouts. Client bindings are registered through `request::default_keybindings`. Numeric keygroups bind the number row and numpad without repeating each key. See [Keybindings](../tutorials/keybindings.md).

## 10. Rules

The `ruled.client` handler adds the default rule, floating exceptions, titlebar settings and application-specific placement. Edit the matching properties for applications you want to float or assign to a tag. See [Client Rules](../guides/client-rules.md).

## 11. Titlebars

`request::titlebars` builds compositor-drawn titlebar widgets with an icon, title and buttons. These are server-side decorations, distinct from decorations an application draws inside its own surface.

Change the widget arrangement here. To disable the configured titlebars, set `titlebars_enabled = false` in the corresponding client rule.

## 12. Notifications

`ruled.notification` assigns the preferred screen and a five-second implicit timeout. The `request::display` handler creates `naughty.layout.box`. Change the rule for defaults or the display handler for custom notification widgets. See [Notifications](../guides/notifications.md).

## 13. Focus behavior

The final `mouse::enter` handler requests activation with `raise = false`. Remove it for click-to-focus, or request `raise = true` to bring the window forward as well.

## Related

- [Architecture](architecture.md)
- [Signals](signals.md)
- [Basics](../tutorials/basics.md)
