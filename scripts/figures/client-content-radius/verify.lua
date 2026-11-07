-- Run through SomeWM's integration runner so the guide uses an isolated
-- compositor and the same Lua modules as the application.
local runner = require('_runner')
local awful = require('awful')
local ruled = require('ruled')
local utils = require('_utils')
local shot = require('_shape_mask_capture')
local filesystem = require('gears.filesystem')
local repo = assert(os.getenv('SOMEWM_DOCS_REPO'), 'Set SOMEWM_DOCS_REPO')
local function read(path)
    local f = assert(io.open(path)); local data = f:read('*a'); f:close(); return data
end
local guide = read(repo .. '/docs/guides/rounded-corners.md')
local blocks = {}
for block in guide:gmatch('```lua\n(.-)```') do blocks[#blocks + 1] = block end
assert(#blocks == 4, 'Update the verifier for changed guide examples')
local helper = filesystem.get_configuration_dir() .. 'rounded-content.lua'
local f = assert(io.open(helper, 'w'))
f:write(read(repo .. '/static/examples/rounded-content.lua')); f:close()
local c, report
local steps = {}
local function spawn()
    report = os.tmpname()
    awful.spawn{'./build-test/test-transient-client', 'firefox', report, '0', 'ff204060'}
    return true
end
local function mapped(n)
    c = utils.find_client_by_class('firefox')
    if not c then assert(n < 30, 'client did not map'); return end
    c.floating, c.shadow, c.animation = true, false, false
    c:geometry{x = 40, y = 40, width = 300, height = 220}
    return true
end
local function close()
    c:kill(); os.remove(report)
    return true
end
local function gone(n)
    if utils.find_client_by_class('firefox') then assert(n < 30, 'client did not close'); return end
    return true
end
steps[#steps + 1] = function()
    screen[1].scale = 1.5
    screen[1].selected_tag.layout = awful.layout.suit.floating
    mouse.coords{x = 0, y = 0}
    ruled.client.append_rule{id = 'earlier-shape', rule = {class = 'firefox'}, properties = {shape = 40}}
    assert(load(blocks[1], 'guide-rule'))()
    ruled.client.emit_signal('request::rules')
    return true
end
steps[#steps + 1] = spawn
steps[#steps + 1] = mapped
steps[#steps + 1] = shot.wait(function()
    assert(c.content_radius == 18 and c.shape == nil and c.border_width == 0,
        'first rule must clear an earlier shape and set the independent radius')
    ruled.client.remove_rule('earlier-shape'); ruled.client.remove_rule('rounded-content')
    assert(load('local c = ...\n' .. blocks[3], 'guide-clear'))(c)
    assert(c.content_radius == nil, 'nil did not clear the radius')
end)
steps[#steps + 1] = close
steps[#steps + 1] = gone
steps[#steps + 1] = function()
    assert(load('local ruled = require("ruled")\n' .. blocks[2], 'guide-helper'))()
    return true
end
steps[#steps + 1] = spawn
steps[#steps + 1] = mapped
shot.check_steps(steps, function()
    assert(c.content_radius == 18 and c.shape == nil and c.border_width == 0)
    for _, side in ipairs{'top', 'right', 'bottom', 'left'} do
        local _, size = c['titlebar_' .. side](c)
        assert(size == (side == 'top' and 48 or 12), 'helper titlebar size: ' .. side)
    end
    return {{52, 88, '#65517f'}, {327, 88, '#65517f'},
        {52, 247, '#65517f'}, {327, 247, '#65517f'},
        {70, 106, '#204060'}, {309, 229, '#204060'}}
end)
steps[#steps + 1] = function()
    ruled.client.remove_rule('rounded-content-frame')
    return close()
end
steps[#steps + 1] = gone
steps[#steps + 1] = function()
    assert(load(blocks[4], 'guide-shape-rule'))()
    ruled.client.emit_signal('request::rules')
    ruled.client.remove_rule('rounded-content')
    return true
end
steps[#steps + 1] = spawn
steps[#steps + 1] = mapped
steps[#steps + 1] = shot.wait(function()
    assert(type(c.shape) == 'function' and c.border_width == 0)
    for command in guide:gmatch("somewm%-client eval '(.-)'") do
        c.content_radius = 18
        assert(load(command, 'guide-eval'))()
        assert(c.content_radius == nil, 'guide shell example left independent rounding enabled')
    end
    assert(c.shape == nil, 'guide shell examples did not reset the shape')
    io.stderr:write('[PASS] guide rules, helper pixels at scale 1.5, nil reset and shell examples\n')
end)
steps[#steps + 1] = function()
    close(); os.remove(helper); return true
end
runner.run_steps(steps, {kill_clients = false})
