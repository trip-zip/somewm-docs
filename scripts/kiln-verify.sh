#!/bin/sh
# Boot a headless kiln on a config and report whether it actually runs.
#
#   scripts/kiln-verify.sh path/to/rc.lua              # verify a config
#   scripts/kiln-verify.sh rc.lua --shot out.png       # and capture the result
#   scripts/kiln-verify.sh rc.lua --box launcher       # and print a solved box
#
# The kiln docs working agreement is that every code sample is checked against a
# live compositor rather than written from source reading. This is that check.
#
# A clean run is not merely "kiln started": kiln keeps the last good frame when a
# declare fails, so a broken config can start, log an error, and look fine. This
# greps the log for Lua errors and failed solves, and exits non-zero on either.
set -eu

repo="$(cd "$(dirname "$0")/.." && pwd)"
. "$repo/scripts/lib/kiln-headless.sh"

rc=""
shot=""
boxes=""
clients=0

while [ $# -gt 0 ]; do
	case "$1" in
	--shot)    shot="$2"; shift 2 ;;
	--box)     boxes="$boxes $2"; shift 2 ;;
	--clients) clients="$2"; shift 2 ;;
	-h|--help) sed -n '2,10p' "$0"; exit 0 ;;
	*)         rc="$1"; shift ;;
	esac
done

[ -n "$rc" ] || { echo "usage: kiln-verify.sh <rc.lua> [--shot out.png] [--box id] [--clients n]" >&2; exit 1; }
[ -f "$rc" ] || { echo "no such config: $rc" >&2; exit 1; }

kh_init
trap kh_cleanup EXIT

rc="$(cd "$(dirname "$rc")" && pwd)/$(basename "$rc")"
kh_boot "$rc" || exit 1

i=0
while [ "$i" -lt "$clients" ]; do
	kh_spawn_client
	i=$((i + 1))
done

# Force a fresh solve so a declare error surfaces even if the first frame
# happened to predate whatever the config registers.
kh_ev 'core.dirty()' >/dev/null 2>&1 || true
sleep 1

errs="$(kh_errors)"
[ -n "$shot" ] && kh_shoot "$shot"

for id in $boxes; do
	printf '  box %-28s %s\n' "$id" "$(kh_box "'$id'" | sed 's/^$/nil/')"
done

if [ -n "$errs" ]; then
	echo "FAIL  $rc"
	echo "$errs" | sed 's/^/      /'
	exit 1
fi

solves="$(grep -c 'solve #' "$KH_LOG" 2>/dev/null || echo 0)"
echo "ok    $rc  ($solves solve(s), no errors)"
[ -n "$shot" ] && echo "      wrote $shot"
exit 0
