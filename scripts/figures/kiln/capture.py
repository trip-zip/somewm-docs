#!/usr/bin/env python3
"""Capture reference scenes in a private nested Kiln session on SomeWM."""
import argparse
import json
import math
import os
from pathlib import Path
import re
import signal
import struct
import subprocess
import tempfile
import time

HERE = Path(__file__).resolve().parent


def command(args, **kwargs):
    return subprocess.run(args, check=True, text=True, capture_output=True, timeout=15, **kwargs).stdout.strip()


def host(code):
    result = command(['somewm-client', 'eval', ' '.join(code.splitlines())])
    if result == 'OK (no return value)':
        return ''
    if not result.startswith('OK\n'):
        raise RuntimeError(result)
    value = result.removeprefix('OK\n').strip()
    return '' if value == 'OK (no return value)' else value


def wait_for(fn, seconds=12, label='readiness deadline exceeded'):
    end = time.monotonic() + seconds
    while time.monotonic() < end:
        value = fn()
        if value:
            return value
        time.sleep(0.1)
    raise RuntimeError(label)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('scenes', nargs='*')
    parser.add_argument('--source', type=Path, default=Path.home() / 'tools/kiln')
    parser.add_argument('--out', type=Path, required=True, help='Unreviewed capture directory')
    parser.add_argument('--connector', help='Host output; defaults to the rightmost')
    args = parser.parse_args()
    args.source = args.source.resolve()
    args.out = args.out.resolve()
    args.out.mkdir(parents=True, exist_ok=True)
    scenes = args.scenes or sorted(p.stem for p in HERE.glob('*.lua') if p.stem not in ('lib', 'config'))
    for name in scenes:
        if not re.fullmatch(r'(widget|ui)-[a-z_]+', name) or not (HERE / (name + '.lua')).is_file():
            raise ValueError(f'unknown scene: {name}')
    work = Path(tempfile.mkdtemp(prefix='kiln-reference-'))
    print(f'Session files: {work}', flush=True)
    for directory in ('home', 'runtime', 'config', 'data', 'cache'):
        (work / directory).mkdir(mode=0o700)
    # A transparent cursor affects only the nested session; the host pointer is not moved.
    cursors = work / 'icons/reference/cursors'
    cursors.mkdir(parents=True)
    words = (0x72756358, 16, 0x10000, 1, 0xfffd0002, 24, 28,
             36, 0xfffd0002, 24, 1, 1, 1, 0, 0, 0, 0)
    (cursors / 'default').write_bytes(struct.pack('<17I', *words))
    parent = Path(os.environ['WAYLAND_DISPLAY'])
    if not parent.is_absolute():
        parent = Path(os.environ['XDG_RUNTIME_DIR']) / parent
    env = dict(os.environ)
    for key in ('DISPLAY', 'WAYLAND_SOCKET', 'DBUS_SESSION_BUS_ADDRESS', 'DBUS_SESSION_BUS_PID'):
        env.pop(key, None)
    env.update(HOME=str(work / 'home'), XDG_RUNTIME_DIR=str(work / 'runtime'),
               XDG_CONFIG_HOME=str(work / 'config'), XDG_DATA_HOME=str(work / 'data'),
               XDG_CACHE_HOME=str(work / 'cache'), WAYLAND_DISPLAY=str(parent),
               XCURSOR_PATH=str(work / 'icons'), XCURSOR_THEME='reference', KILN_BACKEND='nested', KILN_RC=str(HERE / 'config.lua'), KILN_SOCK=str(work / 'eval.sock'))
    client = str(args.source / 'build/kiln-client')

    def ev(code):
        return command([client, '-s', str(work / 'eval.sock'), 'eval', code])

    host_pid = None
    children = []
    log = open(work / 'server.log', 'w')
    proc = subprocess.Popen(['dbus-run-session', '--', str(args.source / 'build/kiln')],
                            cwd=args.source, env=env, stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
    try:
        def ready():
            if proc.poll() is not None:
                raise RuntimeError(f'Kiln startup failed; see {work / "server.log"}')
            return (work / 'eval.sock').exists()
        wait_for(ready)
        # The nested display name contains the compositor PID, not the D-Bus wrapper PID.
        display = wait_for(lambda: re.search(r'WAYLAND_DISPLAY=kiln-(\d+)', (work / 'server.log').read_text()))
        host_pid = display.group(1)
        wait_for(lambda: host(f'for _,c in ipairs(client.get()) do if tostring(c.pid)=={json.dumps(host_pid)} then return "found" end end') == 'found')
        connector = json.dumps(args.connector) if args.connector else 'nil'
        placement = host(f'''local wanted={connector}; local target
for s in screen do
  if wanted then for _,o in pairs(s.outputs) do if o.name==wanted then target=s end end
  elseif not target or s.geometry.x>target.geometry.x then target=s end
end
assert(target,"host output not found")
for _,c in ipairs(client.get()) do if tostring(c.pid)=={json.dumps(host_pid)} then
  c.floating=true; c.ontop=true; c.screen=target; c:tags(target.selected_tags); c:raise()
  c:geometry{{x=target.workarea.x+80,y=target.workarea.y+50,width=1600,height=1120}}
  local output; for _,o in pairs(target.outputs) do output=o.name end
  return output
end end''')
        print(f'Nested window on {placement}', flush=True)
        wait_for(lambda: ev('local s=screen.all()[1]; return s and s.width>=1500') == 'yes')
        ev('screen.all()[1].scale=1.5')
        wait_for(lambda: ev('return screen.all()[1].scale') == '1.5')
        client_scenes = {'widget-taglist', 'widget-tasklist', 'widget-titlebar', 'widget-client', 'ui-surface', 'widget-resize_handles'}
        if client_scenes.intersection(scenes):
            for filename in ('widgets.lua', 'ui.lua'):
                argv = ['foot', '--app-id=kiln-reference-source', '--title=' + filename,
                        '-o', 'main.font=monospace:size=9', '-o', 'colors-dark.background=282828',
                        '-o', 'colors-dark.foreground=ebdbb2', 'sh', '-c',
                        r'printf "\033[?25l"; head -n 12 "$1"; exec sleep 120', 'source', str(args.source / 'lua/kiln' / filename)]
                ev('core.spawn({' + ','.join(json.dumps(v) for v in argv) + '})')
            wait_for(lambda: ev('return #client.all()') == '2')
            ev('client.all()[1]:focus()')
        if 'widget-systray' in scenes:
            tray_env = dict(env, DBUS_SESSION_BUS_ADDRESS=ev('return os.getenv("DBUS_SESSION_BUS_ADDRESS")'))
            children.append(subprocess.Popen(['python3', str(HERE / 'tray.py')], env=tray_env,
                                             stdout=log, stderr=subprocess.STDOUT))
            wait_for(lambda: ev('return #require("kiln").systray.items()') == '1')
        metadata = {'backend': 'nested', 'host_output': placement, 'scale': 1.5,
                    'source': command(['git', '-C', str(args.source), 'rev-parse', 'HEAD']), 'figures': {}}
        for name in scenes:
            if name == 'widget-taglist':
                ev('client.all()[2].tags={screen.all()[1].tags[2]}')
            elif name in client_scenes:
                ev('for _,c in ipairs(client.all()) do c.tags={screen.all()[1].tags[1]} end')
            scene = (HERE / 'lib.lua').read_text() + '\n' + (HERE / (name + '.lua')).read_text()
            path = work / (name + '.lua')
            path.write_text(scene)
            ev(f'dofile({json.dumps(str(path))})')
            geometry = 'local b=core.box("kiln-reference-figure"); return b and table.concat({b.x,b.y,b.width,b.height},",") or ""'
            last = None
            def settled():
                nonlocal last
                value = ev(geometry)
                same = value and value == last
                last = value
                return value if same else None
            box = [float(v) for v in wait_for(settled, label=f'{name}: no settled figure; check {work / "server.log"} for a committed frame').split(',')]
            time.sleep(0.35)
            raw = work / (name + '-full.png')
            command([client, '-s', str(work / 'eval.sock'), 'screenshot', str(raw)])
            x, y, w, h = box
            scale = 1.5
            left, top = math.ceil((x + 1) * scale), math.ceil((y + 1) * scale)
            width, height = math.floor((x + w - 1) * scale) - left, math.floor((y + h - 1) * scale) - top
            iw, ih = map(int, command(['magick', 'identify', '-format', '%w %h', str(raw)]).split())
            if left < 0 or top < 0 or left + width > iw or top + height > ih:
                raise RuntimeError(f'{name}: figure exceeds output: {box}, {iw}x{ih}')
            output = args.out / (name + '.png')
            command(['magick', str(raw), '-crop', f'{width}x{height}+{left}+{top}', '+repage', str(output)])
            (args.out / (name + '.lua')).write_text(scene)
            metadata['figures'][name] = {'width': width, 'height': height, 'logical_box': box}
            print(f'{name}: {width}x{height}', flush=True)
            ev('kiln_reference_figure.stop()')
        errors = [line for line in (work / 'server.log').read_text().splitlines()
                  if re.search(r'FIGURE ERROR|Lua (frame|event|timer)|stack traceback|declare failed|invalid section name|Image decode failed', line)]
        if errors:
            raise RuntimeError('\n'.join(errors))
        (args.out / 'manifest.json').write_text(json.dumps(metadata, indent=2) + '\n')
    finally:
        for child in children:
            child.terminate()
            child.wait(timeout=5)
        if (work / 'eval.sock').exists():
            try:
                ev('for _,c in ipairs(client.all()) do c:close() end')
                wait_for(lambda: ev('return #client.all()') == '0', seconds=3)
                command([client, '-s', str(work / 'eval.sock'), 'quit'])
            except (subprocess.SubprocessError, OSError, RuntimeError):
                pass
        try:
            proc.wait(timeout=5)
        except subprocess.TimeoutExpired:
            os.killpg(proc.pid, signal.SIGTERM)
            proc.wait(timeout=5)
        log.close()



if __name__ == '__main__':
    main()
