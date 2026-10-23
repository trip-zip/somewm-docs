---
title: "Window Switcher"
description: "Build a Super+Tab window switcher that activates on modifier release."
sidebar_label: "09 · Window Switcher"
---

import ChapterNav from '@site/src/components/FromScratch/ChapterNav';
import NextChapter from '@site/src/components/FromScratch/NextChapter';

# Window Switcher

<ChapterNav chapter="09" />

<span id="where-we-are" />

Build a window switcher in `widgets/windowswitcher.lua`, ordered by most recently used.

To catch up: `git checkout 08-mainmenu`.

## Switching windows {#what-alt-tab-actually-means}

Hold Super and tap Tab to cycle through windows. Release Super to activate the selection. A quick Super+Tab returns to the previous window.

## Collecting Windows in MRU Order

Read `awful.client.focus.history.list` for most-recent-first ordering. Append clients missing from the history:

```lua
-- widgets/windowswitcher.lua
local function collect_clients()
  clients = {}
  local seen = {}

  for _, c in ipairs(awful.client.focus.history.list) do
    if (c:isvisible() or c.minimized) and not seen[c] then
      seen[c] = true
      table.insert(clients, c)
    end
  end

  for _, c in ipairs(client.get()) do
    if (c:isvisible() or c.minimized) and not seen[c] then
      seen[c] = true
      table.insert(clients, c)
    end
  end
end
```

The filter includes visible clients and minimised clients on any tag or screen. It excludes non-minimised clients on unselected tags.

## Why Selection Starts at Index 2

Here is `show()` picking the initial selection:

```lua
-- widgets/windowswitcher.lua
  collect_clients()
  if #clients == 0 then
    return
  end

  selected_index = math.min(2, #clients)
```

With a focused client first in the history, index 2 selects the previous window. `math.min` handles the one-window case.

## Drawing the List

Centre an `awful.popup` and highlight the selection with `beautiful.primary_color`. `config.max_items` limits it to ten rows. `create_client_list` scrolls the list to keep the selection visible. Rebuild the widget on selection changes:

```lua
-- widgets/windowswitcher.lua
local function refresh()
  if popup then
    popup.widget = create_popup_widget()
  end
end
```

Each row shows the client’s icon (`c.icon`), title (`c.name`), and application class (`c.class`). Use an initial when the icon is missing:

```lua
-- widgets/windowswitcher.lua
  else
    local initial = (c.class or c.name or "?"):sub(1, 1):upper()
```

Draw the initial in a `beautiful.primary_color` square. Truncate titles longer than 40 characters with `...`.

## Handling key releases {#why-this-is-not-a-modal}

The switcher handles modifier-key releases. `modal.lua` only handles key presses, so create a separate keygrabber.

Start it at the end of `show()`:

```lua
-- widgets/windowswitcher.lua
  keygrabber = awful.keygrabber({
    autostart = true,
    stop_key = nil,
    mask_modkeys = false, -- Receive modifier key events
    keypressed_callback = function(_, mod, key, _)
      if key == "Tab" then
```

`stop_key = nil` disables automatic stopping. `mask_modkeys = false` enables modifier-key events, including the Super release that activates the selection.

Inside `keypressed_callback`, Tab cycles forward and Shift+Tab cycles backward, wrapping at both ends:

```lua
-- widgets/windowswitcher.lua
        if shift_held then
          selected_index = selected_index - 1
          if selected_index < 1 then
            selected_index = #clients
          end
        else
          selected_index = selected_index + 1
          if selected_index > #clients then
            selected_index = 1
          end
        end
        refresh()
```

Read `shift_held` from the event’s `mod` table. Handle Return to activate immediately and Escape to cancel without switching.

Then the release-to-commit itself:

```lua
-- widgets/windowswitcher.lua
    keyreleased_callback = function(_, _, key, _)
      if key == "Super_L" or key == "Super_R" then
        windowswitcher.activate()
      end
    end,
```

Hide the popup if the grabber stops externally:

```lua
-- widgets/windowswitcher.lua
    stop_callback = function()
      if visible then
        windowswitcher.hide()
      end
    end,
```

`hide()` sets `visible = false` before stopping the grabber. Because `stop()` fires `stop_callback` synchronously, this guard prevents recursion.

## Committing the Switch

```lua
-- widgets/windowswitcher.lua
function windowswitcher.activate()
  if not visible then
    return
  end

  local c = clients[selected_index]

  windowswitcher.hide()

  if c then
    if c.minimized then
      c.minimized = false
    end
    c:jump_to()
  end
end
```

`c:jump_to()` switches to the client’s tag, raises it, and focuses it. Focus history updates so the next Super+Tab returns to the window you just left.

## Wiring the Keybinding

One line in the global keys table, using the table-driven format from [chapter 02](./02-keybindings.md):

```lua
-- keybindings.lua
  {{ modkey }, "Tab",                   windowswitcher.show,                                      "window switcher",                       "client"   },
```

Register the module in `widgets/init.lua`. While the switcher is open, its keygrabber handles subsequent Tab presses.

Reload with Super+Ctrl+r. Open a few windows, hold Super, and tap Tab. Release Super to activate the selection. The release handler checks `Super_L` and `Super_R` explicitly. If your nested session remaps Mod4 to Alt, add `Alt_L` and `Alt_R` here too, or press Return to activate.

## Try It

- **Show the tag next to each window.** Each client knows its tags via `c:tags()`, and `c.first_tag.name` gives the primary one. Add a small dimmed textbox to `create_client_item` so entries on other tags say where jumping will take you.
- **Limit the switcher to the current tag.** Add a second filter to `collect_clients` that keeps only clients on the selected tag (compare against `awful.screen.focused().selected_tag`). Bonus: bind it to a different key, and keep the global version on Super+Tab.

![The window switcher listing three terminals in most-recently-used order with the second selected](/img/from-scratch/09-switcher-open.png)

## Checkpoint

The complete files are on [the `09-switcher` branch](https://github.com/trip-zip/awesome-from-scratch/tree/09-switcher).

Use the [nested-session commands](index.md#running-your-work-safely) to run this checkpoint. Stop the previous instance before switching branches.

Compare your work: `git diff origin/08-mainmenu origin/09-switcher`

<NextChapter chapter="09" />
