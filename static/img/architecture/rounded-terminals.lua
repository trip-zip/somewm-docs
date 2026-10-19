local options = ... or {}
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local ruled = require("ruled")
local wibox = require("wibox")

assert(not _G.somewm_rounded_terminals or not _G.somewm_rounded_terminals.running,
    "Close the existing terminal demo first")
local target = awful.screen.focused()
if options.output then target = assert(output.get_by_name(options.output), "Output not found").screen end
local token = "somewm-rounded-" .. tostring({}):match("0x(%x+)")
local state = { running = true, ready = false, clients = {}, previous_tags = target.selected_tags }
_G.somewm_rounded_terminals = state
state.tag = awful.tag.add("corners", {
    screen = target,
    layout = awful.layout.suit.tile,
    master_width_factor = 0.56,
    master_count = 1,
    column_count = 1,
    gap = 14,
})

function state.stop()
    if not state.running then return end
    state.running = false
    if state.timer then state.timer:stop() end
    ruled.client.remove_rule(token)
    for _, c in ipairs(state.clients) do if c.valid then c:kill() end end
    if #target.selected_tags == 1 and state.tag.selected then
        awful.tag.viewmore(state.previous_tags, target)
    end
    local attempts = 0
    gears.timer.start_new(0.1, function()
        attempts = attempts + 1
        if #state.tag:clients() == 0 then state.tag:delete(); return false end
        return attempts < 30
    end)
end

local function decorate(c)
    state.clients[#state.clients + 1] = c
    c.shape = 16
    c.border_width = 0
    c.size_hints_honor = true
    c.animation = false
    for _, edge in ipairs({ "top", "right", "bottom" }) do
        awful.titlebar.hide(c, edge)
    end
    awful.titlebar(c, {
        position = "left",
        size = 24,
        bg_normal = "#3c3836",
        bg_focus = "#504945",
        fg_normal = beautiful.fg_normal,
        fg_focus = beautiful.fg_normal,
    }):setup {
        {
            awful.titlebar.widget.closebutton(c),
            margins = 4,
            widget = wibox.container.margin,
        },
        {
            {
                awful.titlebar.widget.titlewidget(c),
                direction = "west",
                widget = wibox.container.rotate,
            },
            halign = "center",
            valign = "center",
            widget = wibox.container.place,
        },
        nil,
        layout = wibox.layout.align.vertical,
    }
    if #state.clients == 3 then
        gears.timer.delayed_call(function()
            for i = 1, 3 do
                local ordered = {}
                for _, candidate in ipairs(client.get(target)) do
                    if candidate.class and candidate.class:sub(1, #token) == token then
                        ordered[#ordered + 1] = candidate
                    end
                end
                for _, owned in ipairs(state.clients) do
                    if owned.class == token .. "-" .. i and owned ~= ordered[i] then
                        owned:swap(ordered[i])
                    end
                end
            end
            state.ready = true
        end)
    end
end

local classes = { token .. "-1", token .. "-2", token .. "-3" }
ruled.client.append_rule {
    id = token,
    rule_any = { class = classes },
    properties = {
        screen = target, tag = state.tag, focus = false, switchtotag = false,
        floating = false, border_width = 0, shape = 16, size_hints_honor = true,
    },
    callback = decorate,
}
if options.select ~= false then state.tag:view_only() end
local bg = (beautiful.bg_normal or "#282828"):gsub("#", "")
local fg = (beautiful.fg_normal or "#ebdbb2"):gsub("#", "")
for i = 1, 3 do
    local argv = {
        "foot", "--app-id=" .. classes[i],
        "--title=" .. (options.titles and options.titles[i] or "Terminal " .. i),
        "--font=monospace:size=15",
        "--override=colors-dark.background=" .. bg,
        "--override=colors-dark.foreground=" .. fg,
        "--override=pad=12x12",
    }
    if options.commands and options.commands[i] then
        argv[#argv + 1] = "--hold"
        for _, arg in ipairs(options.commands[i]) do argv[#argv + 1] = arg end
    end
    local pid = awful.spawn(argv, false)
    if type(pid) ~= "number" then state.stop(); error(tostring(pid)) end
end
state.timer = gears.timer.start_new(600, function() state.stop(); return false end)
return "Three terminals opening on screen " .. target.index
