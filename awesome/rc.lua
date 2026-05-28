pcall(require, "luarocks.loader")
require("awful.autofocus")
require("awful.hotkeys_popup.keys")
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")

local autostart_cmds = {
    "skippy-xd --start-daemon",
    "nitrogen --restore",
    "wal -R",
    "xmousepasteblock &",
    "picom &",
    "unclutter -idle 5 -root",
    "setxkbmap pl",
    "zen-browser",
    "discord",
    "tidal-hifi",
    "polybar &",
}

for _, cmd in ipairs(autostart_cmds) do
    awful.spawn.with_shell(cmd)
end

local terminal = "kitty"
local editor = "nvim"
local modkey = "Mod4"

local wal_colors = {}
pcall(function()
    local i = 0
    for line in io.lines(os.getenv("HOME") .. "/.cache/wal/colors") do
        line = line:gsub("\n", "")
        if i == 0 then
            wal_colors.background = line
        end
        if i == 7 then
            wal_colors.foreground = line
        end
        if i <= 15 then
            wal_colors["color" .. i] = line
        end
        i = i + 1
    end
end)

beautiful.init({
    bg_normal = wal_colors.background,
    fg_normal = wal_colors.color1,
    border_width = 3,
    border_normal = wal_colors.color0,
    border_focus = wal_colors.color1,
    useless_gap = 30,
})

naughty.config.defaults.timeout = 5
naughty.config.defaults.border_width = 3
naughty.config.defaults.position = "top_right"
naughty.config.defaults.padding = 20
naughty.config.defaults.margin = 30
naughty.config.defaults.spacing = 15
naughty.config.defaults.max_width = 500
naughty.config.defaults.border_color = wal_colors.color1
naughty.config.defaults.bg = wal_colors.background
naughty.config.defaults.fg = wal_colors.foreground
naughty.config.defaults.font = "Iosevka Semibold 11.5"


local function place_window_under_cursor(client_window, target_width, target_height)
    local mouse_coords = mouse.coords()
    local screen_geometry = mouse.screen.geometry
    local margin = 30
    local polybar_height = 21
    local top_margin = margin + polybar_height

    local new_x = mouse_coords.x - target_width / 2
    local new_y = mouse_coords.y - target_height / 2

    if new_x < screen_geometry.x + margin then
        new_x = screen_geometry.x + margin
    end

    if new_y < screen_geometry.y + top_margin then
        new_y = screen_geometry.y + top_margin
    end

    if new_x + target_width > screen_geometry.x + screen_geometry.width - margin then
        new_x = screen_geometry.x + screen_geometry.width - target_width - margin
    end

    if new_y + target_height > screen_geometry.y + screen_geometry.height - margin then
        new_y = screen_geometry.y + screen_geometry.height - target_height - margin
    end

    client_window:geometry({
        x = new_x,
        y = new_y,
        width = target_width,
        height = target_height,
    })
end

awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.floating,
}

awful.screen.connect_for_each_screen(function(s)
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
end)
local globalkeys = gears.table.join(
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift" }, "s", function()
        awful.spawn.with_shell("/usr/bin/maim -s -u | /usr/bin/xclip -selection clipboard -t image/png")
    end),
    awful.key({ modkey, "Control" }, "s", function()
        awful.spawn.with_shell(
            'maim -s -u "$HOME/Pictures/screenshots/$(date +%Y-%m-%d_%H-%M-%S).png" && notify-send "Screenshot saved"'
        )
    end),
    awful.key({ modkey }, ".", function()
        awful.spawn("emoji-picker/src-tauri/target/release/emoji-picker --class emoji-picker")
    end, { description = "open emoji picker  under cursor", group = "launcher" }),

    awful.key({ modkey }, "c", function()
        awful.spawn("kitty --class calc --hold /home/user/bin/calc")
    end, { description = "open floating calc under cursor", group = "launcher" }),
    awful.key({ modkey }, "Tab", function()
        awful.spawn("skippy-xd --expose")
    end),
    awful.key({ modkey }, "Return", function()
        awful.spawn(terminal)
    end),
    awful.key({ modkey }, "n", function()
        awful.spawn(terminal .. " -e nvim")
    end),
    awful.key({ modkey }, "r", function()
        awful.spawn("rofi -show drun")
    end)
)

local clientkeys = gears.table.join(
    awful.key({ modkey }, "h", function()
        local client_window = client.focus
        if not client_window then
            return
        end

        if not client_window.floating then
            awful.client.focus.bydirection("left")
        end
    end),
    awful.key({ modkey }, "j", function()
        local client_window = client.focus
        if not client_window then
            return
        end

        if not client_window.floating then
            awful.client.focus.bydirection("down")
        end
    end),
    awful.key({ modkey }, "k", function()
        local client_window = client.focus
        if not client_window then
            return
        end

        if not client_window.floating then
            awful.client.focus.bydirection("up")
        end
    end),
    awful.key({ modkey }, "l", function()
        local client_window = client.focus
        if not client_window then
            return
        end

        if not client_window.floating then
            awful.client.focus.bydirection("right")
        end
    end),

    awful.key({ modkey, "Shift" }, "Left", function()
        awful.client.swap.bydirection("left")
    end),
    awful.key({ modkey, "Shift" }, "Down", function()
        awful.client.swap.bydirection("down")
    end),
    awful.key({ modkey, "Shift" }, "Up", function()
        awful.client.swap.bydirection("up")
    end),
    awful.key({ modkey, "Shift" }, "Right", function()
        awful.client.swap.bydirection("right")
    end),

    awful.key({ modkey }, "Left", function()
        awful.tag.incmwfact(-0.05)
    end),
    awful.key({ modkey }, "Right", function()
        awful.tag.incmwfact(0.05)
    end),
    awful.key({ modkey }, "Down", function()
        awful.client.incwfact(0.05)
    end),
    awful.key({ modkey }, "Up", function()
        awful.client.incwfact(-0.05)
    end),

    awful.key({ modkey }, "f", function(c)
        c.maximized = false
        c.maximized_horizontal = false
        c.maximized_vertical = false
        c.fullscreen = false
        c.floating = not c.floating
        c:raise()
        place_window_under_cursor(c, 960, 600)
    end),
    awful.key({ modkey, "Shift" }, "m", function(c)
        c.fullscreen = not c.fullscreen
        c:raise()
    end),
    awful.key({ modkey }, "m", function(c)
        c.maximized = not c.maximized
        c:raise()
    end),
    awful.key({ modkey }, "q", function(c)
        c:kill()
    end),
    awful.key({ modkey }, "t", function(c)
        c.ontop = not c.ontop
        c:raise()
    end)
-- awful.key({ modkey }, "i", function()
--     local c = client.focus
--     if not c then
--         return
--     end
--     local s = awful.screen.focused()
--     local t = s.selected_tag
--     local layout_name = t and awful.layout.getname(t.layout) or "nil"
--     local tag_names = {}
--     for _, tag in ipairs(c:tags()) do
--         table.insert(tag_names, tag.name or "nil")
--     end
--     local tags_str = #tag_names > 0 and table.concat(tag_names, ", ") or "none"
--     local text = string.format(
--         "Name: %s\nClass: %s\nFloating: %s\nMaximized: %s\nFullscreen: %s\nOntop: %s\nTags: %s\nLayout: %s",
--         c.name or "nil",
--         c.class or "nil",
--         tostring(c.floating),
--         tostring(c.maximized),
--         tostring(c.fullscreen),
--         tostring(c.ontop),
--         tags_str,
--         layout_name
--     )
--     naughty.notify({ title = "Client Info", text = text })
-- end)
)

for i = 1, 9 do
    globalkeys = gears.table.join(
        globalkeys,
        awful.key({ modkey }, "#" .. (9 + i), function()
            local tag = awful.screen.focused().tags[i]
            if tag then
                tag:view_only()
            end
        end),
        awful.key({ modkey, "Shift" }, "#" .. (9 + i), function()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end)
    )
end

local clientbuttons = gears.table.join(
    awful.button({}, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
    end),
    awful.button({ modkey }, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.resize(c)
    end)
)

root.keys(globalkeys)

awful.rules.rules = {
    {
        rule = {},
        properties = {
            keys = clientkeys,
            buttons = clientbuttons,
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen,
            titlebars_enabled = true,
        },
    },
    {
        rule = { class = "tidal-hifi" },
        properties = {
            tag = "4",
        },
    },
    {
        rule = { class = "discord" },
        properties = {
            tag = "3",
        },
    },

    {
        rule = { class = "zen" },
        properties = {
            tag = "2",
        },
    },
    {
        rule = { class = "Polybar" },
        properties = { focusable = false, border_width = 0, floating = true, skip_taskbar = true },
    },
}

client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)


client.connect_signal("manage", function(c)
    if c.class == "calc" then
        c.floating = true
        c.ontop = true
        c.border_color = wal_colors.color3
        place_window_under_cursor(c, 300, 400)
    end
end)

client.connect_signal("manage", function(c)
    if c.class == "Emoji-picker" then
        c.floating = true
        c.ontop = true
        c.border_color = wal_colors.color1
        place_window_under_cursor(c, 310, 420)

        c:connect_signal("mouse::leave", function()
            c:kill()
        end)
    end
end)


local function update_border(c)
    if c.class == "Polybar" then
        c.border_width = 0
        return
    end
    if c.ontop then
        c.border_color = wal_colors.color3
        c.border_width = 3
    else
        c.border_color = c == client.focus and beautiful.border_focus or beautiful.border_normal
        c.border_width = c.maximized and 0 or beautiful.border_width
    end
end

client.connect_signal("focus", update_border)
client.connect_signal("unfocus", update_border)
client.connect_signal("property::maximized", update_border)

tag.connect_signal("property::selected", function(t)
    for _, c in pairs(t:clients()) do
        update_border(c)
    end
end)

client.connect_signal("manage", function(c)
    local name = (c.class or ""):lower()
    for app, tag_index in pairs(apps_to_tags) do
        if name:find(app) then
            local tag = awful.screen.focused().tags[tag_index]
            if tag then
                c:move_to_tag(tag)
            end
            break
        end
    end
end)
