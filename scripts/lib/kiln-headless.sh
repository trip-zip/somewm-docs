# Sourceable helpers for driving a headless kiln.
#
#   . "$repo/scripts/lib/kiln-headless.sh"
#   kh_init
#   kh_boot /path/to/rc.lua
#   kh_ev 'return #client.all()'
#   kh_halt
#
# Every consumer gets the same isolation guarantees, which is the point of the
# extraction: the operator is very likely running kiln as their real session
# while these scripts run, and exactly one copy of that guard should exist.
#
# Callers must set a trap themselves:  trap kh_cleanup EXIT

KILN_REPO="${KILN_REPO:-$HOME/tools/kiln}"
KH_BIN="$KILN_REPO/build/kiln"

KH_WORK=""
KH_SOCK=""
KH_LOG=""
KH_PID=""
KH_CLIENTS=""
KH_DISPLAY=""
KH_OUTPUT="HEADLESS-1"

kh_require() {
	[ -x "$KH_BIN" ] || { echo "no kiln binary at $KH_BIN (build it, or set KILN_REPO)" >&2; return 1; }
	command -v nc >/dev/null || { echo "nc not found" >&2; return 1; }
}

kh_init() {
	kh_require || exit 1
	KH_WORK="$(mktemp -d /tmp/kiln-headless.XXXXXX)"
	KH_SOCK="$KH_WORK/kiln.sock"
	KH_LOG="$KH_WORK/kiln.log"
	mkdir -p "$KH_WORK/cfg"

	# A boot unlinks its socket path before binding. If that path were ever the
	# session socket, this would take IPC away from the live session, so refuse
	# rather than find out.
	if [ "$KH_SOCK" = "${XDG_RUNTIME_DIR:-/tmp}/kiln.sock" ]; then
		echo "refusing to run: work socket collides with the session socket" >&2
		exit 1
	fi
}

# Only ever kill PIDs recorded here. No pkill, no killall, nothing matched by
# process name: a name-based kill would drop the operator to a TTY.
kh_cleanup() {
	for p in $KH_CLIENTS $KH_PID; do
		kill "$p" 2>/dev/null || true
	done
	[ -n "$KH_WORK" ] && rm -rf "$KH_WORK"
	KH_CLIENTS=""
	KH_PID=""
}

kh_halt() {
	for p in $KH_CLIENTS $KH_PID; do
		kill "$p" 2>/dev/null || true
	done
	KH_CLIENTS=""
	KH_PID=""
	sleep 0.5
}

# Boot on the given rc and wait for the IPC socket.
#
# XDG_CONFIG_HOME is pinned at an empty dir because kiln resolves
# $XDG_CONFIG_HOME/kiln/rc.lua ahead of KILN_RC. Without the pin, a run would
# quietly use whatever config the operator has installed.
kh_boot() {
	rm -f "$KH_SOCK"
	WLR_BACKENDS=headless WLR_LIBINPUT_NO_DEVICES=1 \
		XDG_CONFIG_HOME="$KH_WORK/cfg" KILN_SOCK="$KH_SOCK" KILN_RC="$1" \
		"$KH_BIN" >"$KH_LOG" 2>&1 &
	KH_PID=$!
	n=0
	while [ ! -S "$KH_SOCK" ]; do
		n=$((n + 1))
		if [ "$n" -gt 80 ]; then
			echo "kiln did not come up; last lines of its log:" >&2
			tail -20 "$KH_LOG" >&2
			return 1
		fi
		sleep 0.25
	done
	sleep 1
	KH_DISPLAY="$(sed -n 's/.*WAYLAND_DISPLAY=\([a-z0-9-]*\).*/\1/p' "$KH_LOG" | head -1)"
}

kh_ev() { KILN_SOCK="$KH_SOCK" "$KILN_REPO/scripts/kiln-eval" "$1"; }

kh_shoot() { kh_ev "core.screenshot('$KH_OUTPUT', '$1')" >/dev/null; }

# Solved box of an element, as "x y w h", empty if the id is not in the tree.
# The argument is a Lua expression: kh_box "'launcher'" or
# kh_box "{'titlebar', client.all()[1].handle}"
kh_box() {
	kh_ev "local b = core.box($1); return b and (b.x..' '..b.y..' '..b.width..' '..b.height) or ''"
}

# Spawn a terminal into this instance only, recording its PID for cleanup.
kh_spawn_client() {
	WAYLAND_DISPLAY="$KH_DISPLAY" foot -e sh -c "${1:-clear}; sleep 600" >/dev/null 2>&1 &
	KH_CLIENTS="$KH_CLIENTS $!"
	sleep 2
}

# Lua errors and failed solves from this run's log, empty when the config is
# clean. kiln keeps the previous frame on a declare failure rather than
# crashing, so a broken config is otherwise easy to miss.
kh_errors() {
	grep -iE '\[error\]|declare failed|attempt to |stack traceback' "$KH_LOG" 2>/dev/null \
		| grep -v 'EGL\|GLES' || true
}
