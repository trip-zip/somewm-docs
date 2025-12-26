---
sidebar_position: 2
title: CLI Control
description: Control SomeWM from the command line with somewm-client
---

import YouWillLearn from '@site/src/components/YouWillLearn';
import SomewmOnly from '@site/src/components/SomewmOnly';

# CLI Control <SomewmOnly />

<YouWillLearn>

- How to use somewm-client for IPC
- Common commands for window management
- Scripting with somewm-client
- Evaluating Lua code from the command line

</YouWillLearn>

## Overview

<!-- TODO: Write CLI control guide
     - Source: somewm-client.c
     - Explain somewm-client tool (somewm-only)
     - Connection and ping
     - Client (window) commands
     - Input commands
     - Eval for arbitrary Lua
     - Scripting examples
-->

`somewm-client` is an IPC tool for controlling SomeWM from scripts and the command line.

## Basic Usage

```bash
# Check if SomeWM is running
somewm-client ping

# List all windows
somewm-client client list

# Focus a window by ID
somewm-client client focus 12345
```

## Window Management

<!-- TODO: client commands -->

## Input Settings

<!-- TODO: input commands -->

```bash
# Enable tap-to-click
somewm-client input tap_to_click 1

# Get current pointer speed
somewm-client input pointer_speed
```

## Lua Evaluation

<!-- TODO: eval command -->

```bash
# Run arbitrary Lua code
somewm-client eval "return awesome.version"

# More complex example
somewm-client eval "return #client.get()"
```

## Command Reference

See [somewm-client Reference](/reference/somewm-client) for all commands.
