---
sidebar_position: 1
title: beautiful
description: Theming and appearance configuration
---

# beautiful

The `beautiful` library handles theming in AwesomeWM/SomeWM. It loads theme files and provides access to theme variables throughout your configuration.

**Upstream documentation:** [awesomewm.org/apidoc/libraries/beautiful.html](https://awesomewm.org/apidoc/libraries/beautiful.html)

## Usage

```lua
local beautiful = require("beautiful")

-- Load a theme
beautiful.init("~/.config/awesome/theme.lua")

-- Access theme variables
local bg = beautiful.bg_normal
local font = beautiful.font
```

## Reference

| Reference | Description |
|-----------|-------------|
| [Theme Variables](./theme-variables) | Complete list of theme variables |

## Behavioral Notes

SomeWM's `beautiful` implementation is fully compatible with AwesomeWM. Theme files work identically.
