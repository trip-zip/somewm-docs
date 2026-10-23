---
sidebar_position: 1
title: beautiful
description: Theming and appearance configuration
---

# beautiful

`beautiful` loads a theme table and exposes its values as properties.

**Upstream documentation:** [awesomewm.org/apidoc/theme_related_libraries/beautiful.html](https://awesomewm.org/apidoc/theme_related_libraries/beautiful.html)

## Usage

```lua
local beautiful = require("beautiful")

beautiful.init({ bg_normal = "#222222", font = "sans 10" })

-- Access theme variables
local bg = beautiful.bg_normal
local font = beautiful.font
```

## Initialization Order

`beautiful.init(table_or_path)` replaces the theme table. A file must return a nonempty table. The function returns `true` on success or `nil` on failure.

Load the theme before constructing widgets or requiring modules that copy theme values. Existing locals and widgets do not automatically update when the table changes. Assignments made before `init()` are replaced by the loaded theme.

The font starts as `sans 8`. A theme’s `font` changes that default for subsequent widget construction.

## Reference

| Reference | Description |
|-----------|-------------|
| [Theme Variables](./theme-variables) | Complete list of theme variables |

## Behavioral Notes

Theme variables and GTK theme discovery follow the [compatibility reference](../deviations.md#architectural-differences) for this release. Use the [theme variable reference](theme-variables.md) for supported names.
