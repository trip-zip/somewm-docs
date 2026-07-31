#!/bin/sh
# Render the Clay thesis figures by booting a real headless kiln, declaring the
# figure, and screenshotting what Clay solved.
#
#   scripts/figures/generate.sh          # all figures
#   scripts/figures/generate.sh 01 04    # only these
#
# Every image under static/img/kiln/clay/ comes from here. Nothing is drawn by
# hand, so when kiln's API moves the figures are one command from current.
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

	# The bar plus a band underneath for the callout chips.
	magick "$KH_WORK/03.png" -crop 1280x104+0+0 +repage "$KH_WORK/03-c.png"
	"$here/annotate.sh" "$KH_WORK/03-c.png" "$out/03-bar.png" \
		"$(f1 "$launcher"),$(f2 "$launcher"),$(f3 "$launcher"),$(f4 "$launcher"),below,ui.box" \
		"$(f1 "$taglist"),$(f2 "$taglist"),$(f3 "$taglist"),$(f4 "$taglist"),below,ui.taglist(s)" \
		"$(f1 "$tasklist"),$(f2 "$tasklist"),$(f3 "$tasklist"),$(f4 "$tasklist"),below,ui.tasklist(s)" \
		"$(f1 "$clock"),$(f2 "$clock"),$(f3 "$clock"),$(f4 "$clock"),below,ui.clock()" \
		"$(f1 "$layoutbox"),$(f2 "$layoutbox"),$(f3 "$layoutbox"),$(f4 "$layoutbox"),below,ui.layoutbox(s)"
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
		"$((tx - ox)),$((ty - oy)),$tw,$th,below,ui.titlebar - Clay draws this" \
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

echo "done -> $out"
