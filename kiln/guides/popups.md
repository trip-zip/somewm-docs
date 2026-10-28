---
title: Create a Popup
description: Declare a popup with keyboard and outside-click dismissal.
---

# Create a Popup

Add this to `rc.lua`. It assumes the config already creates tags and a bar.
Construct the popup once per config load; the keybinding opens it.

```lua
local kiln = require("kiln")
local ui = kiln.ui

local panel = ui.popup {
  id = "session-panel",
  w = 240, pad = 12, gap = 8,
  color = kiln.theme.bg,
  scrim = "#00000080",
  keys = { Escape = "close" },
  fn = function(popup, s)
    ui.text("Screen: " .. s.name)
    ui.box({
      color = kiln.theme.bg2, pad = 8,
      on_press = function() popup:close() end,
    }, function()
      ui.text("Close")
    end)
  end,
}

kiln.key {
  mods = { "mod", "shift" }, key = "p",
  desc = "session panel", group = "system",
  press = function() panel:toggle() end,
}
```

Reload and press your modkey with Shift+P. The panel opens in the centre of the
focused screen. Escape, Close, or a click outside dismisses it.

While open, the panel consumes all keyboard input. The opening binding cannot
toggle it closed because the popup owns the keyboard. Remove `keys` if bindings
and client keyboard input should remain available.

To attach it to an element, add `under = "launcher"`, where `launcher` is an
element ID declared earlier on that screen. The popup closes if the anchor
leaves the tree. Use `at = { x = 40, y = 80 }` instead for an output-local
position.

Closing retains the controller for reuse. Call `panel:destroy()` when removing
it permanently. Reload unregisters it automatically and runs this construction
again. See the [popup reference](../reference/ui.md#popups) for all fields.
