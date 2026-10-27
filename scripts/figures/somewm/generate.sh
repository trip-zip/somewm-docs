#!/bin/sh
# Render the widget reference figures on a live SomeWM session.
#
#   scripts/figures/somewm/generate.sh                 # every scene
#   scripts/figures/somewm/generate.sh widget-textbox  # one scene
#   scripts/figures/somewm/generate.sh --check [name]  # headless dry run
#
# Each <name>.lua under this directory is one figure. The script concatenates
# lib.lua ahead of it, loads it on the compositor with somewm-client eval,
# reads the popup's geometry, captures it with grim, and closes it. Output goes
# to static/img/reference/wibox/<name>.png at the output's scale, with the
# concatenated Lua beside it as <name>.lua, and the same code as an MDX partial
# under docs/reference/wibox/_lua/ that the page includes in its Show Lua block.
#
# --check boots a headless test instance from the SomeWM checkout (SOMEWM_REPO,
# default ~/tools/some, needs build-test/) and loads every scene there instead.
# It catches Lua errors and a scene that does not render before anything is
# shown on the live session. Captures from the check are written next to the
# real ones with a -check suffix and are not used by the site.
set -eu

repo="$(cd "$(dirname "$0")/../../.." && pwd)"
here="$repo/scripts/figures/somewm"
out="$repo/static/img/reference/wibox"
somewm_repo="${SOMEWM_REPO:-$HOME/tools/some}"

check=0
if [ "${1:-}" = "--check" ]; then check=1; shift; fi

names="$*"
if [ -z "$names" ]; then
    names=$(cd "$here" && ls *.lua | grep -v '^lib\.lua$' | sed 's/\.lua$//')
fi

# The figure's box, inset one logical pixel so a fractional scale cannot let
# the edge of what is under it into the capture, and cut to the screen: the
# headless check screen is shorter than some figures.
geo_lua='local f = _G.somewm_reference_figure; if not f then return "none" end; local p = f.popup; if p.height < 40 then return "pending" end; local g = f.screen.geometry; local x, y = math.max(p.x + 1, g.x), math.max(p.y + 1, g.y); local w, h = math.min(p.x + p.width - 1, g.x + g.width) - x, math.min(p.y + p.height - 1, g.y + g.height) - y; return string.format("%d,%d %dx%d", x, y, w, h)'

# The popup takes a frame or two to get its size. Poll until it has one.
geometry() {
    i=0
    while [ $i -lt 20 ]; do
        geo=$("$@" "$geo_lua" | grep -E '^[0-9]+,[0-9]+ [0-9]+x[0-9]+$' | tail -1 || true)
        [ -n "$geo" ] && { echo "$geo"; return 0; }
        sleep 0.25; i=$((i + 1))
    done
    return 1
}
stop_lua='if _G.somewm_reference_figure then _G.somewm_reference_figure.stop() end'
# Park the pointer in the corner of the figure's screen so it is not in the
# capture, and put it back afterwards.
park_lua='local f = _G.somewm_reference_figure; if not f then return end; local g = f.screen.geometry; f.pointer = mouse.coords(); mouse.coords { x = g.x + g.width - 1, y = g.y + g.height - 1 }'
unpark_lua='local f = _G.somewm_reference_figure; if f and f.pointer then mouse.coords { x = f.pointer.x, y = f.pointer.y } end'

mkdir -p "$out"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

if [ "$check" = 1 ]; then
    bin="$somewm_repo/build-test/somewm"
    client="$somewm_repo/build-test/somewm-client"
    [ -x "$bin" ] || { echo "no test build at $bin; run make build-test" >&2; exit 1; }
    SOMEWM_BINARY="$bin" "$client" test start --host headless --name docs-figures --force >/dev/null
    trap '"$client" test stop --name docs-figures >/dev/null 2>&1; rm -rf "$tmp"' EXIT
    sleep 1
    rt="$XDG_RUNTIME_DIR/somewm-test/docs-figures/runtime"
fi

for name in $names; do
    scene="$tmp/$name.lua"
    cat "$here/lib.lua" "$here/$name.lua" > "$scene"
    if [ "$check" = 1 ]; then
        "$client" test eval --name docs-figures "return dofile('$scene')" >/dev/null
        geo=$(geometry "$client" test eval --name docs-figures || true)
        case "$geo" in
            *,*\ *x*) ;;
            *) echo "$name: no figure geometry: $geo" >&2; exit 1 ;;
        esac
        XDG_RUNTIME_DIR="$rt" WAYLAND_DISPLAY=wayland-0 grim -l 9 -g "$geo" "$out/$name-check.png"
        "$client" test eval --name docs-figures "$stop_lua" >/dev/null
        echo "$name: ok ($geo) -> $out/$name-check.png"
    else
        somewm-client eval "return dofile('$scene')" >/dev/null
        geo=$(geometry somewm-client eval || true)
        case "$geo" in
            *,*\ *x*) ;;
            *) echo "$name: no figure geometry: $geo" >&2; exit 1 ;;
        esac
        somewm-client eval "$park_lua" >/dev/null
        sleep 0.2
        grim -l 9 -g "$geo" "$out/$name.png"
        somewm-client eval "$unpark_lua" >/dev/null
        somewm-client eval "$stop_lua" >/dev/null
        cp "$scene" "$out/$name.lua"
        # The page includes the same code inline under "Show Lua".
        { printf '```lua\n'; cat "$scene"; printf '```\n'; } > "$repo/docs/reference/wibox/_lua/$name.mdx"
        echo "$name: $geo -> $out/$name.png"
    fi
done
