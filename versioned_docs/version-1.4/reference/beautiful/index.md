---
sidebar_position: 1
title: beautiful
description: Theming and appearance configuration
---

# beautiful

The `beautiful` library handles theming in AwesomeWM/SomeWM. It loads theme files and provides access to theme variables throughout your configuration.

**Upstream documentation:** [awesomewm.org/apidoc/theme_related_libraries/beautiful.html](https://awesomewm.org/apidoc/theme_related_libraries/beautiful.html)

## Usage

```lua
local beautiful = require("beautiful")

-- Load a theme
beautiful.init(os.getenv("HOME") .. "/.config/somewm/theme.lua")

-- Access theme variables
local bg = beautiful.bg_normal
local font = beautiful.font
```

## Initialization Order

`beautiful.init()` must run before anything reads theme variables. The rules:

- Before `init()`, every theme variable is `nil`. Reading one produces no warning and no error.
- `init()` replaces the internal theme table. Values copied into locals before `init()` (for example `local bg = beautiful.bg_normal` at the top of a widget module) stay `nil`; a later `init()` does not update them. This is the usual cause of a custom widget that ignores the theme.
- Writes before `init()` are discarded: `beautiful.foo = x` lands in the table that `init()` throws away.
- The default font is `sans 8`. `init()` only changes it if the theme table defines `font`, and widgets built before `init()` keep the font they were built with.

Practical rule for `rc.lua`: call `beautiful.init()` early, and require modules that read theme variables (widgets, bars, `lockscreen.init()`) after it.

## Reference

| Reference | Description |
|-----------|-------------|
| [Theme Variables](./theme-variables) | Complete list of theme variables |

## Behavioral Notes

SomeWM's `beautiful` implementation is fully compatible with AwesomeWM. Theme files work identically.
