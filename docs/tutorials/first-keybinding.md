---
sidebar_position: 3
title: Your First Keybinding
description: Add custom keyboard shortcuts to SomeWM
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Your First Keybinding

<YouWillLearn>

- How keybindings work in SomeWM
- Adding global keybindings
- Adding client-specific keybindings
- Using modifier keys

</YouWillLearn>

## Overview

<!-- TODO: Write keybinding tutorial
     - Explain awful.key structure
     - Global vs client keybindings
     - Modifier key reference
     - Common keybinding patterns
-->

## Keybinding Basics

<!-- TODO: Explain awful.key API -->

```lua
-- Example structure (placeholder)
awful.keyboard.append_global_keybindings({
    awful.key({ "Mod4" }, "p", function()
        -- TODO: action
    end, {description = "example", group = "custom"})
})
```

## Global Keybindings

<!-- TODO: Examples -->

## Client Keybindings

<!-- TODO: Examples -->

## The Help Popup

<!-- TODO: Mod4+s shows keybinding help -->

## Next Steps

- [First Theme](/tutorials/first-theme) - Customize colors and fonts
- [Default Keybindings](/reference/default-keybindings) - Full keybinding reference
