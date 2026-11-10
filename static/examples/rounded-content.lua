local awful = require('awful')
local wibox = require('wibox')
local shape = require('gears.shape')

return function(c)
    local normal, focused, foreground = '#c680d5', '#65aee2', '#263446'
    c.shape = 24
    c.content_radius = 24
    c.border_width = 0

    local function update_fill()
        c.content_background_color = not c.urgent and c.active and focused or normal
    end
    c:connect_signal('property::active', update_fill)
    c:connect_signal('property::urgent', update_fill)
    update_fill()

    local function button(label, action)
        local text = wibox.widget.textbox(label)
        text.font, text.halign, text.valign = 'sans 12', 'center', 'center'
        local bg = wibox.container.background(text, '#d8e2ea')
        bg.fg = foreground
        bg.shape = function(cr, w, h) shape.rounded_rect(cr, w, h, 6) end
        bg.forced_width, bg.forced_height = 30, 28
        bg:buttons{awful.button({}, 1, action)}
        bg:connect_signal('mouse::enter', function() bg.bg = '#ffffff' end)
        bg:connect_signal('mouse::leave', function() bg.bg = '#d8e2ea' end)
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
        awful.titlebar(c, {position = side, size = side == 'top' and 48 or 12,
            bg_normal = normal, bg_focus = focused, bg_urgent = normal,
            fg_normal = foreground, fg_focus = foreground, fg_urgent = foreground}).widget = child
    end
end
