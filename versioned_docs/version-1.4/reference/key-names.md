---
sidebar_position: 10
title: Key Names
description: Modifier keys and key name reference
---

# Key Names

Names you can pass to `awful.key` and `awful.button`. For the full enumeration of every keysym SomeWM accepts (~2,629 entries including international and dead keys), see **[All Keysyms](/docs/reference/key-names-all)**.

:::tip Case-insensitive
SomeWM resolves keys via `xkb_keysym_from_name()` with the case-insensitive flag set. `"Return"`, `"return"`, and `"RETURN"` all resolve to the same keysym.
:::

## Modifier Keys

Passed as a Lua table — the first argument to `awful.key`.

| Name | Common Name | Notes |
| --- | --- | --- |
| `"Mod4"` | Super / Windows / Meta | The key with the Windows logo |
| `"Super"` | alias for `"Mod4"` | Convenience alias |
| `"Mod1"` | Alt | Left or Right Alt |
| `"Alt"` | alias for `"Mod1"` | Convenience alias |
| `"Shift"` | Shift | Either Shift key |
| `"Control"` | Ctrl | Either Control key |
| `"Ctrl"` | alias for `"Control"` | Convenience alias |
| `"Lock"` | Caps Lock / Num Lock | Toggleable lock state |
| `"Mod2"` | Mod2 | Often Num Lock on common layouts |
| `"Mod3"` | Mod3 | Layout-dependent |
| `"Mod5"` | Mod5 | Often AltGr / ISO Level 3 |
| `"Any"` | wildcard | Matches any modifier combination |

### Combining Modifiers

```lua
{ modkey }                      -- Mod4 only
{ modkey, "Shift" }             -- Mod4 + Shift
{ modkey, "Control" }           -- Mod4 + Ctrl
{ "Mod1", "Shift" }             -- Alt + Shift
{ modkey, "Mod1" }              -- Mod4 + Alt
{ modkey, "Control", "Shift" }  -- Mod4 + Ctrl + Shift
{ "Any" }                       -- match regardless of modifiers
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
| Menu | `"Menu"` |
| Print Screen | `"Print"` |
| Pause | `"Pause"` |
| Caps Lock | `"Caps_Lock"` |
| Num Lock | `"Num_Lock"` |
| Scroll Lock | `"Scroll_Lock"` |

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
| F1 – F12 | `"F1"` through `"F12"` |
| F13 – F35 | `"F13"` through `"F35"` (available, rarely physical) |

## Letters and Numbers

| Key | Lua Name |
|-----|----------|
| Letters | `"a"` through `"z"` (lowercase) |
| Numbers | `"0"` through `"9"` |

## Punctuation

| Key | Lua Name |
|-----|----------|
| Comma `,` | `"comma"` |
| Period `.` | `"period"` |
| Semicolon `;` | `"semicolon"` |
| Colon `:` | `"colon"` |
| Apostrophe `'` | `"apostrophe"` |
| Quote `"` | `"quotedbl"` |
| Grave `` ` `` | `"grave"` |
| Tilde `~` | `"asciitilde"` |
| Minus `-` | `"minus"` |
| Equal `=` | `"equal"` |
| Plus `+` | `"plus"` |
| Underscore `_` | `"underscore"` |
| Left Bracket `[` | `"bracketleft"` |
| Right Bracket `]` | `"bracketright"` |
| Backslash `\` | `"backslash"` |
| Slash `/` | `"slash"` |
| Question Mark `?` | `"question"` |
| Exclamation `!` | `"exclam"` |
| At `@` | `"at"` |
| Hash `#` | `"numbersign"` |

## Keypad

| Key | Lua Name |
|-----|----------|
| Keypad 0 – 9 | `"KP_0"` through `"KP_9"` |
| Keypad Enter | `"KP_Enter"` |
| Keypad + / - / * / / | `"KP_Add"` / `"KP_Subtract"` / `"KP_Multiply"` / `"KP_Divide"` |
| Keypad Decimal | `"KP_Decimal"` |
| Keypad Equal | `"KP_Equal"` |

## Media Keys

| Key | Lua Name |
|-----|----------|
| Volume Up | `"XF86AudioRaiseVolume"` |
| Volume Down | `"XF86AudioLowerVolume"` |
| Mute | `"XF86AudioMute"` |
| Mic Mute | `"XF86AudioMicMute"` |
| Play/Pause | `"XF86AudioPlay"` |
| Pause | `"XF86AudioPause"` |
| Stop | `"XF86AudioStop"` |
| Previous | `"XF86AudioPrev"` |
| Next | `"XF86AudioNext"` |
| Brightness Up | `"XF86MonBrightnessUp"` |
| Brightness Down | `"XF86MonBrightnessDown"` |
| Keyboard Backlight Up | `"XF86KbdBrightnessUp"` |
| Keyboard Backlight Down | `"XF86KbdBrightnessDown"` |
| Search | `"XF86Search"` |
| Calculator | `"XF86Calculator"` |
| Mail | `"XF86Mail"` |
| Browser | `"XF86WWW"` |

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

- [All Keysyms](/docs/reference/key-names-all) – Full enumeration of every xkbcommon keysym
- [Keybindings Tutorial](/docs/tutorials/keybindings) – Learn how to create keybindings
- [Default Keybindings](/docs/reference/default-keybindings) – Built-in shortcuts
- [awful.key (AwesomeWM docs)](https://awesomewm.org/apidoc/libraries/awful.key.html) – Complete API reference
