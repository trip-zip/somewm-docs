---
sidebar_position: 3
title: Add keybindings
description: Add custom keyboard shortcuts to SomeWM
---

# Add keybindings

Add a browser shortcut and a window-opacity toggle to the default 2.1 config. Keep its existing bindings.

Open your `rc.lua`. The default file already imports `awful` and defines `modkey = "Mod4"`. Install Firefox for the browser example, or substitute an application you have.

## Add a global shortcut

<span id="a-global-keybinding" />
<span id="the-help-popup" />

After the `modkey` definition, add:

```lua
awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, "b", function()
        awful.spawn("firefox")
    end, { description = "open browser", group = "launcher" }),
})
```

Reload with **Mod4+Ctrl+r**, then press **Mod4+b**. Firefox should open. Press **Mod4+s** and find “open browser” in the launcher group.

`awful.key` creates a binding. `append_global_keybindings` registers it. The arguments specify modifiers, key, callback, and help text. `{}` means no modifiers, and `{ modkey, "Shift" }` requires both keys.

## Add a shortcut for the focused window

<span id="a-client-keybinding" />
<span id="next" />

Find the existing `request::default_keybindings` handler. Add this entry inside its `awful.keyboard.append_client_keybindings({ ... })` table:

```lua
awful.key({ modkey, "Shift" }, "o", function(c)
    c.opacity = c.opacity == 1 and 0.8 or 1
end, { description = "toggle opacity", group = "client" }),
```

Reload, focus a window, and press **Mod4+Shift+o** twice. The window should become translucent, then opaque again. The callback receives the focused client as `c`.

The unmodified **Mod4+o** already moves a window to another screen, so this example adds Shift to avoid that conflict.

For another key, use the `sym:` name reported by `wev` on Wayland. See [key names](../reference/key-names.md) and [default bindings](../reference/default-keybindings.md) before assigning a shortcut.

If a shortcut does nothing, check the key name, reload the saved file, and look for duplicate bindings or an error notification. Test the application command in a terminal too.

To move bindings into a separate module, see [Keybinding Patterns](../guides/keybinding-patterns.md).
