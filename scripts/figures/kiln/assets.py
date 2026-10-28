#!/usr/bin/env python3
"""Copy reviewed figures into the docs, or check their source and inline Lua."""
import argparse
import json
from pathlib import Path
import shutil
import struct

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
DEST = ROOT / 'static/img/reference/kiln'


def partial(name):
    module = 'widgets' if name.startswith('widget-') else 'ui'
    return ROOT / 'kiln/reference' / module / '_lua' / (name + '.mdx')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--from', dest='source', type=Path, help='Directory of reviewed captures')
    group.add_argument('--check', action='store_true')
    args = parser.parse_args()
    source = args.source or DEST
    manifest = json.loads((source / 'manifest.json').read_text())
    expected = {p.stem for p in HERE.glob('*.lua') if p.stem not in ('lib', 'config')}
    assert set(manifest['figures']) == expected, 'a complete capture set is required'
    for name, info in manifest['figures'].items():
        scene = (HERE / 'lib.lua').read_text() + '\n' + (HERE / (name + '.lua')).read_text()
        assert (source / (name + '.lua')).read_text() == scene, f'{name}: source changed since capture'
        png = (source / (name + '.png')).read_bytes()
        assert png[:8] == b'\x89PNG\r\n\x1a\n', f'{name}: invalid PNG'
        assert struct.unpack('>II', png[16:24]) == (info['width'], info['height']), f'{name}: wrong dimensions'
        inline = '```lua\n' + scene + '```\n'
        if args.check:
            assert partial(name).read_text() == inline, f'{name}: inline Lua differs'
        else:
            DEST.mkdir(parents=True, exist_ok=True)
            for suffix in ('.png', '.lua'):
                shutil.copyfile(source / (name + suffix), DEST / (name + suffix))
            partial(name).parent.mkdir(parents=True, exist_ok=True)
            partial(name).write_text(inline)
    if not args.check:
        shutil.copyfile(source / 'manifest.json', DEST / 'manifest.json')
    print(f'{len(manifest["figures"])} figures {"checked" if args.check else "copied"}.')


if __name__ == '__main__':
    main()
