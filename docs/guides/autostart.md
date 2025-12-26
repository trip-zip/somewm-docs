---
sidebar_position: 4
title: Autostart Applications
description: Starting applications when SomeWM launches
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Autostart Applications

<YouWillLearn>

- Different methods to autostart applications
- Using awful.spawn.once vs awful.spawn
- Handling applications that should only run once
- Integration with systemd user services

</YouWillLearn>

## Overview

<!-- TODO: Write autostart guide
     - awful.spawn vs awful.spawn.once
     - Checking if already running
     - Startup notification
     - systemd user services alternative
-->

## Basic Autostart

<!-- TODO: Simple examples -->

```lua
-- Run once per session
awful.spawn.once("picom")
awful.spawn.once("nm-applet")
```

## Run vs Run Once

<!-- TODO: Explain the difference -->

## Using spawn_with_shell

<!-- TODO: For complex commands -->

## Systemd Integration

<!-- TODO: User services as alternative -->

## Next Steps

- [AwesomeWM Spawn Docs](https://awesomewm.org/doc/api/libraries/awful.spawn.html)
