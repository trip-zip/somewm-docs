---
sidebar_position: 10
title: Key Names
description: Modifier keys and key name reference
---

# Key Names

Names you can pass to `awful.key` and `awful.button`. For the full enumeration of every keysym SomeWM accepts (~2,629 entries including international and dead keys), see **[All Keysyms](/docs/1.4/reference/key-names-all)**.

:::tip Case-insensitive
SomeWM resolves keys via `xkb_keysym_from_name()` with the case-insensitive flag set. `"Return"`, `"return"`, and `"RETURN"` all resolve to the same keysym.
:::

## Finding a Key's Name

Run `wev` inside SomeWM to read keysyms:

```
$ wev
[        14:     wl_keyboard] key: serial: 84; time: 9302175; key: 115; state: 1 (pressed)
                      sym: XF86AudioRaiseVolume (269025043), utf8: ''
```

Pass the `sym:` value to `awful.key`.

This matters most where the name is not what is printed on the keycap. `,` reports `comma`, `;` reports `semicolon`, and Page Up reports `Prior`.

Install your distribution’s `wev` package if the command is missing.

## Modifier Keys

Pass modifiers as the first argument to `awful.key`.

| Name | Common Name | Notes |
| --- | --- | --- |
| `"Mod4"` | Super / Windows / Meta | The key with the Windows logo |
| `"Mod1"` | Alt | Left or Right Alt |
| `"Shift"` | Shift | Either Shift key |
| `"Control"` | Ctrl | Either Control key |
| `"Ctrl"` | alias for `"Control"` | Convenience alias |
| `"Lock"` | Caps Lock | Toggleable lock state |
| `"Mod2"` | Mod2 | Often Num Lock on common layouts |
| `"Mod3"` | Mod3 | Layout-dependent |
| `"Mod5"` | Mod5 | Often AltGr / ISO Level 3 |
| `"Any"` | wildcard | Matches any modifier combination |

### Combining Modifiers

| Combination | Modifier table |
| --- | --- |
| Super | `{ "Mod4" }` |
| Super + Shift | `{ "Mod4", "Shift" }` |
| Super + Ctrl | `{ "Mod4", "Control" }` |
| Alt + Shift | `{ "Mod1", "Shift" }` |
| Super + Alt | `{ "Mod4", "Mod1" }` |
| Super + Ctrl + Shift | `{ "Mod4", "Control", "Shift" }` |
| Any modifiers | `{ "Any" }` |

`"Super"` and `"Alt"` are not modifier aliases in 1.4. Use `"Mod4"` and `"Mod1"`.

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

Constructing a key object does not register it. Global and client bindings use different registration functions:

```lua
local awful = require("awful")

awful.keyboard.append_global_keybindings({
    awful.key({ "Mod4" }, "Return", function()
        awful.spawn("kitty")
    end, { description = "open terminal", group = "launcher" }),
})

client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
        awful.key({ "Mod4", "Shift" }, "c", function(c)
            c:kill()
        end, { description = "close", group = "client" }),
    })
end)
```

The [keybindings tutorial](../tutorials/keybindings.md) covers mouse bindings and media keys.

## See Also

- [All Keysyms](/docs/1.4/reference/key-names-all) – Full enumeration of every xkbcommon keysym
- [Keybindings Tutorial](/docs/1.4/tutorials/keybindings) – Learn how to create keybindings
- [Default Keybindings](/docs/1.4/reference/default-keybindings) – Built-in shortcuts
- [awful.key (AwesomeWM docs)](https://awesomewm.org/apidoc/libraries/awful.key.html) – Complete API reference
