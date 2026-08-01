#!/bin/sh
# Render the Clay Bet figures by booting a real headless kiln, declaring the
# figure, and screenshotting what Clay solved.
#
#   scripts/figures/generate.sh          # all figures
#   scripts/figures/generate.sh 01 04    # only these
#
# Every image under static/img/kiln/clay/ and static/img/kiln/rc/ comes from
# here. Nothing is drawn by hand, so when kiln's API moves the figures are one
# command from current.
#
# Requires: a built kiln (KILN_REPO, default ~/tools/kiln), ImageMagick, nc,
# and foot for the figures that need real client windows.
set -eu

repo="$(cd "$(dirname "$0")/../.." && pwd)"
here="$repo/scripts/figures"
out="$repo/static/img/kiln/clay"

. "$repo/scripts/lib/kiln-headless.sh"

command -v magick >/dev/null || { echo "ImageMagick 'magick' not found" >&2; exit 1; }

only="$*"
kh_init
trap kh_cleanup EXIT
mkdir -p "$out"

# Run this figure? No arguments means all of them.
run() {
	[ -z "$only" ] && return 0
	for a in $only; do [ "$a" = "$1" ] && return 0; done
	return 1
}

# Concatenate the shared lib ahead of a figure config; lib.lua explains why the
# figures share state through a global instead of require().
rc_for() {
	cat "$here/lib.lua" "$here/$1" > "$KH_WORK/rc.lua"
	echo "$KH_WORK/rc.lua"
}

# Crop a capture to one element's solved box, grown by a margin. The geometry
# comes from Clay by way of core.box, so a figure that reflows still crops to
# its own edges instead of to coordinates someone measured once by hand.
crop_el() { # src id margin dest
	geom="$(kh_box "'$2'")"
	[ -n "$geom" ] || { echo "no solved box for element '$2'" >&2; exit 1; }
	x=$(echo "$geom" | cut -d' ' -f1)
	y=$(echo "$geom" | cut -d' ' -f2)
	w=$(echo "$geom" | cut -d' ' -f3)
	h=$(echo "$geom" | cut -d' ' -f4)
	m="$3"
	magick "$1" -crop "$((w + m + m))x$((h + m + m))+$((x - m))+$((y - m))" +repage "$4"
	echo "  ${4##*/}  $((w + m + m))x$((h + m + m))"
}

# Terminal content for the leaf figure: the surface has to visibly hold pixels
# kiln did not draw, which an empty black rectangle does not demonstrate.
client_content='clear; printf "\$ kiln-eval '"'"'return #client.all()'"'"'\n2\n\n\$ kiln-eval '"'"'return screen.focused.name'"'"'\nHEADLESS-1\n\n\$ "'

# --- primer figures: Clay's own palette, no window manager in sight ----------
#
# Discovered by glob, not listed: dropping NN-name.lua in this directory is the
# whole of adding a figure. Each one declares an element with id "figure" (see
# F.canvas in lib.lua) and the capture is cropped to that element's solved box.

for path in "$here"/[0-9][0-9]-*.lua; do
	[ -e "$path" ] || continue
	fig="${path##*/}"
	fig="${fig%.lua}"
	run "${fig%%-*}" || continue
	echo "$fig"
	kh_boot "$(rc_for "$fig.lua")"
	kh_shoot "$KH_WORK/$fig.png"
	crop_el "$KH_WORK/$fig.png" figure 0 "$out/$fig.png"
	kh_halt
done

# --- desktop figures: the stock config, real clients, kiln's own theme -------

# Read one element's solved box as "x y w h".
box_of() { kh_box "$1"; }
f1() { echo "$1" | cut -d' ' -f1; }
f2() { echo "$1" | cut -d' ' -f2; }
f3() { echo "$1" | cut -d' ' -f3; }
f4() { echo "$1" | cut -d' ' -f4; }

if run 03; then
	echo "03-bar"
	kh_boot "$KILN_REPO/kilnrc.lua"
	kh_spawn_client
	kh_spawn_client
	kh_shoot "$KH_WORK/03.png"

	launcher="$(box_of "'launcher'")"
	taglist="$(box_of "'taglist:HEADLESS-1'")"
	tasklist="$(box_of "'tasklist:HEADLESS-1'")"
	clock="$(box_of "'clock'")"
	layoutbox="$(box_of "'layoutbox:HEADLESS-1'")"

	# The bar plus a band underneath for the callout chips. The launcher chip
	# draws last: the widgets.taglist chip reaches into the left corner where
	# the launcher chip clamps, and the shorter label is the one that must
	# stay fully readable.
	magick "$KH_WORK/03.png" -crop 1280x104+0+0 +repage "$KH_WORK/03-c.png"
	"$here/annotate.sh" "$KH_WORK/03-c.png" "$out/03-bar.png" \
		"$(f1 "$taglist"),$(f2 "$taglist"),$(f3 "$taglist"),$(f4 "$taglist"),below,widgets.taglist" \
		"$(f1 "$tasklist"),$(f2 "$tasklist"),$(f3 "$tasklist"),$(f4 "$tasklist"),below,widgets.tasklist" \
		"$(f1 "$clock"),$(f2 "$clock"),$(f3 "$clock"),$(f4 "$clock"),below,widgets.clock" \
		"$(f1 "$layoutbox"),$(f2 "$layoutbox"),$(f3 "$layoutbox"),$(f4 "$layoutbox"),below,widgets.layoutbox" \
		"$(f1 "$launcher"),$(f2 "$launcher"),$(f3 "$launcher"),$(f4 "$launcher"),below,ui.box"
	echo "  03-bar.png"
	kh_halt
fi

if run 04; then
	echo "04-leaf"
	kh_boot "$KILN_REPO/kilnrc.lua"
	kh_spawn_client "$client_content"
	kh_spawn_client
	# Float the subject at a size that makes a compact figure. Tiled to a whole
	# headless output it is mostly empty terminal, which illustrates nothing.
	kh_ev 'local c = client.all()[1]
		c.floating = true
		c.float = { x = 60, y = 90, width = 620, height = 300 }
		core.dirty()' >/dev/null
	sleep 1
	kh_shoot "$KH_WORK/04.png"

	cl="$(kh_ev "local c = client.all()[1]; local b = core.box({'client', c.handle}); return b and (b.x..' '..b.y..' '..b.width..' '..b.height) or ''")"
	tb="$(kh_ev "local c = client.all()[1]; local b = core.box({'titlebar', c.handle}); return b and (b.x..' '..b.y..' '..b.width..' '..b.height) or ''")"
	[ -n "$cl" ] && [ -n "$tb" ] || { echo "no client/titlebar box" >&2; exit 1; }

	cx=$(f1 "$cl"); cy=$(f2 "$cl"); cw=$(f3 "$cl"); chh=$(f4 "$cl")
	tx=$(f1 "$tb"); ty=$(f2 "$tb"); tw=$(f3 "$tb"); th=$(f4 "$tb")

	# The surface is what is left of the client once the titlebar is taken off
	# the top: kiln has no id for it, but the fork this figure is about is
	# exactly this split, and both halves come from Clay's solved boxes.
	sx=$tx
	sy=$((ty + th))
	sw=$tw
	sh=$((cy + chh - sy - 2))

	m=10
	ox=$((cx - m)); oy=$((cy - m))
	magick "$KH_WORK/04.png" -crop "$((cw + m + m))x$((chh + m + m))+$ox+$oy" +repage "$KH_WORK/04-c.png"
	"$here/annotate.sh" "$KH_WORK/04-c.png" "$out/04-leaf.png" \
		"$((tx - ox)),$((ty - oy)),$tw,$th,below,widgets.titlebar - Clay draws this" \
		"$((sx - ox)),$((sy - oy)),$sw,$sh,center,ui.surface - the client's own pixels"
	echo "  04-leaf.png"
	kh_halt
fi

if run 05; then
	echo "05-mwfact"
	kh_boot "$KILN_REPO/kilnrc.lua"
	kh_spawn_client 'clear; printf "master\n\n\$ "'
	kh_spawn_client 'clear; printf "stack 1\n\n\$ "'
	kh_spawn_client 'clear; printf "stack 2\n\n\$ "'
	# 0.4 and 0.75 rather than a timid 0.5/0.7: the figure has to read at page
	# width, where a fifteen percent difference in column width does not.
	for f in 40 75; do
		kh_ev "screen.focused.tags[1].master_width_factor = 0.$f; core.dirty()" >/dev/null
		sleep 1
		kh_shoot "$KH_WORK/05-$f.png"
		magick "$KH_WORK/05-$f.png" -crop 1280x688+0+32 +repage "$KH_WORK/05-$f-c.png"
		"$here/annotate.sh" "$KH_WORK/05-$f-c.png" "$KH_WORK/05-$f-a.png" \
			"640,600,0,0,center,master_width_factor = 0.${f%0}"
	done
	magick "$KH_WORK/05-40-a.png" "$KH_WORK/05-75-a.png" \
		-background "#a8421c" -splice 6x0+0+0 +append -chop 6x0 \
		"$out/05-mwfact.png"
	echo "  05-mwfact.png"
	kh_halt
fi

# --- anatomy figures: the shipped rc, photographed piece by piece ------------
#
# These land in static/img/kiln/rc/ and illustrate Anatomy of rc.lua. Headless
# has no pointer, so presses and hovers are dispatched the way kiln's own test
# battery dispatches them: walk core.hits at the element's center and fire the
# first handler in the same table a real click or motion event lands in.

out_rc="$repo/static/img/kiln/rc"
mkdir -p "$out_rc"

# Fire the innermost press handler under an element's center. Returns the id
# whose handler ran.
press_el() { # id
	kh_ev "
local st = require('kiln.state')
local s = screen.all()[1]
local b = core.box(\"$1\")
if b == nil then return 'no-box' end
local presses = st.screen_presses[s.name] or {}
for _, h in ipairs(core.hits(s.name, b.x + b.width / 2, b.y + b.height / 2)) do
  local fn = presses['on_press:' .. h.name .. '#' .. h.index]
  if fn ~= nil then
    fn()
    core.dirty()
    return h.name
  end
end
return 'no-handler'"
	sleep 0.6
}

# The hover transition, restated like the tooltip battery: the handler takes
# (entered, hit) and reads the screen name off the hit. $2 is true to enter,
# false to leave, so a figure can clear its own tooltip.
hover_el() { # id entered
	kh_ev "
local st = require('kiln.state')
local s = screen.all()[1]
local b = core.box(\"$1\")
if b == nil then return 'no-box' end
local presses = st.screen_presses[s.name] or {}
for _, h in ipairs(core.hits(s.name, b.x + b.width / 2, b.y + b.height / 2)) do
  local fn = presses['on_hover:' .. h.name .. '#' .. h.index]
  if fn ~= nil then
    h.screen = s.name
    fn($2, h)
    core.dirty()
    return h.name
  end
end
return 'no-handler'"
	sleep 0.6
}

# The union of several solved boxes as "x y w h", for crops that must hold a
# chain of elements (a menu and its open submenus).
union_of() { # comma-separated quoted lua ids
	kh_ev "
local x1, y1, x2, y2
for _, id in ipairs({$1}) do
  local b = core.box(id)
  if b ~= nil then
    if x1 == nil or b.x < x1 then x1 = b.x end
    if y1 == nil or b.y < y1 then y1 = b.y end
    if x2 == nil or b.x + b.width > x2 then x2 = b.x + b.width end
    if y2 == nil or b.y + b.height > y2 then y2 = b.y + b.height end
  end
end
return x1 and (x1 .. ' ' .. y1 .. ' ' .. (x2 - x1) .. ' ' .. (y2 - y1)) or ''"
}

# Crop src to "x y w h" plus a margin, clamped at the canvas edges on all four
# sides: a box that solves past the screen must not pad the crop with void.
crop_box() { # src "x y w h" margin dest
	bx=$(f1 "$2"); by=$(f2 "$2"); bw=$(f3 "$2"); bh=$(f4 "$2")
	m="$3"
	iw=$(magick identify -format "%w" "$1")
	ih=$(magick identify -format "%h" "$1")
	cx=$((bx - m)); [ "$cx" -lt 0 ] && cx=0
	cy=$((by - m)); [ "$cy" -lt 0 ] && cy=0
	cw=$((bw + bx - cx + m)); [ $((cx + cw)) -gt "$iw" ] && cw=$((iw - cx))
	ch=$((bh + by - cy + m)); [ $((cy + ch)) -gt "$ih" ] && ch=$((ih - cy))
	magick "$1" -crop "${cw}x${ch}+$cx+$cy" +repage "$4"
	echo "  ${4##*/}"
}

if run rc-wallpaper; then
	echo "rc-wallpaper"
	kh_boot "$KILN_REPO/kilnrc.lua"
	kh_shoot "$KH_WORK/rc-wp.png"
	cp "$KH_WORK/rc-wp.png" "$out_rc/rc-wallpaper.png"
	echo "  rc-wallpaper.png"
	kh_halt
fi

if run rc-bar || run rc-launcher || run rc-menu || run rc-tooltip \
		|| run rc-hotkeys || run rc-error; then
	kh_boot "$KILN_REPO/kilnrc.lua"
	kh_spawn_client
	kh_spawn_client
	kh_shoot "$KH_WORK/rc-base.png"

	if run rc-bar; then
		echo "rc-bar"
		taglist="$(box_of "'taglist:HEADLESS-1'")"
		tasklist="$(box_of "'tasklist:HEADLESS-1'")"
		clock="$(box_of "'clock'")"
		layoutbox="$(box_of "'layoutbox:HEADLESS-1'")"
		magick "$KH_WORK/rc-base.png" -crop 1280x104+0+0 +repage "$KH_WORK/rc-bar-c.png"
		"$here/annotate.sh" "$KH_WORK/rc-bar-c.png" "$out_rc/rc-bar.png" \
			"$(f1 "$taglist"),$(f2 "$taglist"),$(f3 "$taglist"),$(f4 "$taglist"),below,taglist" \
			"$(f1 "$tasklist"),$(f2 "$tasklist"),$(f3 "$tasklist"),$(f4 "$tasklist"),below,tasklist" \
			"$(f1 "$clock"),$(f2 "$clock"),$(f3 "$clock"),$(f4 "$clock"),below,the clock box" \
			"$(f1 "$layoutbox"),$(f2 "$layoutbox"),$(f3 "$layoutbox"),$(f4 "$layoutbox"),below,layoutbox"
		echo "  rc-bar.png"
	fi

	if run rc-launcher; then
		echo "rc-launcher"
		g="$(box_of "'launcher'")"
		m=4
		magick "$KH_WORK/rc-base.png" \
			-crop "$(($(f3 "$g") + m + m))x$(($(f4 "$g") + m + m))+$(($(f1 "$g") - m))+$(($(f2 "$g") - m))" \
			+repage -filter point -resize 400% "$out_rc/rc-launcher.png"
		echo "  rc-launcher.png"
	fi

	if run rc-menu; then
		echo "rc-menu"
		press_el launcher >/dev/null
		press_el "menu:/1" >/dev/null
		press_el "menu:/1/3" >/dev/null
		sleep 0.5
		kh_shoot "$KH_WORK/rc-menu.png"
		u="$(union_of "'launcher','menu:box','menu:box/1','menu:box/1/3'")"
		crop_box "$KH_WORK/rc-menu.png" "$u" 14 "$out_rc/rc-menu.png"
		kh_ev 'require("kiln").menu.close() core.dirty()' >/dev/null
		sleep 0.5
	fi

	if run rc-tooltip; then
		echo "rc-tooltip"
		hover_el clock true >/dev/null
		sleep 0.5
		kh_shoot "$KH_WORK/rc-tt.png"
		u="$(union_of "'clock','tooltip'")"
		crop_box "$KH_WORK/rc-tt.png" "$u" 12 "$out_rc/rc-tooltip.png"
		hover_el clock false >/dev/null
	fi

	if run rc-hotkeys; then
		echo "rc-hotkeys"
		# The sheet solves taller than the default 720 headless output, so give
		# it a screen it fits on for the shot, then put the mode back.
		kh_ev "core.output.set_mode('$KH_OUTPUT', 1280, 1200)" >/dev/null
		sleep 1
		kh_ev 'require("kiln").hotkeys.show(screen.all()[1]) core.dirty()' >/dev/null
		sleep 1
		kh_shoot "$KH_WORK/rc-hk.png"
		crop_box "$KH_WORK/rc-hk.png" "$(kh_box "'hotkeys'")" 16 "$out_rc/rc-hotkeys.png"
		kh_ev 'require("kiln").hotkeys.close() core.dirty()' >/dev/null
		kh_ev "core.output.set_mode('$KH_OUTPUT', 1280, 720)" >/dev/null
		sleep 1
	fi

	# Last in this boot: a critical notification is sticky, and every shot
	# after it would carry it. The error is real: a listener that throws, on
	# the same pcall-isolated bus every config callback runs on, so the
	# notification is the rc's own handler doing its job.
	if run rc-error; then
		echo "rc-error"
		kh_ev 'client.on("figure::error", function()
  error("deliberate: thrown to photograph the handler", 0)
end)
client.all()[1]:emit("figure::error")' >/dev/null
		sleep 1
		kh_shoot "$KH_WORK/rc-err.png"
		crop_el "$KH_WORK/rc-err.png" notifications 6 "$out_rc/rc-error.png"
	fi

	kh_halt
fi

if run rc-titlebar; then
	echo "rc-titlebar"
	kh_boot "$KILN_REPO/kilnrc.lua"
	kh_spawn_client "$client_content"
	kh_ev 'local c = client.all()[1]
		c.floating = true
		c.float = { x = 80, y = 120, width = 560, height = 240 }
		core.dirty()' >/dev/null
	sleep 1
	kh_shoot "$KH_WORK/rc-tb.png"

	tb="$(kh_box "{'titlebar', client.all()[1].handle}")"
	flt="$(kh_box "{'float', client.all()[1].handle}")"
	cls="$(kh_box "{'close', client.all()[1].handle}")"
	[ -n "$tb" ] && [ -n "$flt" ] && [ -n "$cls" ] || { echo "no titlebar boxes" >&2; exit 1; }

	tx=$(f1 "$tb"); ty=$(f2 "$tb"); tw=$(f3 "$tb"); th=$(f4 "$tb")
	# The crop keeps a band above for the button chip, a slice of the client
	# below so the titlebar visibly sits on a window, and room under that for
	# the icon and title chips.
	ox=$((tx - 12)); oy=$((ty - 44))
	magick "$KH_WORK/rc-tb.png" -crop "$((tw + 24))x$((th + 44 + 92))+$ox+$oy" \
		+repage "$KH_WORK/rc-tb-c.png"
	# The buttons as one cluster, from the float button's left edge to the
	# close button's right. The icon is the 12px image at the row's left pad;
	# the title is the grow cell between them.
	bx1=$(f1 "$flt"); bx2=$(($(f1 "$cls") + $(f3 "$cls")))
	"$here/annotate.sh" "$KH_WORK/rc-tb-c.png" "$out_rc/rc-titlebar.png" \
		"$((tx + 4 - ox)),$((ty + (th - 12) / 2 - oy)),12,12,below,the client icon" \
		"$((tx + tw / 2 - 80 - ox)),$((ty - oy)),160,$th,below,the title: one grow cell" \
		"$((bx1 - ox)),$(($(f2 "$flt") - oy)),$((bx2 - bx1)),$(f4 "$flt"),above,float / maximize / close"
	echo "  rc-titlebar.png"
	kh_halt
fi

if run rc-themes; then
	echo "rc-themes"
	for name in gruvbox catppuccin nord; do
		mkdir -p "$KH_WORK/cfg/kiln"
		printf '%s\n' "$name" > "$KH_WORK/cfg/kiln/theme"
		kh_boot "$KILN_REPO/kilnrc.lua"
		kh_spawn_client
		kh_spawn_client
		kh_shoot "$KH_WORK/rc-th-$name.png"
		magick "$KH_WORK/rc-th-$name.png" -crop 1280x150+0+0 +repage \
			-resize 768 "$KH_WORK/rc-th-$name-c.png"
		"$here/annotate.sh" "$KH_WORK/rc-th-$name-c.png" "$KH_WORK/rc-th-$name-a.png" \
			"70,62,0,0,center,$name"
		kh_halt
	done
	rm -f "$KH_WORK/cfg/kiln/theme"
	magick "$KH_WORK/rc-th-gruvbox-a.png" "$KH_WORK/rc-th-catppuccin-a.png" \
		"$KH_WORK/rc-th-nord-a.png" \
		-background "#a8421c" -splice 0x6+0+0 -append -chop 0x6 \
		"$out_rc/rc-themes.png"
	echo "  rc-themes.png"
fi

echo "done -> $out and $out_rc"
