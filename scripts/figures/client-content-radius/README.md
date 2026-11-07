# Client content radius

`live.lua` opens three real foot terminals on the selected output. It adds temporary rules and floating windows to that output's selected tag. It does not change the theme, layout or existing clients. Click **Close demo** beneath a window to remove all three.

Run from the documentation checkout, with a compositor that supports `client.content_radius`:

```sh
somewm-client output list
somewm-client eval "return loadfile(\"$PWD/scripts/figures/client-content-radius/live.lua\")({output=\"eDP-1\"})"
```

Replace `eDP-1` with the intended connector. Once the three terminals appear:

```sh
grim -o eDP-1 /tmp/content-radius-screen.png
somewm-client eval 'for _, c in ipairs(_berry_border_demo.clients) do if c.class == "BerryConceptInner" then local g=c:geometry(); return string.format("crop logical %dx%d+%d+%d scale=%s",g.width,g.height,g.x,g.y,c.screen.scale) end end'
```

Multiply the returned coordinates and dimensions by the output scale for the ImageMagick crop. Do not resize the capture before cropping.

The checked-in `static/img/clients/content-radius.png` is the middle terminal from a live 2880×1920 capture of `eDP-1`: logical output 1920×1280, scale 1.5, client geometry 578×483+668+406. The crop was:

```sh
magick /tmp/content-radius-screen.png -crop 867x724+1002+609 +repage static/img/clients/content-radius.png
```

The image shows four square purple titlebars, a 27-logical-pixel content radius and a pale outline drawn by a separate input-transparent wibox. The terminal uses foot's `monospace:size=12` font, `252b3b` background and `b8ddc8` foreground. The original wallpaper and bar remain outside the crop. The crop was inspected for all four curved content corners and a continuous purple backing.

The guide's downloadable `static/examples/rounded-content.lua` is a separate configuration helper. It uses an 18-pixel radius, a 48-pixel top titlebar, 12-pixel side/bottom titlebars and standard window controls. It does not add an outline wibox.

To stop the capture scene from the command line:

```sh
somewm-client eval 'if _berry_border_demo then _berry_border_demo.stop() end'
```

Verify the guide's Lua blocks and shell eval expressions, and sample the helper's four inner corners at 1.5× scale, from the SomeWM source checkout:

```sh
HEADLESS=1 SOMEWM_DOCS_REPO=../somewm-docs make test-one TEST=../somewm-docs/scripts/figures/client-content-radius/verify.lua
```

The verifier uses a solid-color Wayland fixture client and reads both `screen.content` and grim pixels. It does not open or modify Firefox.
