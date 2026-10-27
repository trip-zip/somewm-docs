-- wibox.widget.textbox: text and markup, alignment, ellipsize, font.
local long = "A long line of text that does not fit in the slot it was given, so it is cut"
return F.scene("wibox.widget.textbox", "One string of text, aligned, cut or wrapped, in a font", {
    F.row('text = "Hello"', F.label("Hello")),
    F.row('markup = "<b>Bold</b> ..."', { markup = "<b>Bold</b> <i>italic</i> <span foreground='#83a598'>blue</span>", font = F.font, widget = wibox.widget.textbox }),
    F.row('halign = "left"', F.label("left", { halign = "left" })),
    F.row('halign = "center"', F.label("center", { halign = "center" })),
    F.row('halign = "right"', F.label("right", { halign = "right" })),
    F.row('valign = "top"', F.label("top", { valign = "top" }), { h = 64 }),
    F.row('valign = "bottom"', F.label("bottom", { valign = "bottom" }), { h = 64 }),
    F.row('ellipsize = "end" (default)', F.label(long), { w = 360 }),
    F.row('ellipsize = "none"', F.label(long, { ellipsize = "none" }), { w = 360, h = 72 }),
    F.row('font = "sans Bold 14"', F.label("Bold 14", { font = F.font_bold })),
    F.row('font = "monospace 18"', F.label("monospace 18", { font = "monospace 18" }), { h = 64 }),
})
