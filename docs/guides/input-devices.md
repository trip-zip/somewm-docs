---
sidebar_position: 1
title: Input Device Configuration
description: Configure pointer and keyboard settings at runtime
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Input Device Configuration <SomewmOnly />

## Overview

<!-- TODO: Write input devices guide
     - Source: lua/awful/input.lua
     - Explain awful.input module (somewm-only)
     - Pointer settings (tap_to_click, natural_scrolling, etc.)
     - Keyboard settings (repeat_rate, repeat_delay, layout)
     - Example rc.lua configuration
-->

SomeWM provides `awful.input` for runtime input device configuration - a feature not available in AwesomeWM.

## Pointer Settings

<!-- TODO: Examples for each property -->

```lua
local awful = require("awful")

-- Enable tap-to-click on touchpads
awful.input.tap_to_click = 1

-- Natural (inverted) scrolling
awful.input.natural_scrolling = 1

-- Pointer speed (-1.0 to 1.0)
awful.input.pointer_speed = 0.3
```

## Keyboard Settings

<!-- TODO: Layout, repeat rate/delay -->

```lua
-- Keyboard layout
awful.input.xkb_layout = "us"
awful.input.xkb_variant = ""
awful.input.xkb_options = "ctrl:nocaps"

-- Repeat settings
awful.input.repeat_rate = 25    -- keys per second
awful.input.repeat_delay = 600  -- ms before repeat starts
```

## All Properties

See [awful.input Reference](/reference/awful-input) for the complete property list.

## Next Steps

- [CLI Control](/guides/cli-control) - Control SomeWM from scripts
