---
slug: /
sidebar_position: 1
title: Welcome to SomeWM
description: AwesomeWM on Wayland - 100% Lua API compatibility
---

# Welcome to SomeWM

**SomeWM** is a Wayland compositor that brings AwesomeWM's Lua API to Wayland, built on [wlroots](https://gitlab.freedesktop.org/wlroots/wlroots). The goal is 100% compatibility with AwesomeWM's Lua configuration.

## What is SomeWM?

If you love AwesomeWM but want to run on Wayland, SomeWM is for you. Your existing `rc.lua` should work with minimal changes.

## Quick Links

<div className="row">
  <div className="col col--6">
    <h3>New to SomeWM?</h3>
    <ul>
      <li><a href="/getting-started/installation">Installation Guide</a></li>
      <li><a href="/getting-started/first-launch">First Launch</a></li>
      <li><a href="/tutorials/my-first-somewm">My First SomeWM</a></li>
    </ul>
  </div>
  <div className="col col--6">
    <h3>Coming from AwesomeWM?</h3>
    <ul>
      <li><a href="/getting-started/migrating">Migration Guide</a></li>
      <li><a href="/concepts/wayland-vs-x11">Wayland vs X11</a></li>
      <li><a href="/concepts/awesomewm-compat">Compatibility</a></li>
    </ul>
  </div>
</div>

## SomeWM-Only Features

SomeWM extends AwesomeWM with Wayland-native features:

- **[`awful.input`](/reference/awful-input)** - Runtime input device configuration (tap-to-click, natural scrolling, pointer speed)
- **[`somewm-client`](/reference/somewm-client)** - IPC CLI tool for external control (~45 commands)
- **SNI Systray** - Modern D-Bus tray protocol (StatusNotifierItem)

## Current Status

SomeWM is in active development. Most AwesomeWM functionality works, including:

- Window management and tiling layouts
- Wibox widgets and titlebars
- Keybindings and mouse bindings
- Tags and screens
- Notifications (naughty)
- Theming

See [Current Limitations](/troubleshooting#current-limitations) for features not yet implemented.
