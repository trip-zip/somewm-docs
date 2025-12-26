---
sidebar_position: 6
title: Screenshots
description: Taking screenshots with SomeWM
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Screenshots

<YouWillLearn>

- Using awful.screenshot for native screenshots
- Alternative tools (grim, slurp)
- Setting up screenshot keybindings
- Saving to files vs clipboard

</YouWillLearn>

## Overview

<!-- TODO: Write screenshots guide
     - awful.screenshot (native)
     - grim/slurp for Wayland
     - wl-copy for clipboard
     - Keybinding examples
-->

## Using awful.screenshot

<!-- TODO: Built-in screenshot support -->

```lua
-- Example placeholder
awful.screenshot({ directory = "~/Pictures" })
```

## Using grim and slurp

<!-- TODO: External tools -->

```bash
# Full screen
grim ~/screenshot.png

# Select region
grim -g "$(slurp)" ~/screenshot.png
```

## Keybinding Setup

<!-- TODO: Example keybindings -->

## Clipboard Support

<!-- TODO: wl-copy integration -->

## Next Steps

- [AwesomeWM Screenshot Docs](https://awesomewm.org/doc/api/libraries/awful.screenshot.html)
