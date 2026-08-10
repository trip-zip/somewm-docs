---
sidebar_position: 3
title: Keybindings
description: Add custom keyboard shortcuts to SomeWM
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Keybindings

<YouWillLearn>

- The four parts of an `awful.key` binding
- How to add a global keybinding and verify it works
- How to add a per-client keybinding
- How your bindings show up in the help popup

</YouWillLearn>

:::tip Building a full config?
This page retrofits one feature into an existing config. If you would rather build a complete desktop from the ground up, the [Awesome From Scratch](from-scratch/index.md) series covers this topic as part of a thirteen-chapter course.
:::

We will add two keybindings to your config: one that opens a browser from anywhere, and one that changes the focused window. By the end you will have pressed both and seen them listed in the built-in help popup.

## Your First Keybinding

Open your `rc.lua` and find the keybindings section (search for `append_global_keybindings`). Add a new binding:

```lua
awful.keyboard.append_global_keybindings({
    -- Your existing keybindings...

    -- Add a new one:
    awful.key({ modkey }, "b", function()
        awful.spawn("firefox")
    end, { description = "open browser", group = "launcher" }),
})
```

Press **Mod4 + Ctrl + r** to reload, then press **Mod4 + b**. Firefox opens and tiles into the current tag. That's the whole loop: edit, reload, press, observe.

## What You Just Wrote

Every binding has the same four parts:

```lua
awful.key(
    { modkey },           -- 1. Modifiers (a table; empty {} means none)
    "b",                  -- 2. Key
    function()            -- 3. Callback, runs on press
        awful.spawn("firefox")
    end,
    { description = "open browser", group = "launcher" }  -- 4. Metadata
)
```

The metadata is not decoration; you will see what it does in a moment. For the full list of key and modifier names, see the [Key Names Reference](/docs/reference/key-names).

## A Keybinding That Acts on a Window

Global bindings work anywhere. Client bindings only fire when a window is focused, and that window (`c`) is passed to your callback. Find the client keybindings section in your `rc.lua`:

```lua
client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
        -- Existing keybindings...

        -- Toggle window opacity:
        awful.key({ modkey }, "o", function(c)
            if c.opacity == 1 then
                c.opacity = 0.8
            else
                c.opacity = 1
            end
        end, { description = "toggle opacity", group = "client" }),
    })
end)
```

Reload with **Mod4 + Ctrl + r**, focus a terminal, and press **Mod4 + o**. The window turns translucent; whatever is behind it shows through. Press **Mod4 + o** again and it turns solid. Notice that pressing it with a different window focused affects *that* window: the `c` in your callback is always the focused client.

## See Your Bindings in the Help Popup

Press **Mod4 + s**.

{/* TODO: Screenshot needed
   - Hotkeys popup showing custom keybinding groups
   - Should show the "launcher" group with custom shortcuts
*/}

In the popup, find the **launcher** group: your "open browser" binding is listed there, next to the defaults. The **client** group now shows "toggle opacity". That is what the `description` and `group` metadata are for: every binding you write documents itself.

Press any key to dismiss the popup.

## What's Next?

You now know the edit-reload-press-observe loop and both binding kinds. From here:

- **[Keybinding patterns](../guides/keybinding-patterns.md)** - Media keys, binding the whole number row at once, mouse bindings, and organizing bindings as data or a module
- **[Key Names Reference](/docs/reference/key-names)** - Complete list of key names and modifiers
- **[Widgets](/docs/tutorials/widgets)** - Create custom widgets

## Troubleshooting

### Keybinding not working

1. Check for typos in key names (they're case-sensitive for modifiers)
2. Look for conflicts with existing keybindings
3. Make sure you reloaded config with **Mod4 + Ctrl + r**

### Callback errors

Check the notification for error messages. Common issues:

- Missing `local` for variables
- Typos in function names
- Missing `end` for functions
