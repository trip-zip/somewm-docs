local awful = require('awful')
local wibox = require('wibox')
local shape = require('gears.shape')

return function(c)
    local frame, foreground = '#65517f', '#f4f2fa'
    c.shape = nil
    c.content_radius = 18
    c.border_width, c.border_color = 0, frame

    local function button(label, action)
        local text = wibox.widget.textbox(label)
        text.font, text.halign, text.valign = 'sans 12', 'center', 'center'
        local bg = wibox.container.background(text, '#796291')
        bg.fg = foreground
        bg.shape = function(cr, w, h) shape.rounded_rect(cr, w, h, 6) end
        bg.forced_width, bg.forced_height = 30, 28
        bg:buttons{awful.button({}, 1, action)}
        bg:connect_signal('mouse::enter', function() bg.bg = '#9579b1' end)
        bg:connect_signal('mouse::leave', function() bg.bg = '#796291' end)
        return wibox.container.place(bg, 'center', 'center')
    end

    local title = awful.titlebar.widget.titlewidget(c)
    title.font, title.halign = 'sans 12', 'left'
    title:buttons{
        awful.button({}, 1, function()
            c:emit_signal('request::activate', 'titlebar', {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({}, 3, function()
            c:emit_signal('request::activate', 'titlebar', {raise = true})
            awful.mouse.client.resize(c)
        end),
    }
    local controls = wibox.layout.fixed.horizontal()
    controls.spacing = 8
    controls:add(button('−', function() c.minimized = true end),
        button('□', function() c.maximized = not c.maximized end),
        button('×', function() c:kill() end))
    local row = wibox.layout.align.horizontal()
    row:set_middle(title)
    row:set_right(controls)
    for _, side in ipairs{'top', 'right', 'bottom', 'left'} do
        local child = side == 'top' and wibox.container.margin(row, 16, 12, 0, 0) or nil
        local bg = wibox.container.background(child, frame)
        bg.fg = foreground
        awful.titlebar(c, {position = side, size = side == 'top' and 48 or 12,
            bg_normal = frame, bg_focus = frame, bg_urgent = frame}).widget = bg
    end
end
