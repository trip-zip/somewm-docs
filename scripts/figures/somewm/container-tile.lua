-- wibox.container.tile: draws its child once in SomeWM.
return F.scene("wibox.container.tile", "One copy of the child; tiling is not applied", {
    F.row('tiled = true (one copy drawn)', { F.block(80, 24, F.blue, "child"), widget = wibox.container.tile }, { h = 72 }),
})
