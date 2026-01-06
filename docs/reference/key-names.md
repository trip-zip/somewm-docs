---
sidebar_position: 10
title: Key Names
description: Modifier keys and key name reference
---

# Key Names

Reference for key names used in keybindings.

## Modifier Keys

| Modifier | Common Name | Description |
|----------|-------------|-------------|
| `"Mod4"` | Super/Windows | The key with the Windows logo |
| `"Mod1"` | Alt | Left or Right Alt |
| `"Shift"` | Shift | Either Shift key |
| `"Control"` | Ctrl | Either Control key |

### Combining Modifiers

Combine modifiers in a table:

```lua
{ modkey }                -- Mod4 only
{ modkey, "Shift" }       -- Mod4 + Shift
{ modkey, "Control" }     -- Mod4 + Ctrl
{ "Mod1", "Shift" }       -- Alt + Shift
{ modkey, "Mod1" }        -- Mod4 + Alt
{ modkey, "Control", "Shift" }  -- Mod4 + Ctrl + Shift
```

## Common Key Names

| Key | Lua Name |
|-----|----------|
| Enter | `"Return"` |
| Space | `"space"` |
| Tab | `"Tab"` |
| Escape | `"Escape"` |
| Backspace | `"BackSpace"` |
| Delete | `"Delete"` |
| Insert | `"Insert"` |
| Home | `"Home"` |
| End | `"End"` |
| Page Up | `"Prior"` |
| Page Down | `"Next"` |

## Arrow Keys

| Key | Lua Name |
|-----|----------|
| Left Arrow | `"Left"` |
| Right Arrow | `"Right"` |
| Up Arrow | `"Up"` |
| Down Arrow | `"Down"` |

## Function Keys

| Key | Lua Name |
|-----|----------|
| F1 - F12 | `"F1"` through `"F12"` |

## Letters and Numbers

| Key | Lua Name |
|-----|----------|
| Letters | `"a"` through `"z"` (lowercase) |
| Numbers | `"1"` through `"0"` |

## Media Keys

| Key | Lua Name |
|-----|----------|
| Volume Up | `"XF86AudioRaiseVolume"` |
| Volume Down | `"XF86AudioLowerVolume"` |
| Mute | `"XF86AudioMute"` |
| Play/Pause | `"XF86AudioPlay"` |
| Stop | `"XF86AudioStop"` |
| Previous | `"XF86AudioPrev"` |
| Next | `"XF86AudioNext"` |
| Brightness Up | `"XF86MonBrightnessUp"` |
| Brightness Down | `"XF86MonBrightnessDown"` |

## Mouse Buttons

| Button | Number |
|--------|--------|
| Left click | `1` |
| Middle click | `2` |
| Right click | `3` |
| Scroll up | `4` |
| Scroll down | `5` |
| Scroll left | `6` |
| Scroll right | `7` |
| Back | `8` |
| Forward | `9` |

## Examples

```lua
-- Global keybinding
awful.key({ modkey }, "Return", function()
    awful.spawn(terminal)
end, { description = "open terminal", group = "launcher" })

-- Keybinding with multiple modifiers
awful.key({ modkey, "Shift" }, "c", function(c)
    c:kill()
end, { description = "close", group = "client" })

-- Media key (no modifier)
awful.key({}, "XF86AudioRaiseVolume", function()
    awful.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")
end, { description = "raise volume", group = "media" })

-- Mouse binding
awful.button({ modkey }, 1, function(c)
    c:activate({ context = "mouse_click", action = "mouse_move" })
end)
```

## See Also

- [Keybindings Tutorial](/tutorials/keybindings) - Learn how to create keybindings
- [Default Keybindings](/reference/default-keybindings) - Built-in shortcuts
- [awful.key (AwesomeWM docs)](https://awesomewm.org/apidoc/libraries/awful.key.html) - Complete API reference
