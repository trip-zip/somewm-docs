local options = ... or {}
assert(options.output, "Pass the output connector name")
local awful = require('awful')
local wibox = require('wibox')
local ruled = require('ruled')
local timer = require('gears.timer')
local shape = require('gears.shape')
assert(not _berry_border_demo, 'Berry demo is already open')
local target
for s in screen do
    if s.output and s.output.name == options.output then target = s end
end
assert(target and target.selected_tag, 'Selected screen is unavailable')
local purple, outline = '#65517f', '#bca1ff'
local wa = target.workarea
local gap, margin = 36, 48
local width = math.floor((wa.width - 2 * margin - 2 * gap) / 3)
local height = math.min(500, wa.height - 160)
local y = wa.y + math.floor((wa.height - height) / 2)
local demo = {clients = {}, outlines = {}, disconnect = {}, state = 'starting'}
_berry_border_demo = demo
local rule_id = 'berry-border-concept-demo'
local classes = {'BerryConceptSquare', 'BerryConceptInner', 'BerryConceptBoth'}
local titles = {'1. Square content', '2. Rounded content', '3. Both rounded'}
local function outer(cr, w, h)
    local r = math.min(39, w / 2, h / 2)
    local k = r * 0.5522847498
    cr:move_to(r, 0)
    cr:line_to(w - r, 0)
    cr:curve_to(w - r + k, 0, w, r - k, w, r)
    cr:line_to(w, h - r)
    cr:curve_to(w, h - r + k, w - r + k, h, w - r, h)
    cr:line_to(r, h)
    cr:curve_to(r - k, h, 0, h - r + k, 0, h - r)
    cr:line_to(0, r)
    cr:curve_to(0, r - k, r - k, 0, r, 0)
    cr:close_path()
end
function demo.stop()
    ruled.client.remove_rule(rule_id)
    if demo.timeout then demo.timeout:stop() end
    for _, disconnect in ipairs(demo.disconnect) do disconnect() end
    for _, box in ipairs(demo.outlines) do box.visible = false end
    for _, c in ipairs(demo.clients) do if c.valid then c:kill() end end
    _berry_border_demo = nil
end
local function setup(c)
    local index
    for i, class in ipairs(classes) do if c.class == class then index = i end end
    if not index then return end
    demo.clients[#demo.clients + 1] = c
    c.animation, c.shadow, c.ontop = false, false, true
    c.border_width, c.border_color = 0, purple
    c.shape = index == 3 and outer or nil
    c.content_radius = index > 1 and 27 or nil
    for _, side in ipairs{'top', 'right', 'bottom', 'left'} do
        local child
        if side == 'top' then
            child = wibox.widget.textbox(titles[index])
            child.font = 'sans 15'
            child.valign = 'center'
            child = wibox.container.margin(child, 22, 12, 0, 0)
        elseif side == 'bottom' then
            child = wibox.widget.textbox('Close demo')
            child.font, child.halign = 'sans 10', 'center'
            child:buttons{awful.button({}, 1, demo.stop)}
        end
        local bg = wibox.container.background(child, purple)
        bg.fg = '#f4f2fa'
        awful.titlebar(c, {position = side, size = side == 'top' and 63 or 21,
            bg_normal = purple, bg_focus = purple}).widget = bg
    end
    c:geometry{x = wa.x + margin + (index - 1) * (width + gap), y = y,
        width = width, height = height}
    local stroke = wibox.container.background()
    stroke.bg, stroke.border_color, stroke.border_width = '#00000000', outline, 2
    stroke.shape = index == 3 and outer or shape.rectangle
    local box = wibox{screen = target, bg = '#00000000', ontop = true,
        input_passthrough = true, visible = false, widget = stroke}
    demo.outlines[#demo.outlines + 1] = box
    local function sync()
        if not c.valid then box.visible = false; return end
        box:geometry(c:geometry())
        box.visible = c:isvisible()
    end
    c:connect_signal('property::geometry', sync)
    c:connect_signal('property::minimized', sync)
    target:connect_signal('tag::history::update', sync)
    local function disconnect()
        target:disconnect_signal('tag::history::update', sync)
    end
    demo.disconnect[#demo.disconnect + 1] = disconnect
    c:connect_signal('unmanage', function() box.visible = false; disconnect() end)
    c:raise()
    sync()
    if #demo.clients == 3 then
        ruled.client.remove_rule(rule_id)
        demo.timeout:stop()
        demo.state = 'ready'
    end
end
ruled.client.append_rule{
    id = rule_id, rule_any = {class = classes},
    properties = {screen = target, tags = {target.selected_tag}, floating = true,
        focus = false, titlebars_enabled = false, size_hints_honor = false},
    callback = setup,
}
demo.timeout = timer.start_new(12, function()
    if demo.state ~= 'ready' then demo.stop() end
    return false
end)
for _, class in ipairs(classes) do
    awful.spawn{'foot', '--app-id=' .. class, '--title=' .. class,
        '-o', 'font=monospace:size=12', '-o', 'colors-dark.background=252b3b',
        '-o', 'colors-dark.foreground=b8ddc8', '-o', 'colors-light.background=252b3b', '-o', 'colors-light.foreground=b8ddc8',
        '-o', 'pad=16x16', '/bin/sh'}
end
return 'Opening three content-radius examples on ' .. options.output
