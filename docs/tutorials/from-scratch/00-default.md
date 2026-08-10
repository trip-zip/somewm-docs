---
title: "The Default Config"
description: "A guided tour of the baseline rc.lua: how the compositor loads it, what each section does, how it differs from the config SomeWM 2.0 ships, and how to test changes in a nested session without breaking your desktop."
sidebar_label: "00 · The Default Config"
---

import YouWillLearn from '@site/src/components/YouWillLearn';
import ChapterNav from '@site/src/components/FromScratch/ChapterNav';
import NextChapter from '@site/src/components/FromScratch/NextChapter';

# The Default Config

<ChapterNav chapter="00" />

<YouWillLearn>

- how the compositor loads rc.lua, and what happens when it contains an error
- the structure of the baseline config: error handling, theme, menu, wibar, keybindings, rules, signals
- how that baseline differs from the config SomeWM 2.0 ships, and why the series starts from the smaller one
- how to run a work-in-progress config in a nested session on SomeWM or AwesomeWM
- how to recover when a config change goes wrong

</YouWillLearn>

You write no code in this chapter. Instead, we read the file we are about to spend twelve chapters rebuilding, so that when we start tearing sections out you know exactly what each one did.

## Where We Are

There is no previous chapter; this is the start. Clone the companion repository and check out the baseline branch:

```bash
git clone https://github.com/trip-zip/awesome-from-scratch.git
cd awesome-from-scratch
git checkout 00-default
```

The branch contains two files: a README and a 693-line `rc.lua`. That rc.lua is the SomeWM 1.4 stock configuration, unchanged apart from running it through this repository's `stylua` formatting. Every later branch is exactly one commit on top of the branch before it, so `git diff` between neighboring branches always shows you one chapter's worth of change.

## What This Series Targets

:::caution Read this before you compare notes
This series targets **AwesomeWM** (4.3 and current master) and the **SomeWM 1.4** series. Those are what the checkpoint branches are written and tested against. If you are on a SomeWM 2.0 development build, the `somewmrc.lua` it ships is **not** the file this series starts from: it was rewritten after 1.4 to showcase the compositor, and it is about 1,100 lines against this baseline's 693. Open `~/.config/somewm/rc.lua` and try to follow along there and nothing will line up.
:::

The series builds on the 1.4-lineage config because it is the smaller, more conventional starting point: it is essentially the AwesomeWM default with SomeWM's additions folded in, so it reads the same on both compositors and it leaves you something to build. The 2.0 default already hands you several of the things you are about to write.

| | `00-default` branch (this series) | shipped SomeWM 2.0 default |
|---|---|---|
| Lines | 693 | 1,118 |
| Section markers | `-- {{{ Menu` folds, `-- @DOC_*@` doc anchors | plain comments, no folds or anchors |
| Theme | `default/theme.lua` | `gruvbox`, persisted to `~/.config/somewm/theme`, with a switcher in the menu |
| Terminal | `xterm` | `foot` |
| Tags | nine numbered, `"1"` through `"9"` | five named: `dev`, `web`, `chat`, `files`, `media` |
| Clock | bare `wibox.widget.textclock()` | rounded background, centered with `wibox.layout.stack` |
| Keybinding style | positional: `awful.key({ modkey }, "l", fn, desc)` | declarative: `awful.key { modifiers =, key =, on_press = }` |
| Media, brightness, screenshot keys | none | `wpctl`, `brightnessctl`, `grim`/`slurp`, and `awful.screenshot` |
| Commented-out extras | none | `awful.input` pointer and xkb, fractional scaling, autostart, idle auto-lock, layout animation, `awful.ipc.register` |

Three practical consequences:

1. **Run the checkout, not your installed config.** `somewm-client test start --config "$PWD/rc.lua"` points the nested session at the baseline in the git checkout. The public Lua API is the same in both releases, so the baseline runs correctly under 2.0.
2. **Several rows above are chapters.** The theme is chapter 01, media keys are chapter 02, the styled clock is chapter 03, named tags and a centered bar are chapter 04, do-not-disturb is chapter 06, and locking is chapter 12. The 2.0 default gives them to you already configured. This series has you write them, which is what makes them yours to change.
3. **Two keybindings are dead on 2.0, in this chapter and the next one only.** The stock 1.4 config uses `awful.client.floating.toggle` and `awful.client.getmaster`, both long deprecated and both removed on the 2.0 development line. On a 2.0 build, `Mod+Ctrl+Space` and `Mod+Ctrl+Return` therefore do nothing on the `00-default` and `01-theme` branches. That is not a mistake to fix here: those branches carry the stock file verbatim, which is the whole point of this chapter. Chapter 02 rewrites the keybindings from scratch and uses the `c.floating` property and `awful.client.visible` instead, which work everywhere, so the problem disappears for good at the next checkpoint.

If you are on SomeWM 1.4, or on AwesomeWM, none of this applies: the baseline is your stock config.

## What rc.lua Is

`rc.lua` is the entire window manager configuration: one Lua program that the compositor executes, top to bottom, exactly once at startup. There is no config file format to learn. Defining a keybinding, building a bar, styling a border: all of it is ordinary Lua calling the compositor's libraries. After the file finishes running, nothing "re-runs" it; everything that happens afterward is driven by callbacks the file registered.

Two consequences matter from day one:

1. **A broken rc.lua does not lock you out.** If your config throws an error during startup, the compositor falls back to the system default config and shows a critical notification with the error message. You get a working (ugly) desktop and a stack trace, not a black screen.
2. **Reloading is just re-executing.** `Mod4+Control+r` restarts the compositor in place, which re-reads rc.lua. Your edit-reload loop is a keypress.

The compositor looks for the file at `$XDG_CONFIG_HOME/somewm/rc.lua` (or `~/.config/awesome/rc.lua` on AwesomeWM), but you can point it at any path, which is exactly what the nested test session below does. Throughout this series we run straight out of the git checkout.

## A Tour of the Baseline

Open the `rc.lua` from the checkout and skim it alongside this section. The file is divided by fold-marker comments like `-- {{{ Menu`, and you will see markers like `-- @DOC_WIBAR@` scattered around: those are anchors used to generate the official API docs from this same file. Ignore them.

### Libraries and Error Handling

The top of the file pulls in the standard libraries you will use constantly: `gears` (utilities), `awful` (window management), `wibox` (widgets), `beautiful` (theming), `naughty` (notifications), and `ruled` (declarative rules). Then comes the first interesting block:

```lua
-- rc.lua
naughty.connect_signal("request::display_error", function(message, startup)
  naughty.notification({
    urgency = "critical",
    title = "Oops, an error happened" .. (startup and " during startup!" or "!"),
    message = message,
  })
end)
```

This is your first **signal**. Signals are the compositor's event system: objects emit named events, and `connect_signal` registers a callback for one. Here, whenever an error needs displaying, `naughty` (the notification library) pops up a critical notification with the message. The entire config is wired together this way, and you will connect dozens of signals before the series is done.

:::note
The SomeWM build of this file carries a few extras the AwesomeWM original does not: a startup notice if your config was skipped for containing X11-only code, tag persistence across monitor hotplug, and a hook into the built-in lockscreen (`require("lockscreen").init()`, plus a `Mod4+Shift+Escape` binding to `awesome.lock()`). On AwesomeWM these pieces do not apply; chapter 12 covers locking on both.
:::

### Theme and Variables

One line loads the entire visual identity:

```lua
-- rc.lua
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
```

`beautiful` is the theming library: `beautiful.init` reads a theme file that returns a table of colors, fonts, and sizes, and every built-in widget consults that table when drawing. Change the table, change the look. Chapter 01 replaces this default theme with our own.

Next come the user variables:

```lua
-- rc.lua
terminal = "xterm"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
```

plus `modkey = "Mod4"`, the Super key, which prefixes nearly every binding.

### The Menu

The stock config builds a right-click desktop menu and a launcher button for the bar:

```lua
-- rc.lua
mymainmenu = awful.menu({
  items = {
    { "awesome", myawesomemenu, beautiful.awesome_icon },
    { "open terminal", terminal },
  },
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })
```

Right-click an empty patch of desktop and this is what appears. We rebuild it properly in chapter 08.

### Layouts, Wallpaper, and Tags

The next two blocks register callbacks for `request::default_layouts` (the list of tiling layouts you cycle with `Mod4+Space`: tile, fair, spiral, max, and friends) and `request::wallpaper` (drawn per screen with an image widget). Inside the wibar section, each screen also gets nine **tags**, the workspaces you switch between with `Mod4+1` through `Mod4+9`. A window (a **client**, in compositor vocabulary) lives on one or more tags; only clients on the selected tags are visible.

### The Wibar

The largest section runs once per screen, building a taglist, a prompt box, a layout indicator, a tasklist, and finally the bar itself:

```lua
-- rc.lua
  s.mywibox = awful.wibar({
    position = "top",
    screen = s,
    -- @DOC_SETUP_WIDGETS@
    widget = {
      layout = wibox.layout.align.horizontal,
      { -- Left widgets
        layout = wibox.layout.fixed.horizontal,
        mylauncher,
        s.mytaglist,
        s.mypromptbox,
      },
      s.mytasklist, -- Middle widget
      { -- Right widgets
        layout = wibox.layout.fixed.horizontal,
        mykeyboardlayout,
        wibox.widget.systray(),
        mytextclock,
        s.mylayoutbox,
      },
    },
  })
```

This is the **declarative widget syntax**: a nested Lua table where each level names a layout and lists its children. A wibar is just a docked box holding a widget tree. We will spend chapters 03 and 04 replacing every widget in it, but the three-section align layout survives all the way to the finished config.

### Keybindings

Bindings are `awful.key` objects appended in themed batches:

```lua
-- rc.lua
  awful.key({ modkey, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
  awful.key({ modkey, "Shift" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),
  awful.key({ modkey }, "l", function()
    awful.tag.incmwfact(0.05)
  end, { description = "increase master width factor", group = "layout" }),
```

Each one is modifiers, key, callback, and a description table. The descriptions are not decoration: press `Mod4+s` and a help popup lists every binding, grouped by that `group` field. Roughly 250 lines of the file are bindings in this style; chapter 02 compresses them into a table-driven system.

### Rules

When a new client appears, `ruled.client` matches it against declarative rules and applies properties. The first rule matches everything:

```lua
-- rc.lua
  -- All clients will match this rule.
  ruled.client.append_rule({
    id = "global",
    rule = {},
    properties = {
      focus = awful.client.focus.filter,
      raise = true,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen,
    },
  })
```

Further rules float specific apps and enable titlebars on normal windows and dialogs. Chapter 05 digs into rules and rebuilds the titlebar.

### Final Signals

The file closes with three signal handlers: one that builds each client's titlebar widget tree on `request::titlebars`, one that displays notifications in the default box, and sloppy focus:

```lua
-- rc.lua
-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
  c:activate({ context = "mouse_enter", raise = false })
end)
```

Move the mouse over a window and it takes focus. Delete these three lines later if that is not your taste.

## Running It Nested

Never iterate on your live session. Both compositors run nested in a window, pointed at whatever rc.lua you like. From the repo checkout, on SomeWM:

```bash
somewm-client test start --config "$PWD/rc.lua" --name afs
```

On AwesomeWM, use Xephyr:

```bash
Xephyr :1 -ac -br -noreset -screen 1280x720 &
DISPLAY=:1 awesome -c "$PWD/rc.lua"
```

Either way you get the stock desktop in a window: gray bar on top, nine tags, right-click menu. Open a terminal with `Mod4+Return`, cycle layouts with `Mod4+Space`, press `Mod4+s` for the help popup. The [series intro](./index.md) covers this setup in more detail, including the Mod4 remapping caveat for nested sessions, and there is a full guide at [testing with a nested compositor](../../guides/testing-with-nested-compositor.md).

## When You Break It

You will break it; that is part of the deal. What happens depends on where you were running:

- **In the nested session:** the nested compositor falls back to the default config or dies. Close the window, fix the file, start it again. Your real desktop never noticed.
- **On your real session:** the fallback config loads and a critical notification shows the error with a file and line number. Fix the line, press `Mod4+Control+r`, and you are back.

Hence the habit this series assumes from here on: edit, test in the nested session, and only then reload your real session. Syntax errors are even cheaper to catch: `luac -p rc.lua` checks the file compiles without running anything.

## The Road Ahead

Over the next twelve chapters this one file becomes a project. Chapter 01 replaces the default theme with a theme directory of our own; chapter 02 moves every binding into a table-driven `keybindings.lua`; chapters 03 and 04 build custom widgets and a new wibar around them; chapter 05 takes over rules and titlebars; chapter 06 replaces the notification defaults with a full system including history and a notification center; chapters 07 through 11 build a run of overlay UIs (exit screen, main menu, window switcher, launcher, dashboard) on a single modal pattern; and chapter 12 finishes with a native lockscreen. By the end, rc.lua itself is a short entry point that wires the modules together, and you will have written every one of them.

![The stock config: two tiled terminals under the default bar](/img/from-scratch/00-default-stock.png)

## Checkpoint

The code for this chapter is [the `00-default` branch](https://github.com/trip-zip/awesome-from-scratch/tree/00-default):

```bash
git checkout 00-default
somewm-client test start --config "$PWD/rc.lua" --name afs
```

There is no previous branch to diff against: this is the baseline every later `git diff` starts from.

<NextChapter chapter="00" />
