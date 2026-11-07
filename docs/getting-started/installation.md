---
sidebar_position: 1
title: Installation
description: Build and install SomeWM on your system
---

# Installation

Install dependencies for your distribution, then build the development version below. You can also [try SomeWM in a nested session](../tutorials/try-somewm-without-installing.md) without installing it system-wide.

## Dependencies

SomeWM uses system wlroots 0.20.2 or newer in the 0.20 series, including development headers. No wlroots patch is needed.

Install Wayland 1.24.0, libdrm 2.4.129, xkbcommon 1.8.0 and wayland-protocols 1.47 or newer, plus the packages below.

XWayland support is always built in. Install the Xwayland binary to run X11 applications.

### Arch Linux

<span id="from-the-aur-recommended" />

#### From the AUR

```bash
yay -S somewm-git
```

`paru -S somewm-git` is an alternative. This package follows development. For a released version, use the documentation version switcher.

The package builds against LuaJIT. To build against another Lua, install its LGI package and set `SOMEWM_LUA`:

```bash
sudo pacman -S lua54-lgi
SOMEWM_LUA=5.4 yay -S somewm-git
```

`SOMEWM_LUA` accepts `luajit`, `5.1`, `5.3`, `5.4` and `5.5`. yay still installs LuaJIT, because the AUR lists the default dependencies. Add `--rebuild` if yay already built this version with a different Lua.

#### Manual Build

```bash
sudo pacman -S --needed base-devel git meson ninja pkgconf luajit lua51-lgi \
    cairo pango gdk-pixbuf2 librsvg glib2 dbus wayland wayland-protocols \
    wlroots0.20 libinput libxkbcommon pixman libdrm mesa libglvnd libffi \
    xorg-xwayland libxcb xcb-util-wm
```

### Debian/Ubuntu

If your release does not package `libwlroots-0.20-dev` at the required version, install it separately or upgrade your distribution.

```bash
sudo apt install build-essential git meson ninja-build pkg-config \
    luajit libluajit-5.1-dev lua-lgi libcairo2-dev libpango1.0-dev \
    libgdk-pixbuf-2.0-dev librsvg2-dev libglib2.0-dev libdbus-1-dev \
    libwlroots-0.20-dev libwayland-dev libwayland-bin wayland-protocols \
    libdrm-dev libinput-dev libxkbcommon-dev libegl-dev libgles-dev \
    libpixman-1-dev libffi-dev xwayland libxcb1-dev libxcb-icccm4-dev
```

Optional packages:

- `libpam0g-dev` for built-in lockscreen authentication
- `systemd-dev` for systemd session integration

### Fedora

```bash
sudo dnf install gcc make git meson ninja-build pkgconf-pkg-config \
    luajit luajit-devel lua-lgi cairo-devel pango-devel gdk-pixbuf2-devel \
    librsvg2-devel glib2-devel dbus-devel wayland-devel wayland-protocols-devel \
    wlroots-devel libdrm-devel libinput-devel libxkbcommon-devel \
    libglvnd-egl-devel libglvnd-gles-devel pixman-devel libffi-devel \
    systemd-devel xorg-x11-server-Xwayland libxcb-devel xcb-util-wm-devel
```

### Gentoo

The third-party [somewm-gentoo-overlay](https://github.com/shuber2/somewm-gentoo-overlay) packages SomeWM. As root:

```bash
eselect repository add somewm git https://github.com/shuber2/somewm-gentoo-overlay.git
emaint sync -r somewm
echo 'gui-wm/somewm ~amd64' >> /etc/portage/package.accept_keywords/somewm
emerge -av gui-wm/somewm
```

Check the selected ebuild's version. A `9999` ebuild follows development rather than a fixed release.

## Build and Install

```bash
git clone --branch main https://github.com/trip-zip/somewm
cd somewm
make
sudo make install
```

A manual build uses the first Lua it finds: LuaJIT, then 5.5, 5.4, 5.3, 5.2 and 5.1. To choose one, name it on the first build, for example `make LUA_PKG=lua5.4`. An existing `build/` directory keeps its Lua; delete it to change.

Then follow [Launch](first-launch.md).

### LGI {#lgi-troubleshooting}

LGI provides Cairo, Pango and GLib bindings. It must match the Lua interpreter used by the build. LuaJIT is the default and uses Lua 5.1 modules. On Arch, this requires `lua51-lgi`. Debian/Ubuntu and Fedora package it as `lua-lgi`.

If startup reports `module 'lgi' not found`, check the interpreter and module paths before installing another Lua version. `somewm -L /path/to/modules` adds a search directory for modules installed elsewhere.

### NixOS

From the source checkout:

```bash
nix build .
./result/bin/somewm
```

`nix-build` also works if your nixpkgs channel provides a compatible `wlroots_0_20`.

The package installs the default configuration and Lua libraries, and wraps the binary with its Lua and typelib paths.

## NixOS Details {#nixos-details}

<span id="gi_typelib_path-and-third-party-libraries" />
<span id="extra-lua-modules" />

GTK3 typelibs are included by default. To add GI libraries or Lua modules, save this as `with-libraries.nix` in the checkout and run `nix-build with-libraries.nix`:

```nix
{ pkgs ? import <nixpkgs> {} }:
(import ./default.nix { inherit pkgs; }).override {
  extraGIPackages = [ pkgs.networkmanager ];
  extraLuaPackages = ps: [ ps.luafilesystem ];
}
```

## Uninstallation

From the checkout used to install:

```bash
sudo make uninstall
make clean
```
