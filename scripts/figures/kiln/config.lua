local kiln = require("kiln")
local theme = kiln.theme
for key, value in pairs {
  bg = "#282828", bg2 = "#32302f", fg = "#ebdbb2", accent = "#83a598",
  muted = "#bdae93", titlebar = "#32302f", titlebar_focus = "#504945",
  urgent = "#d79921", close = "#cc241d", font = "Sans", font_size = 18,
} do theme[key] = value end
screen.on("added", function(s)
  for _, name in ipairs { "code", "web", "chat" } do
    tag.new { name = name, screen = s }
  end
end)
kiln.on("error", function(where, err)
  io.stderr:write("FIGURE ERROR: " .. tostring(where) .. ": " .. tostring(err) .. "\n")
end)
