#!/usr/bin/env python3
"""Capture the existing tray with spacing and hover settings, then restore it."""
import argparse
import json
from pathlib import Path
import re
import subprocess
import time
import tempfile
import uuid

parser = argparse.ArgumentParser()
parser.add_argument('--output', required=True)
parser.add_argument('--item', required=True)
parser.add_argument('--destination', type=Path, required=True)
parser.add_argument('--attention', action='store_true')
args = parser.parse_args()
args.destination.mkdir(parents=True, exist_ok=True)


def ipc(*arguments):
    result = subprocess.run(['somewm-client', *arguments], capture_output=True, text=True, check=True)
    if not result.stdout.startswith('OK'):
        raise RuntimeError(result.stdout + result.stderr)
    return result.stdout


outputs = ipc('output', 'list')
match = re.search(r'name="' + re.escape(args.output) + r'" geometry=(\d+)x(\d+)\+(-?\d+)\+(-?\d+) scale=([\d.]+)', outputs)
if not match:
    raise RuntimeError('Output not found')
width, height, ox, oy = map(int, match.groups()[:4])
scale = float(match[5])
screens = ipc('screen', 'list')
match = re.search(r'screen=(\d+) geometry=' + re.escape(f'{width}x{height}+{ox}+{oy}'), screens)
if not match:
    raise RuntimeError('Screen not found')
screen_id = match[1]
version = ipc('version')
token = uuid.uuid4().hex


def geometry():
    tree = ipc('clay', 'tree', screen_id)
    match = re.search(r'wibox\.widget\.systray .*? box (\d+),(\d+) (\d+)x(\d+)', tree)
    return tuple(map(int, match.groups())) if match else None


def capture(name):
    deadline = time.monotonic() + 5
    previous = None
    while time.monotonic() < deadline:
        current = geometry()
        if current and current == previous:
            break
        previous = current
        time.sleep(0.15)
    else:
        raise RuntimeError('Tray geometry did not settle')
    x, y, w, h = current
    # Clay coordinates are relative to the output; grim uses desktop coordinates.
    subprocess.run(['grim', '-g', f'{ox+x},{oy+y} {w}x{h}',
                    str(args.destination / name)], check=True)
    return current


provider = None
provider_directory = None
try:
    if args.attention:
        if args.item != 'docs-systray-example':
            raise RuntimeError('--attention requires --item docs-systray-example')
        provider_directory = tempfile.TemporaryDirectory(prefix='systray-attention-')
        state_file = Path(provider_directory.name) / 'status'
        state_file.write_text('Active')
        provider = subprocess.Popen(['python3', str(Path(__file__).with_name('tray-item.py')),
            '--icon', str(Path(__file__).parent.parent / 'kiln/tray.svg'),
            '--state-file', str(state_file)])
        for attempt in range(50):
            found = ipc('eval', 'for _, i in ipairs(systray_item.get_items()) do if i.id == "docs-systray-example" then return i.status end end')
            if 'Active' in found: break
            if provider.poll() is not None: raise RuntimeError('Tray provider exited')
            time.sleep(0.1)
        else:
            raise RuntimeError('Tray item did not register')
    ipc('eval', 'return assert(loadfile(' + json.dumps(str(Path(__file__).with_name('scene.lua'))) + '))(' + json.dumps(token) + ')')
    if args.attention:
        ipc('eval', '_G.docs_systray_style.attention(' + json.dumps(args.item) + ')')
        normal = capture('attention-normal.png')
        state_file.write_text('NeedsAttention')
        for attempt in range(50):
            status = ipc('eval', 'for _, i in ipairs(systray_item.get_items()) do if i.id == "docs-systray-example" then return i.status end end')
            if 'NeedsAttention' in status: break
            time.sleep(0.1)
        else:
            raise RuntimeError('Attention status did not arrive')
        highlighted = capture('attention.png')
    else:
        normal = capture('spacing.png')
        ipc('eval', '_G.docs_systray_style.hover(' + json.dumps(args.item) + ')')
        highlighted = capture('hover.png')
    manifest = dict(version=version, output=args.output, screen=screen_id,
                    output_geometry=[ox, oy, width, height], scale=scale,
                    item=args.item, normal_crop=normal, highlighted_crop=highlighted,
                    effect='attention' if args.attention else 'hover')
    (args.destination / 'capture.json').write_text(json.dumps(manifest, indent=2) + '\n')
finally:
    if provider is not None:
        provider.terminate()
        provider.wait(timeout=5)
    if provider_directory is not None:
        provider_directory.cleanup()
    ipc('eval', 'local s = _G.docs_systray_style; if s and s.token == ' + json.dumps(token) + ' then s.stop() end')
