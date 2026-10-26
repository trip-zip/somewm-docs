---
sidebar_position: 1
title: Installation
description: Build and install SomeWM on your system
---

# Installation

Install dependencies for your distribution, then build the pinned 2.1.0 release below. You can also [try SomeWM in a nested session](../tutorials/try-somewm-without-installing.md) without installing it system-wide.

## Dependencies

SomeWM downloads and builds wlroots 0.20.2. It does not use an installed wlroots package. The first build needs network access.

The build uses system Wayland 1.24.0, libdrm 2.4.129, xkbcommon 1.8.0, pixman 0.46.0 and wayland-protocols 1.47 or newer. Older dependencies are downloaded at pinned versions and built alongside wlroots. Ubuntu 24.04 also needs the libdisplay-info fallback.

XWayland support is always built in. Install its build dependencies and the Xwayland binary to run X11 applications.

### Arch Linux

<span id="from-the-aur-recommended" />

#### From the AUR

```bash
yay -S somewm-git
```

`paru -S somewm-git` is an alternative. This package follows development, not the pinned 2.1.0 release. For that release, use the manual build below.

The package builds against LuaJIT. To build against another Lua, install its LGI package and set `SOMEWM_LUA`:

```bash
sudo pacman -S lua54-lgi
SOMEWM_LUA=5.4 yay -S somewm-git
```

`SOMEWM_LUA` accepts `luajit`, `5.1`, `5.3`, `5.4` and `5.5`. yay still installs LuaJIT, because the AUR lists the default dependencies. Add `--rebuild` if yay already built this version with a different Lua.

#### Manual Build

```bash
sudo pacman -S base-devel git meson ninja pkgconf luajit lua51-lgi \
    cairo pango gdk-pixbuf2 librsvg glib2 dbus wayland wayland-protocols \
    libinput libxkbcommon pixman libdrm seatd libdisplay-info libliftoff \
    hwdata mesa libglvnd lcms2 xorg-xwayland libxcb xcb-util \
    xcb-util-wm xcb-util-renderutil xcb-util-errors
```

### Debian/Ubuntu

```bash
sudo apt install build-essential git meson ninja-build pkg-config \
    luajit libluajit-5.1-dev lua-lgi libcairo2-dev libpango1.0-dev \
    libgdk-pixbuf-2.0-dev librsvg2-dev libglib2.0-dev libdbus-1-dev \
    libwayland-dev libwayland-bin wayland-protocols libdrm-dev \
    libinput-dev libxkbcommon-dev libgbm-dev libegl-dev libgles-dev \
    libpixman-1-dev libudev-dev libseat-dev libdisplay-info-dev \
    libliftoff-dev liblcms2-dev hwdata libffi-dev libexpat1-dev \
    xwayland libxcb1-dev libxcb-util-dev libxcb-icccm4-dev \
    libxcb-composite0-dev libxcb-ewmh-dev libxcb-res0-dev \
    libxcb-render0-dev libxcb-render-util0-dev libxcb-errors-dev \
    libxcb-xfixes0-dev libxcb-xinput-dev libxcb-dri3-dev \
    libxcb-present-dev libxcb-shm0-dev
```

Optional packages:

- `libpam0g-dev` for built-in lockscreen authentication
- `systemd-dev` for systemd session integration

### Fedora

```bash
sudo dnf install gcc make git meson ninja-build pkgconf-pkg-config \
    luajit luajit-devel lua-lgi cairo-devel pango-devel gdk-pixbuf2-devel \
    librsvg2-devel glib2-devel dbus-devel wayland-devel wayland-protocols-devel \
    libdrm-devel libinput-devel libxkbcommon-devel mesa-libgbm-devel \
    libglvnd-egl-devel libglvnd-gles-devel pixman-devel systemd-devel \
    libseat-devel libdisplay-info-devel libliftoff-devel lcms2-devel hwdata \
    xorg-x11-server-Xwayland xorg-x11-server-Xwayland-devel \
    libxcb-devel xcb-util-devel xcb-util-wm-devel \
    xcb-util-renderutil-devel xcb-util-errors-devel
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
git clone --branch v2.1.0 https://github.com/trip-zip/somewm
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

In the `v2.1.0` checkout, apply the Nix build fixes before building:

```bash
git cherry-pick --no-commit 35e21e4410b09cc9115766cc07a62bce7c19cc91
nix-build
./result/bin/somewm
```

These fixes address duplicate Meson flags, build-machine dependency lookup and a compiler warning treated as an error. The package installs the default configuration and Lua libraries, and wraps the binary with its Lua and typelib paths.

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
