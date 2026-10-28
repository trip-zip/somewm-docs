#!/usr/bin/env python3
"""Export one StatusNotifierItem on the capture session's private bus."""
from pathlib import Path
from gi.repository import Gio, GLib

xml = '''<node><interface name="org.kde.StatusNotifierItem">
<property name="Id" type="s" access="read"/>
<property name="Title" type="s" access="read"/>
<property name="Status" type="s" access="read"/>
<property name="IconName" type="s" access="read"/>
<method name="Activate"><arg type="i" direction="in"/><arg type="i" direction="in"/></method>
<method name="Scroll"><arg type="i" direction="in"/><arg type="s" direction="in"/></method>
</interface></node>'''
properties = {'Id': 'kiln-reference-status', 'Title': 'Reference status item',
              'Status': 'Active', 'IconName': str(Path(__file__).with_name('tray.svg'))}
bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
info = Gio.DBusNodeInfo.new_for_xml(xml).interfaces[0]
bus.register_object('/StatusNotifierItem', info,
                    lambda conn, sender, path, iface, method, args, invocation: invocation.return_value(None),
                    lambda conn, sender, path, iface, prop: GLib.Variant('s', properties[prop]), None)
bus.call_sync('org.kde.StatusNotifierWatcher', '/StatusNotifierWatcher',
              'org.kde.StatusNotifierWatcher', 'RegisterStatusNotifierItem',
              GLib.Variant('(s)', ('/StatusNotifierItem',)), None, Gio.DBusCallFlags.NONE, 5000, None)
loop = GLib.MainLoop()
GLib.timeout_add_seconds(180, lambda: loop.quit())
loop.run()
