# Client content radius

`live.lua` opens three floating foot terminals on the selected output's current tag using a temporary rule. The theme, layout and existing clients are unchanged. Click **Close demo** beneath any window to close all three.

Run from the documentation checkout, with a compositor that supports `client.content_radius`:

```sh
somewm-client output list
somewm-client eval "return loadfile(\"$PWD/scripts/figures/client-content-radius/live.lua\")({output=\"eDP-1\"})"
```

Replace `eDP-1` with the intended connector. Once the three terminals appear:

```sh
grim -o eDP-1 /tmp/content-radius-screen.png
somewm-client eval 'for _, c in ipairs(_berry_border_demo.clients) do if c.class == "BerryConceptInner" then local g=c:geometry(); local s=c.screen.geometry; return string.format("crop logical %dx%d+%d+%d scale=%s",g.width,g.height,g.x-s.x,g.y-s.y,c.screen.scale) end end'
```

The coordinates are relative to the captured output. Multiply them and the dimensions by the output scale for the ImageMagick crop. Do not resize before cropping.

The checked-in `static/img/clients/content-radius.png` is the middle terminal from a live 2880×1920 capture of `eDP-1`: logical output 1920×1280, scale 1.5, client geometry 578×483+668+406. The crop was:

```sh
magick /tmp/content-radius-screen.png -crop 867x724+1002+609 +repage static/img/clients/content-radius.png
```

The image shows four square purple titlebars and a radius of 27 logical pixels. A separate input-transparent wibox draws the pale outline. Foot uses `monospace:size=12`, background `252b3b` and foreground `b8ddc8`.

The guide's `static/examples/rounded-content.lua` helper uses an 18-pixel radius, a 48-pixel top titlebar, 12-pixel side/bottom titlebars and standard window controls, without the outline wibox. All sizes use logical pixels.

To stop the capture scene from the command line:

```sh
somewm-client eval 'if _berry_border_demo then _berry_border_demo.stop() end'
```

From the SomeWM source checkout, verify the guide examples and the helper's four inner corners at 1.5× scale:

```sh
HEADLESS=1 SOMEWM_DOCS_REPO=../somewm-docs make test-one TEST=../somewm-docs/scripts/figures/client-content-radius/verify.lua
```

The verifier uses a solid-color Wayland fixture client and reads both `screen.content` and grim pixels. It does not open or modify Firefox.
