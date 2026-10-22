---
title: "Keybindings: A Table You Can Read"
description: Extract every keybinding into its own module, flatten the awful.key boilerplate into a scannable table, and learn how global, client, and tag bindings differ.
sidebar_label: "02 · Keybindings"
---

import ChapterNav from '@site/src/components/FromScratch/ChapterNav';
import NextChapter from '@site/src/components/FromScratch/NextChapter';

# Keybindings: A Table You Can Read

<ChapterNav chapter="02" />

## Where We Are

Move bindings into `keybindings.lua` and store each as a table row. Start from [chapter 01](./01-theme.md): `git checkout 01-theme`.

## Extract the Bindings {#a-third-of-your-config-is-keybindings}

Move the global, client, mouse, and tag bindings from `rc.lua` into `keybindings.lua`. Replace them in `rc.lua` with:

```lua
-- rc.lua
require("keybindings")
```

## How require Finds the Module

Keep these lines at the top of `rc.lua` so `require` can find modules beside it:

```lua
-- rc.lua
local config_dir = require("gears.filesystem").get_configuration_dir()
package.path = config_dir .. "?.lua;" .. config_dir .. "?/init.lua;" .. package.path
```

`require` replaces `?` in each `package.path` template with the module name. The added paths find `keybindings.lua` and, for directory modules, files such as `dashboard/init.lua`.

`get_configuration_dir()` returns the directory of the loaded `rc.lua`, including when running from a checkout.

Define `terminal`, `filemanager`, and `modkey` in `rc.lua` before `require("keybindings")`. Keep them global (without `local`), because the module reads them directly.

## The Anatomy of awful.key

A stock binding looks like this:

```lua
-- rc.lua (before, on 01-theme)
  awful.key({ modkey }, "j", function()
    awful.client.focus.byidx(1)
  end, { description = "focus next by index", group = "client" }),
```

`awful.key` takes four things:

1. **Modifiers.** `{ modkey }` means Super; `{ modkey, "Shift" }` requires both. `{}` requires no modifier.
2. **Key.** A letter, named key, or keysym such as `"XF86AudioRaiseVolume"`. Names are case-insensitive. Use [Key Names](../../reference/key-names.md) or the `sym:` field from `wev` to identify keys: comma is `"comma"`, Page Up is `"Prior"`.
3. **Callback.** Runs on press; client callbacks receive the focused client. Pass a function, such as `media_helpers.lower_volume`, rather than calling it during setup.
4. **Description table.** `description` labels the binding and `group` organises it in the Mod+S help popup.

## One Row Per Binding

Define a converter from table rows to `awful.key` objects:

```lua
-- keybindings.lua
local function table_to_keybinding(bindings)
  local key_bindings = {}
  for _, g_key in ipairs(bindings) do
    table.insert(key_bindings, awful.key(g_key[1], g_key[2], g_key[3], { description = g_key[4], group = g_key[5] }))
  end
  return key_bindings
end
```

Each row is `{modifiers, key, callback, description, group}`.

Start `global_keys` with the media bindings:

```lua
-- keybindings.lua
--{modifier(s) table, key string,          function function,                     description string,    group string}
local global_keys = {
  -- no modifiers
  {{},         "XF86AudioLowerVolume",  media_helpers.lower_volume,                               "decrease volume",                       "media"    },
  {{},         "XF86AudioRaiseVolume",  media_helpers.raise_volume,                               "increase volume",                       "media"    },
  {{},         "XF86MonBrightnessDown", function() awful.spawn("brightnessctl s 5%-") end,        "decrease brightness",                   "media"    },
  {{},         "XF86MonBrightnessUp",   function() awful.spawn("brightnessctl s +5%") end,        "increase brightness",                   "media"    },
  {{},         "XF86AudioMute",         media_helpers.toggle_mute,                                "mute volume",                           "media"    },
```

Media keys use an empty modifiers table. The branch also includes `playerctl` bindings for next, play/pause, and previous.

Group the remaining rows by modifier, then sort by key:

```lua
-- keybindings.lua
  {{ modkey }, "j",                     function () awful.client.focus.byidx( 1) end,             "focus next by index",                   "client"   },
  {{ modkey }, "k",                     function () awful.client.focus.byidx(-1) end,             "focus previous by index",               "client"   },
  {{ modkey }, "s",                     hotkeys_popup.show_help,                                  "show help",                             "awesome"  },
  {{ modkey }, "Return",                function () awful.spawn(terminal) end,                    "open a terminal",                       "launcher" },
```

## Helper Tables

Define longer callbacks in `global_helpers`, `client_helpers`, and `media_helpers` above `global_keys`. Reference each helper by name in the row.

For example:

```lua
-- keybindings.lua
local client_helpers = {
  toggle_fullscreen = function(c)
    c.fullscreen = not c.fullscreen
    c:raise()
  end,
  minimize = function(c)
    -- The client currently has the input focus, so it cannot be
    -- minimized, since minimized clients can't have the focus.
    c.minimized = true
  end,
```

The branch replaces the deprecated `awful.client.floating.toggle` with direct assignment to `c.floating`, and `awful.client.getmaster()` with the first entry from `awful.client.visible(c.screen)`.

The volume helper runs `wpctl` and emits a custom signal:

```lua
-- keybindings.lua
local media_helpers = {
  raise_volume = function()
    awful.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")
    awesome.emit_signal("volume::update")
  end,
```

`awful.spawn` starts the command asynchronously. `awesome.emit_signal("volume::update")` tells listeners to refresh; [chapter 03](./03-widgets.md) connects the volume widget to this signal. No listener is needed yet.

## Global Keys and Client Keys Register Differently

Register the bindings after defining both tables:

```lua
-- keybindings.lua
client.connect_signal("request::default_keybindings", function()
  awful.keyboard.append_client_keybindings(table_to_keybinding(client_keys))
end)
awful.keyboard.append_global_keybindings(table_to_keybinding(global_keys))
```

**Global keybindings** work with or without a focused window. `append_global_keybindings` registers them immediately when the module loads.

**Client keybindings** act on the focused window, passed as `c` to the callback. Register them inside the startup `request::default_keybindings` handler with `append_client_keybindings`.

Define `client_keys` using the same row format:

```lua
-- keybindings.lua
local client_keys = {
  -- modkey only modifier
  {{ modkey },            "f",      client_helpers.toggle_fullscreen,       "toggle fullscreen",         "client" },
  {{ modkey },            "m",      client_helpers.toggle_maximized,        "(un)maximize",              "client" },
  {{ modkey },            "n",      client_helpers.minimize,                "minimize",                  "client" },
  {{ modkey },            "o",      function (c) c:move_to_screen() end,    "move to screen",            "client" },
  {{ modkey },            "q",      function (c) c:kill() end,              "close",                     "client" },
```

Keep the stock `request::default_mousebindings` handler at the bottom of the module. It registers click-to-focus, Mod+drag-to-move, and Mod+right-drag-to-resize.

## Nine Keys, One Binding

Keep the tag bindings in `awful.key`’s declarative form:

```lua
-- keybindings.lua
  awful.key({
    modifiers = { modkey },
    keygroup = "numrow",
    description = "only view tag",
    group = "tag",
    on_press = function(index)
      local screen = awful.screen.focused()
      local tag = screen.tags[index]
      if tag then
        tag:view_only()
      end
    end,
  }),
```

`keygroup = "numrow"` covers keys 1 through 9. The callback receives the key’s position as `index`, and the help popup groups them as "1..9".

Keep the four tag actions: view, toggle, move client to tag, and toggle client on tag. The fifth declaration uses `keygroup = "numpad"` to select a layout. See the branch for their callbacks.

## Try It

1. Add a row to `global_keys` that launches your browser on Mod+B, with a sensible description in the `"launcher"` group. Press Mod+S afterwards and find it in the popup.
2. Change the terminal. `terminal` is a global defined in rc.lua, so the Mod+Return row should not need to change at all. Prove it.

![The hotkeys popup on Mod+S listing the migrated keybindings by group](/img/from-scratch/02-keybindings-hotkeys.png)

## Checkpoint

The finished code is on [the `02-keybindings` branch](https://github.com/trip-zip/awesome-from-scratch/tree/02-keybindings).

```bash
git checkout 02-keybindings
somewm-client test start --config "$PWD/rc.lua" --name afs
```

Compare your work: `git diff 01-theme 02-keybindings`

<NextChapter chapter="02" />
