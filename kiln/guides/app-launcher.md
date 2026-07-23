---
title: App Launcher
description: Build a .desktop application launcher on the stdlib menu, with icons and activation tokens.
sidebar_position: 13
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# App Launcher

<YouWillLearn>

- Finding `.desktop` files under the XDG application directories
- Parsing Name, Exec, and Icon with plain Lua
- Resolving icons with `some.icon.path`
- Presenting the list with `some.menu.show` and launching with `some.spawn_with_token`

</YouWillLearn>

Snippets assume the standard config preamble:

```lua
local some = require("somewm")
local ui, key = some.ui, some.key
local th = some.theme
```

An application launcher is a menu of every installed `.desktop` entry, where picking a row spawns its command. kiln does not ship one as a module; you build it from the stdlib menu plus a directory scan and a file parse, both plain Lua. The one launcher-specific ingredient is `some.spawn_with_token(cmd)`: it launches the command with an XDG activation token, so the app you asked for arrives able to focus itself.

## Step 1: find the application directories

Applications live as `.desktop` files under `$XDG_DATA_HOME/applications` and each entry of `$XDG_DATA_DIRS`, with the standard defaults when the variables are unset:

```lua
local function app_dirs()
  local home = os.getenv("HOME") or ""
  local data_home = os.getenv("XDG_DATA_HOME")
  if data_home == nil or data_home == "" then
    data_home = home .. "/.local/share"
  end
  local dirs_env = os.getenv("XDG_DATA_DIRS")
  if dirs_env == nil or dirs_env == "" then
    dirs_env = "/usr/local/share:/usr/share"
  end
  local dirs = { data_home }
  for d in (dirs_env .. ":"):gmatch("([^:]*):") do
    if d ~= "" then dirs[#dirs + 1] = d end
  end
  for i, d in ipairs(dirs) do
    dirs[i] = d .. "/applications"
  end
  return dirs
end
```

Lua's standard library has no directory listing, so the one place this recipe shells out is `ls`:

```lua
local function desktops(dir)
  local out = {}
  local p = io.popen('ls -1 "' .. dir .. '" 2>/dev/null')
  if p == nil then return out end
  for line in p:lines() do
    if line:match("%.desktop$") then
      out[#out + 1] = dir .. "/" .. line
    end
  end
  p:close()
  return out
end
```

## Step 2: parse an entry

A `.desktop` file is an ini file with groups. The launcher wants `Name`, `Exec`, and `Icon` from the `[Desktop Entry]` group, and it skips entries the format says never to show: `NoDisplay`, `Hidden`, and any `Type` other than `Application`. `Exec` carries field codes (`%u`, `%F`, ...) that stand for files the user picked, meaningless for a bare launch, so strip them; `%%` means a literal percent:

```lua
local function parse_desktop(path)
  local f = io.open(path, "r")
  if f == nil then return nil end
  local entry, name, exec, icon, show = false, nil, nil, nil, true
  for line in f:lines() do
    local head = line:match("^%[(.-)%]$")
    if head ~= nil then
      entry = head == "Desktop Entry"
    elseif entry then
      local k, v = line:match("^([%w-]+)%s*=%s*(.*)$")
      if k == "Name" and name == nil then
        name = v
      elseif k == "Exec" then
        exec = v
      elseif k == "Icon" then
        icon = v
      elseif k == "Type" and v ~= "Application" then
        show = false
      elseif (k == "NoDisplay" or k == "Hidden") and v == "true" then
        show = false
      end
    end
  end
  f:close()
  if not show or name == nil or exec == nil then return nil end
  exec = exec:gsub("%%(.)", function(c)
    return c == "%" and "%" or ""
  end)
  return { name = name, exec = (exec:gsub("%s+$", "")), icon = icon }
end
```

Matching keys as `^([%w-]+)` drops the localized `Name[de]` variants and keeps the base `Name`, which is all the localization this recipe does.

## Step 3: build the menu rows

Walk the directories with first-name-wins on a basename clash (so your `~/.local/share` override shadows the system copy), sort by name, and turn each entry into a `{ label, action }` menu item. `some.icon.path(name)` resolves an icon name to a file path (or nil), and a menu item takes the result as `icon`:

```lua
local function menubar_items()
  local seen, apps = {}, {}
  for _, dir in ipairs(app_dirs()) do
    for _, path in ipairs(desktops(dir)) do
      local base = path:match("([^/]+)$")
      if not seen[base] then
        seen[base] = true
        local a = parse_desktop(path)
        if a ~= nil then apps[#apps + 1] = a end
      end
    end
  end
  table.sort(apps, function(x, y)
    return x.name:lower() < y.name:lower()
  end)
  local items = {}
  for _, a in ipairs(apps) do
    items[#items + 1] = { a.name, function()
      some.spawn_with_token(a.exec)
    end, icon = a.icon ~= nil and some.icon.path(a.icon) or nil }
  end
  return items
end
```

The action is the point of the recipe: `some.spawn_with_token` mints an activation token for the child, so the app opens focused. The user asked for the window; the window gets the seat.

:::note
`some.icon.path` is a bounded lookup: the app's own `Icon=` line, then hicolor at common sizes, then pixmaps. It does not walk icon-theme inheritance chains, so a name only your GTK theme ships may resolve to nil. Menu rows render fine without an icon.
:::

## Step 4: open it

From a bar button, or a keybinding, or both. The scan runs on open, not per frame, so the menu is always current against what is installed, with nothing cached to go stale:

```lua
ui.box({
  id = "apps-btn", color = th.accent, radius = 4,
  pad = { x = 8 }, align = "center",
  on_press = function()
    some.menu.show { under = "apps-btn", screen = s,
      items = menubar_items() }
  end,
}, function() ui.text("apps", { color = th.bg, size = 12 }) end)
```

```lua
key { mods = { "mod" }, key = "p", desc = "show the menubar", group = "launcher",
  press = function()
    local s = screen.focused
    some.menu.show { under = "apps-btn", screen = s, items = menubar_items() }
  end }
```

Dismissal, nesting, and press dispatch all come from the stdlib menu; this recipe only supplies the rows. Install an app and it appears on the next open; uninstall one and it is gone.

:::tip
Prefer typing to clicking? `some.prompt.run` with `some.prompt.completion` over the same list gives you a keyboard launcher instead: feed it the app names, look up the `exec` for the completed name in `done`. The scan and parse above are reusable as-is.
:::

## See also

- [Menus](/kiln/guides/menus)
- [Spawn lifecycle](/kiln/guides/spawn-lifecycle), including what activation tokens do for focus
- [some reference](/kiln/reference/some)
- [Client rules](/kiln/guides/client-rules), for routing launched apps to tags
