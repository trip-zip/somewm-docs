---
sidebar_position: 3
title: Multi-Monitor Setup
description: Configure multiple screens and outputs
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Multi-Monitor Setup

<YouWillLearn>

- How SomeWM handles multiple screens
- Configuring screen layouts
- Moving clients between screens
- Per-screen wiboxes and tags

</YouWillLearn>

## Overview

<!-- TODO: Write multi-monitor guide
     - Screen detection and signals
     - screen.connect_signal for dynamic setup
     - Per-screen tags and wibox
     - Moving windows between screens
     - Screen geometry and workarea
-->

## Screen Signals

<!-- TODO: screen::added, screen::removed -->

## Per-Screen Setup

<!-- TODO: Example for_each_screen -->

```lua
awful.screen.connect_for_each_screen(function(s)
    -- TODO: Per-screen setup example
end)
```

## Moving Windows

<!-- TODO: Keybindings for screen movement -->

## Troubleshooting

<!-- TODO: Common issues -->

## Next Steps

- [AwesomeWM Screen Docs](https://awesomewm.org/doc/api/classes/screen.html) - Full screen API
