#!/bin/sh
# Draw callouts onto a capture: outline a region, run a leader line to a chip,
# print the chip's label.
#
#   annotate.sh src.png dest.png 'x,y,w,h,side,label' ['x,y,w,h,side,label' ...]
#
# side is above|below and says which way the chip hangs off the region, or
# center to put the chip inside it. A region of w=0,h=0 is a bare chip at x,y:
# no outline and no leader, for captions that do not point at anything.
#
# The geometry always comes from core.box on the live compositor, so these
# callouts sit on Clay's own solved boxes rather than on coordinates somebody
# measured off a screenshot once and never checked again.
set -eu

src="$1"; dest="$2"; shift 2

AMBER="#ecab57"
RUST="#a8421c"
PAPER="#f4ebe6"
MONO="${FIG_MONO:-/usr/share/fonts/TTF/JetBrainsMono-Regular.ttf}"
PT="${FIG_PT:-14}"

img_w=$(magick identify -format "%w" "$src")
img_h=$(magick identify -format "%h" "$src")

# Stash the annotations, then rebuild the positional parameters as magick's
# argument list. Assembling a command string and eval'ing it cannot survive a
# label containing a quote, which is exactly what an English caption contains.
spec_file=$(mktemp)
trap 'rm -f "$spec_file"' EXIT
for a in "$@"; do printf '%s\n' "$a"; done > "$spec_file"

set --

while IFS= read -r a; do
	[ -n "$a" ] || continue
	x=$(echo "$a" | cut -d, -f1)
	y=$(echo "$a" | cut -d, -f2)
	w=$(echo "$a" | cut -d, -f3)
	h=$(echo "$a" | cut -d, -f4)
	side=$(echo "$a" | cut -d, -f5)
	label=$(echo "$a" | cut -d, -f6-)

	# Exact text metrics, so the chip fits its label instead of guessing an
	# advance width per character.
	tw=$(magick -font "$MONO" -pointsize "$PT" label:"$label" -format "%w" info:)
	th=$(magick -font "$MONO" -pointsize "$PT" label:"$label" -format "%h" info:)
	cw=$((tw + 18))
	ch=$((th + 10))

	cx=$((x + w / 2 - cw / 2))
	[ "$cx" -lt 4 ] && cx=4
	[ $((cx + cw)) -gt $((img_w - 4)) ] && cx=$((img_w - cw - 4))

	case "$side" in
	below)  cy=$((y + h + 20)); ly1=$((y + h)); ly2=$cy ;;
	center) cy=$((y + h / 2 - ch / 2)); ly1=0; ly2=0 ;;
	*)      cy=$((y - 20 - ch)); ly1=$y; ly2=$((cy + ch)) ;;
	esac

	# Keep the chip on the canvas in both axes. Without the vertical clamp an
	# "above" chip near the top edge is drawn off-image and silently vanishes.
	[ "$cy" -lt 4 ] && cy=4
	[ $((cy + ch)) -gt $((img_h - 4)) ] && cy=$((img_h - ch - 4))

	if [ "$w" -ne 0 ] || [ "$h" -ne 0 ]; then
		set -- "$@" -stroke "$AMBER" -strokewidth 2 -fill none \
			-draw "roundrectangle $x,$y $((x + w - 1)),$((y + h - 1)) 5,5"
		if [ "$side" != center ]; then
			set -- "$@" -stroke "$AMBER" -strokewidth 1 \
				-draw "line $((x + w / 2)),$ly1 $((cx + cw / 2)),$ly2"
		fi
	fi

	set -- "$@" -stroke none -fill "$RUST" \
		-draw "roundrectangle $cx,$cy $((cx + cw)),$((cy + ch)) 4,4" \
		-fill "$PAPER" -font "$MONO" -pointsize "$PT" \
		-annotate "+$((cx + 9))+$((cy + ch - 8))" "$label"
done < "$spec_file"

magick "$src" "$@" "$dest"
