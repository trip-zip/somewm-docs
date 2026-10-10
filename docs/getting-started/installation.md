---
sidebar_position: 1
title: Installation
description: Build and install SomeWM on your system
---

# Installation

:::tip
SomeWM runs nested in a window on your current session, so you can try it without logging out: [Try SomeWM without installing](../tutorials/try-somewm-without-installing.md).
:::

## Dependencies

:::note wlroots
The build downloads wlroots 0.20.2 and builds it into SomeWM, so no wlroots package is needed and an installed one is not used. wlroots needs wayland 1.24.0, libdrm 2.4.129, xkbcommon 1.8.0, pixman 0.46.0 and wayland-protocols 1.47 or newer. If your system has those, nothing else is built. Each one that is older is downloaded at a fixed version and built alongside wlroots; Debian 13 builds all five this way, Ubuntu 24.04 builds those five and libdisplay-info. The first build needs network access for the downloads.

XWayland support is always built in, so xcb, xcb-icccm and Xwayland are required to build, and X11 applications need the Xwayland binary at runtime.
:::

### Arch Linux

#### From the AUR (recommended)

```bash
yay -S somewm-git
# or with paru:
paru -S somewm-git
```

Then go to [Launch](/docs/getting-started/first-launch).

#### Manual Build

```bash
# Required dependencies
# Note: lua51-lgi is required for LuaJIT (the default Lua for SomeWM)
sudo pacman -S \
    luajit \
    lua51-lgi \
    cairo \
    pango \
    gdk-pixbuf2 \
    wayland-protocols \
    libinput \
    libxkbcommon

# XWayland, required
sudo pacman -S xorg-xwayland libxcb xcb-util-wm
```

The wlroots build inside SomeWM needs wlroots' own build dependencies too: the packages Arch's `wlroots0.20` depends on, among them `pixman`, `libdrm`, `seatd`, `libdisplay-info`, `libliftoff`, `hwdata` and `mesa`.

### Debian/Ubuntu

The build always builds wlroots from source, and on Debian 13 and Ubuntu 24.04 also wayland, libdrm, xkbcommon, pixman and wayland-protocols at the versions wlroots needs. That needs wlroots' own build dependencies as well as SomeWM's.

```bash
# Required dependencies
sudo apt install \
    build-essential \
    meson \
    ninja-build \
    pkg-config \
    luajit \
    libluajit-5.1-dev \
    lua-lgi \
    libcairo2-dev \
    libpango1.0-dev \
    libgdk-pixbuf-2.0-dev \
    libglib2.0-dev \
    libwayland-dev \
    libwayland-bin \
    wayland-protocols \
    libdrm-dev \
    libdbus-1-dev \
    libinput-dev \
    libxkbcommon-dev \
    libxcb-util-dev

# wlroots build dependencies, required
sudo apt install \
    libgbm-dev \
    libegl-dev \
    libgles-dev \
    libvulkan-dev \
    libpixman-1-dev \
    libudev-dev \
    libseat-dev \
    libdisplay-info-dev \
    libliftoff-dev \
    hwdata

# XWayland, required
sudo apt install \
    xwayland \
    libxcb1-dev \
    libxcb-icccm4-dev \
    libxcb-composite0-dev \
    libxcb-ewmh-dev \
    libxcb-res0-dev \
    libxcb-render0-dev \
    libxcb-render-util0-dev \
    libxcb-errors-dev \
    libxcb-xfixes0-dev \
    libxcb-xinput-dev

# Optional: lock screen authentication
sudo apt install libpam0g-dev

# Optional: systemd session integration (somewm-session, login manager entry)
sudo apt install systemd-dev

# Optional: SVG icon rendering
sudo apt install gir1.2-rsvg-2.0
```

### Fedora

```bash
# Required dependencies
sudo dnf install \
    meson \
    luajit \
    luajit-devel \
    lua-lgi \
    cairo-devel \
    pango-devel \
    gdk-pixbuf2-devel \
    wayland-devel \
    wayland-protocols-devel \
    libdrm-devel \
    dbus-devel \
    glib2-devel \
    libinput-devel \
    libxkbcommon-devel

# XWayland, required
sudo dnf install \
    xorg-x11-server-Xwayland \
    xorg-x11-server-Xwayland-devel \
    libxcb-devel \
    xcb-util-wm-devel \
    xcb-util-renderutil-devel
```

### Gentoo

:::note
SomeWM is not currently part of the official Gentoo Portage tree or the [GURU](https://wiki.gentoo.org/wiki/Project:GURU) project overlay. Use the third-party overlay below instead.
:::

SomeWM is packaged in the [somewm-gentoo-overlay](https://github.com/shuber2/somewm-gentoo-overlay):

```bash
eselect repository add somewm git https://github.com/shuber2/somewm-gentoo-overlay.git
emaint sync -r somewm

echo 'gui-wm/somewm ~amd64' >> /etc/portage/package.accept_keywords/somewm
emerge -av gui-wm/somewm
```

A `9999` ebuild tracks `main` and `1.4.9999` tracks `release/1.4`. Then go to [Launch](/docs/getting-started/first-launch).

### NixOS

A `default.nix` is provided for building on NixOS:

```bash
nix-build
./result/bin/somewm
```

The derivation sets up LGI and `GI_TYPELIB_PATH`; third-party Lua libraries may need more, see [NixOS details](#nixos-details).

## Build and Install

```bash
git clone https://github.com/trip-zip/somewm
cd somewm
make
sudo make install
```

The build checks that LGI, the Lua GObject Introspection bindings the libraries use for cairo, Pango and GLib, is installed for your Lua version, and names the package to install if not. The package must match the Lua version:

| Lua Version | Arch Linux | Debian/Ubuntu | Fedora |
|-------------|------------|---------------|--------|
| LuaJIT (default) | `lua51-lgi` | `lua-lgi` | `lua-lgi` |
| Lua 5.4 | `lua-lgi` | `lua-lgi` | `lua-lgi` |

The wrong package fails with `module 'lgi' not found`. For an LGI installed elsewhere:
```bash
somewm -L /usr/lib/lua/5.1
```

## NixOS Details {#nixos-details}

### GI_TYPELIB_PATH and Third-Party Libraries

Typelibs live in `/nix/store`, and `default.nix` puts pango, gdk-pixbuf, glib and gtk3 on `GI_TYPELIB_PATH`. A third-party library such as [bling](https://github.com/BlingCorp/bling) may need more (its `app_launcher` needs GTK3 for icon lookups). Extend the wrapper:

```nix
postFixup = ''
  wrapProgram $out/bin/somewm \
    --prefix GI_TYPELIB_PATH : "${pkgs.gtk3}/lib/girepository-1.0" \
    --prefix GI_TYPELIB_PATH : "${pkgs.networkmanager}/lib/girepository-1.0" \
    # Add more as needed for your Lua libraries
'';
```

### Extra Lua Modules

For extra Lua modules such as `luafilesystem`:

```nix
let
  luaEnv = pkgs.luajit.withPackages (ps: with ps; [
    lgi
    luafilesystem  # Add extra modules here
  ]);
in
# ... use luaEnv in buildInputs and wrapper
```

## Uninstallation

```bash
sudo make uninstall
make clean
```
