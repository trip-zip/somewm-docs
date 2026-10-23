---
sidebar_position: 1
title: Installation
description: Build and install SomeWM on your system
---

# Installation

Build the `release/1.4` branch for SomeWM 1.4. After installing, you can [try it in a window](../tutorials/try-somewm-without-installing.md) before logging into it.

## Dependencies

You need Git, a C compiler, Make, Meson, Ninja and pkg-config, plus the libraries below.

SomeWM 1.4 supports wlroots 0.19 and 0.20. Meson uses an installed wlroots or builds it as a subproject. It selects 0.19 when the system dependencies are too old for 0.20.

wlroots 0.20 requires wayland-server 1.24.0, libdrm 2.4.129, xkbcommon 1.8.0, wayland-protocols 1.47 and pixman 0.46.0. An installed wlroots 0.20 takes priority over this dependency check. To choose explicitly, pass `MESON_OPTS=-Dwlroots_version=0.19` or `MESON_OPTS=-Dwlroots_version=0.20` to the first `make` invocation.

### Arch Linux

#### AUR packages {#from-the-aur-recommended}

`somewm-git` builds the current development branch. To install 1.4, use the source build below.

#### Manual Build

```bash
sudo pacman -S --needed \
    base-devel git meson ninja pkgconf \
    luajit lua51-lgi cairo pango gdk-pixbuf2 \
    wayland wayland-protocols libdrm dbus glib2 \
    libinput libxkbcommon

# Optional: XWayland support
sudo pacman -S xorg-xwayland libxcb xcb-util-wm
```

`lua51-lgi` matches LuaJIT, the default Lua runtime.

### Debian/Ubuntu

If your release does not package wlroots 0.19 or 0.20, Meson builds wlroots from source. That needs wlroots' own build dependencies as well as SomeWM's.

```bash
# Required dependencies
sudo apt install \
    build-essential \
    git \
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

# wlroots build dependencies
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

# Optional: XWayland support
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
    gcc make git ninja-build pkgconf-pkg-config \
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

# Optional: XWayland support
sudo dnf install \
    xorg-x11-server-Xwayland \
    xorg-x11-server-Xwayland-devel \
    libxcb-devel \
    xcb-util-wm-devel \
    xcb-util-renderutil-devel
```

### Gentoo

The [SomeWM overlay](https://github.com/shuber2/somewm-gentoo-overlay) provides a `1.4.9999` ebuild that tracks `release/1.4`. As root:

```bash
eselect repository add somewm git https://github.com/shuber2/somewm-gentoo-overlay.git
emaint sync -r somewm

mkdir -p /etc/portage/package.accept_keywords
echo '=gui-wm/somewm-1.4.9999 **' >> /etc/portage/package.accept_keywords/somewm
emerge -av '=gui-wm/somewm-1.4.9999'
```

After installation, continue to [Launch](first-launch.md).

### NixOS

From a checkout of `release/1.4`, build and run:

```bash
nix-build
./result/bin/somewm
```

The derivation wraps SomeWM with LGI and its typelib paths. See [NixOS Details](#nixos-details) to add libraries. NixOS users can skip the Make commands below.

## Build and Install

```bash
git clone --branch release/1.4 https://github.com/trip-zip/somewm
cd somewm
make
sudo make install
```

The build checks that LGI matches the selected Lua version and reports missing packages. The default install prefix is `/usr/local`.

## LGI Troubleshooting

SomeWM requires LGI (Lua GObject Introspection bindings) for widget rendering. **The LGI package must match your Lua version.**

| Lua Version | Arch Linux | Debian/Ubuntu | Fedora |
|-------------|------------|---------------|--------|
| LuaJIT (default) | `lua51-lgi` | `lua-lgi` | `lua-lgi` |
| Lua 5.4 | `lua-lgi` | `lua-lgi` | `lua-lgi` |

A missing or mismatched LGI package can produce:

```text
module 'lgi' not found
```

For custom LGI locations, use the `-L` (or `--search`) flag:

```bash
somewm -L /usr/lib/lua/5.1
```

## NixOS Details {#nixos-details}

<span id="gi_typelib_path-and-third-party-libraries" />
<span id="extra-lua-modules" />

`package.nix` includes GTK3 typelibs by default. To add typelibs or Lua modules, save this as `custom.nix` beside `package.nix`:

```nix
{ pkgs ? import <nixpkgs> {} }:
(pkgs.callPackage ./package.nix {}).override {
  extraGIPackages = [ pkgs.networkmanager ];
  extraLuaPackages = ps: [ ps.luafilesystem ];
}
```

Run `nix-build custom.nix`. The wrapper adds the typelibs to `GI_TYPELIB_PATH` and the Lua modules to the Lua search paths.

## Uninstallation

```bash
# Remove installed files
sudo make uninstall

# Remove build directory
make clean
```

## Next Steps

Continue to [Launch](first-launch.md).
