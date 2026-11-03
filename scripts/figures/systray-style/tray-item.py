#!/usr/bin/env python3
"""Publish a temporary tray item with a controllable StatusNotifierItem status."""
import argparse
from pathlib import Path
from gi.repository import Gio, GLib

parser = argparse.ArgumentParser()
parser.add_argument('--icon', type=Path, required=True)
parser.add_argument('--state-file', type=Path, required=True)
args = parser.parse_args()
xml = '''<node><interface name="org.kde.StatusNotifierItem">
<property name="Id" type="s" access="read"/>
<property name="Title" type="s" access="read"/>
<property name="Status" type="s" access="read"/>
<property name="IconName" type="s" access="read"/>
<signal name="NewStatus"><arg type="s"/></signal>
<method name="Activate"><arg type="i" direction="in"/><arg type="i" direction="in"/></method>
<method name="Scroll"><arg type="i" direction="in"/><arg type="s" direction="in"/></method>
</interface></node>'''
properties = {'Id': 'docs-systray-example', 'Title': 'Systray documentation example',
              'Status': 'Active', 'IconName': str(args.icon.resolve())}
bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
info = Gio.DBusNodeInfo.new_for_xml(xml).interfaces[0]
bus.register_object('/StatusNotifierItem', info,
                    lambda conn, sender, path, iface, method, values, invocation: invocation.return_value(None),
                    lambda conn, sender, path, iface, prop: GLib.Variant('s', properties[prop]), None)
bus.call_sync('org.kde.StatusNotifierWatcher', '/StatusNotifierWatcher',
              'org.kde.StatusNotifierWatcher', 'RegisterStatusNotifierItem',
              GLib.Variant('(s)', ('/StatusNotifierItem',)), None, Gio.DBusCallFlags.NONE, 5000, None)


def update():
    status = args.state_file.read_text().strip()
    if status in ('Active', 'NeedsAttention') and status != properties['Status']:
        properties['Status'] = status
        bus.emit_signal(None, '/StatusNotifierItem', 'org.kde.StatusNotifierItem',
                        'NewStatus', GLib.Variant('(s)', (status,)))
    return True


loop = GLib.MainLoop()
GLib.timeout_add(50, update)
GLib.timeout_add_seconds(120, lambda: loop.quit())
loop.run()
