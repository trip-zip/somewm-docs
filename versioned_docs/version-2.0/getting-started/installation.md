---
sidebar_position: 1
title: Installation
description: Build and install SomeWM on your system
---

# Installation

:::tip Want to try first?
You can run a sandboxed nested SomeWM inside your current Wayland or X11 session without logging out. Install the binary, then follow the [Try SomeWM Without Logging Out](../tutorials/try-somewm-without-installing.md) tutorial. Your daily-driver desktop is untouched.
:::

## Dependencies

:::note wlroots
SomeWM builds against wlroots 0.20, or 0.19 if your system is too old for 0.20. If wlroots is not installed, Meson fetches the matching version as a subproject during the build.

wlroots 0.20 needs wayland-server 1.24.0, libdrm 2.4.129, xkbcommon 1.8.0, wayland-protocols 1.47 and pixman 0.46.0. Debian 13 and Ubuntu 24.04 ship older versions, so they get 0.19. An already-installed wlroots 0.20 is used regardless. Force a version with `-Dwlroots_version=0.19` or `-Dwlroots_version=0.20`.

The 0.19 path exists for these older distributions and will be dropped once they ship wlroots 0.20 or the dependency versions it needs.
:::

### Arch Linux

#### From the AUR (recommended)

```bash
yay -S somewm-git
# or with paru:
paru -S somewm-git
```

This installs somewm and all dependencies. After installation, skip directly to [Launch](/docs/getting-started/first-launch).

#### Manual Build

If you prefer to build from source:

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

# Optional: XWayland support
sudo pacman -S xorg-xwayland libxcb
```

### Debian/Ubuntu

If your release does not package wlroots 0.19 or 0.20, Meson builds wlroots from source. That needs wlroots' own build dependencies as well as SomeWM's.

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

### NixOS

A `default.nix` is provided for building on NixOS:

```bash
nix-build
./result/bin/somewm
```

The included derivation sets up LGI and `GI_TYPELIB_PATH` automatically. For custom configurations or third-party Lua libraries, see the [NixOS section](#nixos-details) below.

## Build and Install

```bash
git clone https://github.com/trip-zip/somewm
cd somewm
make
sudo make install
```

The build will verify that LGI is correctly installed for your Lua version. If the check fails, you'll see instructions for which package to install.

## LGI Troubleshooting

SomeWM requires LGI (Lua GObject Introspection bindings) for widget rendering. **The LGI package must match your Lua version.**

| Lua Version | Arch Linux | Debian/Ubuntu | Fedora |
|-------------|------------|---------------|--------|
| LuaJIT (default) | `lua51-lgi` | `lua-lgi` | `lua-lgi` |
| Lua 5.4 | `lua-lgi` | `lua-lgi` | `lua-lgi` |

If you have the wrong package, you'll see:
```
module 'lgi' not found
```

For custom LGI locations, use the `-L` (or `--search`) flag:
```bash
somewm -L /usr/lib/lua/5.1
```

## NixOS Details {#nixos-details}

### GI_TYPELIB_PATH and Third-Party Libraries

On NixOS, GObject Introspection typelibs are isolated in `/nix/store` rather than system paths. The `default.nix` sets up `GI_TYPELIB_PATH` with common typelibs (pango, gdk-pixbuf, glib, gtk3).

**If you use third-party Lua libraries** (like [bling](https://github.com/BlingCorp/bling)), they may require additional typelibs. For example, bling's `app_launcher` widget requires GTK3 for icon theme lookups.

To add additional typelibs when packaging SomeWM, extend the wrapper:

```nix
postFixup = ''
  wrapProgram $out/bin/somewm \
    --prefix GI_TYPELIB_PATH : "${pkgs.gtk3}/lib/girepository-1.0" \
    --prefix GI_TYPELIB_PATH : "${pkgs.networkmanager}/lib/girepository-1.0" \
    # Add more as needed for your Lua libraries
'';
```

### Extra Lua Modules

To add additional Lua modules (like `luafilesystem`):

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
# Remove installed files
sudo make uninstall

# Remove build directory
make clean
```

## Next Steps

Once installed, proceed to [Launch](/docs/getting-started/first-launch) to run SomeWM for the first time.
