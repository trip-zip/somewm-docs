---
sidebar_position: 4
title: Anatomy of rc.lua
description: Section-by-section map of the default SomeWM config
---

# Anatomy of `rc.lua`

The default [`somewmrc.lua`](https://github.com/trip-zip/somewm/blob/v2.0.1/somewmrc.lua) contains the theme, widgets, bindings, and rules for SomeWM 2.0. To edit your own copy, start with the [basics tutorial](../tutorials/basics.md).

## At a glance

| Change | Config section |
| --- | --- |
| Colours, fonts, or theme | [Theme system](#2-theme-system) |
| Terminal, editor, or modifier key | [Lockscreen and defaults](#4-lockscreen-and-defaults) |
| Available window layouts | [Layouts](#7-layouts) |
| Background image or gradient | [Wallpaper](#8-wallpaper) |
| Tags, clock, or bar widgets | [Wibar](#10-wibar) |
| Keyboard shortcuts | [Global](#12-global-key-bindings) or [client bindings](#13-client-mouse-and-key-bindings) |
| Placement of particular applications | [Rules](#14-rules) |
| Focus on mouse entry | [Sloppy focus](#17-sloppy-focus) |

## 1. Error handling

The `request::display_error` handler shows Lua errors through `naughty.notification`. The `awesome.x11_fallback_info` block reports detected X11-specific patterns. Detection alone does not skip the user config, which is still attempted.

## 2. Theme system

`theme_name` defaults to `"gruvbox"`. If `$XDG_CONFIG_HOME/somewm/theme` exists, its contents select a theme from the installed themes directory. Without `XDG_CONFIG_HOME`, the path is `~/.config/somewm/theme`.

`switch_theme(name)` saves the name and reloads the config. `beautiful.init()` loads its theme file. For a custom file, follow the [theme tutorial](../tutorials/theme.md).

## 3. Custom "s" logo

The Cairo block assigns a generated logo to `beautiful.awesome_icon`. The launcher uses this image. To use your own icon, replace the block with an assignment to an image path.

## 4. Lockscreen and defaults

`require("lockscreen").init()` creates the built-in [lockscreen](lockscreen.md). The following local variables are used throughout the config:

| Variable | Default |
| --- | --- |
| `terminal` | `"foot"` |
| `editor` | `$EDITOR`, or `"nano"` |
| `editor_cmd` | Terminal command with `-e` and the editor |
| `modkey` | `"Mod4"`, the Super key |

## 5. User customization examples

This section contains commented examples. Nothing runs until uncommented. For working configurations and their limits, see [input devices](../guides/input-devices.md), [autostart](../guides/autostart.md), [fractional scaling](../guides/fractional-scaling.md), and [locking](../guides/lockscreen.md).

## 6. Menu

`theme_menu` lists the built-in themes. `menu_items` supplies the main menu, opened by the launcher, right-clicking the desktop, or `Mod4 + w`. `menubar.utils.terminal` selects the terminal used for text applications launched through the menubar.

## 7. Layouts

The `request::default_layouts` handler registers layouts in cycle order. `tile` is first and is the default for new tags. Reorder the list to change the default, or remove entries to shorten the cycle. See the [layout reference](awful/layout.md) and [carousel tutorial](../tutorials/carousel.md).

## 8. Wallpaper

The `request::wallpaper` handler uses `awful.wallpaper` with the first matching option:

1. `beautiful.wallpaper_colors`: gradient and centred logo.
2. `beautiful.wallpaper`: image.
3. `beautiful.bg_normal`: solid colour, falling back to `"#222222"`.

Unset `wallpaper_colors` to use an image with a theme that defines a gradient.

## 9. Tag persistence

`awful.permissions.tag_screen` saves tag state when a monitor disconnects. The commented `disconnect_signal` call disables saving. Restoration happens in the next section. See [tag persistence](tag-persistence.md).

## 10. Wibar

`mytextclock` is created before the per-screen handler. Inside `request::desktop_decoration`, the config restores saved tags or creates `dev`, `web`, `chat`, `files`, and `media`. It then creates the prompt, layoutbox, taglist, tasklist, and `s.mywibox`.

The bar overlays a centred clock on an align layout. The tasklist belongs to the left group, alongside the launcher, tags, and prompt. The right group contains the tray and layoutbox.

When changing the bar, keep the tag restore/create block. The [wibar tutorial](../tutorials/wibar.md) identifies the part to replace. The [widgets tutorial](../tutorials/widgets.md) replaces the clock.

## 11. Root mouse bindings

`awful.mouse.append_global_mousebindings()` binds right-click on the desktop to the main menu and scrolling to tag switching.

## 12. Global key bindings

`awful.keyboard.append_global_keybindings()` registers groups for launchers, tags, focus, screens, audio, brightness, screenshots, and layouts. Number-row bindings address tags by index. Numpad bindings select layouts by index.

See [default keybindings](default-keybindings.md) for the full list and the [keybindings tutorial](../tutorials/keybindings.md) to add one.

## 13. Client mouse and key bindings

The `request::default_mousebindings` and `request::default_keybindings` handlers register bindings whose callbacks receive the target client. Left-click activates a client. `Mod4` with left or right drag moves or resizes it. Keyboard actions include closing, floating, maximising, and moving between screens.

## 14. Rules

The `ruled.client` `request::rules` handler registers defaults for all clients, floating applications, the `wlroots` application class, and titlebars. Rules apply when a client is managed. See [client rules](../guides/client-rules.md) for matching and ordering.

## 15. Titlebars

`request::titlebars` builds compositor-drawn titlebars with an icon, title, and floating, maximise, and close buttons. These are server-side decorations. Applications may also draw their own decorations.

Set `titlebars_enabled = false` in the titlebar rule to disable compositor titlebars.

## 16. Notifications

`ruled.notification` supplies a five-second timeout and preferred screen. The `request::display` handler creates a `naughty.layout.box`. Change that handler to customise the notification widget, or change the rules for per-application behaviour. See [notifications](../guides/notifications.md).

## 17. Sloppy focus

<span id="related" />

The final `mouse::enter` handler activates the client under the pointer without raising it. Remove the handler for click-to-focus. See [focus configuration](../guides/focus.md).
