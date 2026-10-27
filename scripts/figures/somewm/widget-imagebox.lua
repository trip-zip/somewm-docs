-- wibox.widget.imagebox: one 64x40 image drawn with Cairo, shown at several sizes.
local cairo = require("lgi").cairo
local img = cairo.ImageSurface.create(cairo.Format.ARGB32, 64, 40)
local cr = cairo.Context(img)
cr:set_source(gears.color(F.blue)); cr:rectangle(0, 0, 64, 40); cr:fill()
cr:set_source(gears.color(F.amber)); cr:arc(20, 20, 14, 0, 2 * math.pi); cr:fill()
cr:set_source(gears.color(F.green)); cr:rectangle(40, 8, 18, 24); cr:fill()
local function image(extra)
    local t = { image = img, widget = wibox.widget.imagebox }
    for k, v in pairs(extra or {}) do t[k] = v end
    return t
end
return F.scene("wibox.widget.imagebox", "A 64x40 image, resized or not, aligned, clipped", {
    F.row('image = surface (own size)', image(), { fit = true }),
    F.row('forced_height = 80', image { forced_height = 80 }, { fit = true }),
    F.row('forced_width = 200, forced_height = 60', image { forced_width = 200, forced_height = 60 }, { fit = true }),
    F.row('resize = false', image { resize = false }, { h = 80 }),
    F.row('upscale = false', image { upscale = false }, { h = 80 }),
    F.row('halign = "right", valign = "bottom"', image { halign = "right", valign = "bottom" }, { h = 80 }),
    F.row('clip_shape = gears.shape.circle', image { clip_shape = gears.shape.circle, forced_height = 80 }, { fit = true }),
})
