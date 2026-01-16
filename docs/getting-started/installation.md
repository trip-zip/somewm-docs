---
sidebar_position: 1
title: Installation
description: Build and install SomeWM on your system
---

# Installation

## Dependencies

:::note wlroots
SomeWM is tightly coupled to wlroots 0.19. Meson fetches it automatically as a subproject during the build.
:::

### Arch Linux

#### From the AUR (recommended)

```bash
yay -S somewm-git
# or with paru:
paru -S somewm-git
```

This installs somewm and all dependencies. After installation, skip directly to [Launch](/getting-started/first-launch).

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

### Debian/Ubuntu (25.04+ or unstable)

```bash
# Required dependencies
sudo apt install \
    luajit \
    lua-lgi \
    libcairo2-dev \
    libpango1.0-dev \
    libgdk-pixbuf-2.0-dev \
    wayland-protocols \
    libinput-dev \
    libxkbcommon-dev

# Optional: XWayland support
sudo apt install xwayland libxcb1-dev libxcb-icccm4-dev
```

### Fedora

```bash
# Required dependencies
sudo dnf install \
    luajit \
    lua-lgi \
    cairo-devel \
    pango-devel \
    gdk-pixbuf2-devel \
    wayland-protocols-devel \
    libinput-devel \
    libxkbcommon-devel

# Optional: XWayland support
sudo dnf install xorg-x11-server-Xwayland libxcb-devel xcb-util-wm-devel
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

Once installed, proceed to [Launch](/getting-started/first-launch) to run SomeWM for the first time.
