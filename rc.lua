pcall(require, "luarocks.loader")

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")

local wibox = require("wibox")

local beautiful = require("beautiful")

local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

require("awful.hotkeys_popup.keys")
volume_slider = nil

local sink_name = "alsa_output.pci-0000_00_1f.3.analog-stereo"
volume_slider = wibox.widget({
	max_value = 100,
	value = 50,
	forced_width = 150,
	widget = wibox.widget.progressbar,
	shape = gears.shape.rounded_bar,
	border_color = "#ebdbb2",
	border_width = 2,
	background_color = "#282828",
	color = "#ebdbb2",
})

local function update_volume()
	awful.spawn.easy_async_with_shell(
		"pactl get-sink-volume " .. sink_name .. " | head -1 | grep -o '[0-9]*%' | head -1",
		function(stdout)
			local vol = tonumber(stdout:match("(%d?%d?%d)%%"))
			if vol and volume_slider then
				volume_slider.value = vol
			end
		end
	)
end

volume_slider:connect_signal("button::press", function(_, _, _, button)
	local vol = volume_slider.value

	volume_slider.value = vol
	awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ " .. vol .. "%")
end)

update_volume()

-- Error handling

if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end

do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		if in_error then
			return
		end
		in_error = true
		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err),
		})
		in_error = false
	end)
end

-- Variables
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

terminal = "kitty"
editor = "nvim"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"

awful.layout.layouts = {
	awful.layout.suit.floating,
	awful.layout.suit.tile,
	awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.tile.top,
	awful.layout.suit.fair,
	awful.layout.suit.fair.horizontal,
	awful.layout.suit.spiral,
	awful.layout.suit.spiral.dwindle,
	awful.layout.suit.max,
	awful.layout.suit.max.fullscreen,
	awful.layout.suit.magnifier,
	awful.layout.suit.corner.nw,
}

myawesomemenu = {
	{
		"hotkeys",
		function()
			hotkeys_popup.show_help(nil, awful.screen.focused())
		end,
	},
	{ "manual", terminal .. " -e man awesome" },
	{ "edit config", editor_cmd .. " " .. awesome.conffile },
	{ "restart", awesome.restart },
	{
		"quit",
		function()
			awesome.quit()
		end,
	},
}

mymainmenu = awful.menu({
	items = {
		{ "awesome", myawesomemenu, beautiful.awesome_icon },
		{ "open terminal", terminal },
	},
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

menubar.utils.terminal = terminal
mykeyboardlayout = awful.widget.keyboardlayout()

mytextclock = wibox.widget.textclock()

local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({}, 4, function(t)
		awful.tag.viewnext(t.screen)
	end),
	awful.button({}, 5, function(t)
		awful.tag.viewprev(t.screen)
	end)
)

local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal("request::activate", "tasklist", { raise = true })
		end
	end),
	awful.button({}, 3, function()
		awful.menu.client_list({ theme = { width = 250 } })
	end),
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end)
)

beautiful.wallpaper = function(s)
	local f = io.open(os.getenv("HOME") .. "/.wallpaper", "r")
	if f then
		local path = f:read("*l")
		f:close()
		return path
	end
end

local function set_wallpaper(s)
	local wallpaper = beautiful.wallpaper and beautiful.wallpaper(s)
	if wallpaper then
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end

screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	set_wallpaper(s)

	-- layout setup
	local layout_for_screen = awful.layout.suit.floating
	if s.index == 2 then
		layout_for_screen = awful.layout.suit.fair.horizontal
	end

	local tags = awful.tag({ "1" }, s, layout_for_screen)
	tags[1]:view_only()

	s.mytaglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = taglist_buttons,
		widget_template = {
			{ id = "text_role", widget = wibox.widget.textbox, visible = false },
			id = "background_role",
			widget = wibox.container.background,
		},
	})

	s.mytasklist = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
		widget_template = {
			{
				{
					id = "icon_role",
					widget = wibox.widget.imagebox,
					forced_width = 20,
					forced_height = 20,
					resize = true,
				},
				margins = 4,
				widget = wibox.container.margin,
			},
			id = "background_role",
			widget = wibox.container.background,
			create_callback = function(self, c, index, objects)
				self:connect_signal("button::press", function()
					client.focus = c
					c:raise()
				end)
			end,
		},
	})

	-- volume slider
	volume_slider.forced_width = 80 -- mniejszy w pasku

	local function update_volume_screen()
		awful.spawn.easy_async_with_shell(
			"pactl get-sink-volume " .. sink_name .. " | head -1 | grep -o '[0-9]*%' | head -1",
			function(stdout)
				local vol = tonumber(stdout:match("(%d?%d?%d)%%"))
				if vol and volume_slider then
					volume_slider.value = vol
				end
			end
		)
	end

	volume_slider:connect_signal("property::value", function()
		local vol = math.floor(volume_slider.value)
		awful.spawn("pactl set-sink-volume " .. sink_name .. " " .. vol .. "%")
	end)

	update_volume_screen()

	-- clock
	if s.index == 1 then
		local mytextclock = wibox.widget.textclock("%H:%M")
		mytextclock.font = "azukifontLB 8"

		s.mywibox = awful.wibar({
			position = "top",
			screen = s,
			bg = "#282828",
			fg = "#ebdbb2",
			height = 28,
		})

		s.mywibox:setup({
			layout = wibox.layout.align.horizontal,
			{ -- left
				layout = wibox.layout.fixed.horizontal,
				s.mytaglist,
				s.mytasklist,
			},
			nil,
			{ -- right
				layout = wibox.layout.fixed.horizontal,
				wibox.container.margin(volume_slider, 8, 8, 9, 9),
				wibox.container.margin(mytextclock, 5, 10, 0, 0),
			},
		})
	else
		if s.mywibox then
			s.mywibox.visible = false
		end
	end
end)

-- {{{ Mouse bindings
root.buttons(gears.table.join(
	awful.button({}, 3, function()
		mymainmenu:toggle()
	end),
	awful.button({}, 4, awful.tag.viewnext),
	awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
	awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
	awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
	awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
	awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),

	awful.key({ modkey }, "j", function()
		awful.client.focus.byidx(1)
	end, { description = "focus next by index", group = "client" }),
	awful.key({ modkey }, "k", function()
		awful.client.focus.byidx(-1)
	end, { description = "focus previous by index", group = "client" }),
	awful.key({ modkey }, "w", function()
		mymainmenu:show()
	end, { description = "show main menu", group = "awesome" }),

	-- Layout manipulation
	awful.key({ modkey, "Shift" }, "j", function()
		awful.client.swap.byidx(1)
	end, { description = "swap with next client by index", group = "client" }),
	awful.key({ modkey, "Shift" }, "k", function()
		awful.client.swap.byidx(-1)
	end, { description = "swap with previous client by index", group = "client" }),
	awful.key({ modkey, "Control" }, "j", function()
		awful.screen.focus_relative(1)
	end, { description = "focus the next screen", group = "screen" }),
	awful.key({ modkey, "Control" }, "k", function()
		awful.screen.focus_relative(-1)
	end, { description = "focus the previous screen", group = "screen" }),
	awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),

	awful.key({ "Mod4", "Shift" }, "s", function()
		awful.spawn.with_shell("/usr/bin/maim -s -u | /usr/bin/xclip -selection clipboard -t image/png")
	end, { description = "screenshot to clipboard", group = "screenshot" }),

	-- volume up
	awful.key({}, "XF86AudioRaiseVolume", function()
		awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")
		update_volume()
	end, { description = "volume up", group = "media" }),

	-- volume down
	awful.key({}, "XF86AudioLowerVolume", function()
		awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")
		update_volume()
	end, { description = "volume down", group = "media" }),

	awful.key({ "Mod1" }, ".", function()
		awful.spawn("rofi -modi emoji -show emoji -emoji-format '{emoji}  {name}'")
	end, { description = "uruchom rofi z emotkami", group = "custom" }),

	-- Standard program
	awful.key({ modkey }, "Return", function()
		awful.spawn(terminal)
	end, { description = "open a terminal", group = "launcher" }),
	awful.key({ modkey, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
	awful.key({ modkey, "Shift" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),

	awful.key({ modkey }, "l", function()
		awful.tag.incmwfact(0.05)
	end, { description = "increase master width factor", group = "layout" }),
	awful.key({ modkey }, "h", function()
		awful.tag.incmwfact(-0.05)
	end, { description = "decrease master width factor", group = "layout" }),
	awful.key({ modkey, "Shift" }, "h", function()
		awful.tag.incnmaster(1, nil, true)
	end, { description = "increase the number of master clients", group = "layout" }),
	awful.key({ modkey, "Shift" }, "l", function()
		awful.tag.incnmaster(-1, nil, true)
	end, { description = "decrease the number of master clients", group = "layout" }),
	awful.key({ modkey, "Control" }, "h", function()
		awful.tag.incncol(1, nil, true)
	end, { description = "increase the number of columns", group = "layout" }),
	awful.key({ modkey, "Control" }, "l", function()
		awful.tag.incncol(-1, nil, true)
	end, { description = "decrease the number of columns", group = "layout" }),
	awful.key({ modkey }, "space", function()
		awful.layout.inc(1)
	end, { description = "select next", group = "layout" }),
	awful.key({ modkey, "Shift" }, "space", function()
		awful.layout.inc(-1)
	end, { description = "select previous", group = "layout" }),

	awful.key({ modkey, "Control" }, "n", function()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			c:emit_signal("request::activate", "key.unminimize", { raise = true })
		end
	end, { description = "restore minimized", group = "client" }),

	-- Prompt
	-- awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
	--           {description = "run prompt", group = "launcher"}),

	-- zmiana

	awful.key({ modkey }, "r", function()
		awful.spawn("rofi -show drun")
	end, { description = "rofi: run app", group = "launcher" }),

	awful.key({ modkey }, "x", function()
		awful.prompt.run({
			prompt = "Run Lua code: ",
			textbox = awful.screen.focused().mypromptbox.widget,
			exe_callback = awful.util.eval,
			history_path = awful.util.get_cache_dir() .. "/history_eval",
		})
	end, { description = "lua execute prompt", group = "awesome" })
	-- Menubar
	-- awful.key({ modkey },
	-- "p", function() menubar.show() end,
	--           {description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
	awful.key({ modkey }, "f", function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, { description = "toggle fullscreen", group = "client" }),
	awful.key({ modkey, "Shift" }, "c", function(c)
		c:kill()
	end, { description = "close", group = "client" }),
	awful.key(
		{ modkey, "Control" },
		"space",
		awful.client.floating.toggle,
		{ description = "toggle floating", group = "client" }
	),
	awful.key({ modkey, "Control" }, "Return", function(c)
		c:swap(awful.client.getmaster())
	end, { description = "move to master", group = "client" }),
	awful.key({ modkey }, "o", function(c)
		c:move_to_screen()
	end, { description = "move to screen", group = "client" }),
	awful.key({ modkey }, "t", function(c)
		c.ontop = not c.ontop
	end, { description = "toggle keep on top", group = "client" }),
	awful.key({ modkey }, "n", function(c)
		-- The client currently has the input focus, so it cannot be
		-- minimized, since minimized clients can't have the focus.
		c.minimized = true
	end, { description = "minimize", group = "client" }),
	awful.key({ modkey }, "m", function(c)
		c.maximized = not c.maximized
		c:raise()
	end, { description = "(un)maximize", group = "client" }),
	awful.key({ modkey, "Control" }, "m", function(c)
		c.maximized_vertical = not c.maximized_vertical
		c:raise()
	end, { description = "(un)maximize vertically", group = "client" }),
	awful.key({ modkey, "Shift" }, "m", function(c)
		c.maximized_horizontal = not c.maximized_horizontal
		c:raise()
	end, { description = "(un)maximize horizontally", group = "client" }),
	awful.key({ modkey }, "Tab", function()
		awful.spawn("rofi -show window")
	end, { description = "window switcher", group = "launcher" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = gears.table.join(
		globalkeys,
		-- View tag only.
		awful.key({ modkey }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end, { description = "view tag #" .. i, group = "tag" }),
		-- Toggle tag display.
		awful.key({ modkey, "Control" }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end, { description = "toggle tag #" .. i, group = "tag" }),
		-- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end, { description = "move focused client to tag #" .. i, group = "tag" }),
		-- Toggle tag on focused client.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end, { description = "toggle focused client on tag #" .. i, group = "tag" })
	)
end

clientbuttons = gears.table.join(
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
	end),

	clientbuttons or {},
	awful.button({ modkey }, 4, function(c) -- scroll up
		c.maximized = true
		c:raise()
	end),
	awful.button({ modkey }, 5, function(c) -- scroll down
		c.minimized = true
	end),
	awful.button({ modkey }, 2, function(c) -- scroll click
		c:kill()
	end),
	awful.button({ modkey }, 1, function(c) -- mod + left click (drag) - unmaximize
		if c.maximized then
			c.maximized = false
		end
	end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		},
	},

	-- Floating clients.
	{
		rule_any = {
			instance = {
				"DTA", -- Firefox addon DownThemAll.
				"copyq", -- Includes session name in class.
				"pinentry",
			},
			class = {
				"Arandr",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"MessageWin", -- kalarm.
				"Sxiv",
				"Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
				"Wpa_gui",
				"veromix",
				"xtightvncviewer",
			},

			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {
				"Event Tester", -- xev.
			},
			role = {
				"AlarmWindow", -- Thunderbird's calendar.
				"ConfigManager", -- Thunderbird's about:config.
				"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
			},
		},
		properties = { floating = true },
	},

	-- Add titlebars to normal clients and dialogs
	{ rule_any = { type = { "normal", "dialog" } }, properties = { titlebars_enabled = true } },

	-- Set Firefox to always map on the tag named "2" on screen 1.
	-- { rule = { class = "Firefox" },
	--   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c) end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)
client.connect_signal("property::maximized", function(c)
	if c.maximized then
		c.border_width = 0
	else
		-- Przywraca standardową szerokość ramki, gdy okno nie jest zmaksymalizowane
		c.border_width = beautiful.border_width
	end
end)
-- }}}

-- sudocode shortcut
-- awful.spawn.with_shell([[
--   if [ ! -f /usr/local/bin/sudocode ]; then
--     sudo tee /usr/local/bin/sudocode > /dev/null <<'EOF'
-- #!/bin/bash
-- xhost +SI:localuser:root
-- sudo /usr/bin/code --no-sandbox --user-data-dir=/root/.vscode-root "$@"
-- EOF
--     sudo chmod +x /usr/local/bin/sudocode
--   fi
-- ]])

awful.util.spawn("xsetroot -cursor_name macOS")

awful.util.spawn("xmousepasteblock")

awful.spawn.with_shell("nice -n -10 picom --glx-no-stencil --config ~/.config/picom/picom.conf")

client.connect_signal("property::geometry", function(c)
	local geo = c:geometry()

	if geo.x > 1080 and not c.size_fixed then
		c:geometry({
			width = 960,
			height = 540,
			x = geo.x,
			y = geo.y,
		})
		c.size_fixed = true
	elseif geo.x <= 1080 and c.size_fixed then
		c.size_fixed = false
	end
end)

client.connect_signal("request::default_mousebindings", function()
	awful.mouse.append_client_mousebindings({
		awful.button({ modkey }, 4, function(c) -- scroll w górę
			c.maximized = true
			c:raise()
		end),
		awful.button({ modkey }, 5, function(c) -- scroll w dół
			c.minimized = true
		end),
		awful.button({ modkey }, 2, function(c) -- środkowy przycisk (scroll klik)
			c:kill()
		end),
		awful.key({ modkey }, "w", function(c)
			c:kill()
		end),
		awful.button({ modkey }, 1, function(c) -- mod + klik i ruch = zdemaksymalizuj
			if c.maximized then
				c.maximized = false21
			end
		end),
	})
end)

beautiful.border_width = 3
beautiful.border_normal = "#7c6f64"
beautiful.border_focus = "#3c3836"

awesome.connect_signal("wallpaper::changed", function()
	for s in screen do
		local wallpaper
		if s == screen.primary then
			-- główny ekran: dynamiczna tapeta
			local wp_func = beautiful.wallpaper
			wallpaper = type(wp_func) == "function" and wp_func(s) or wp_func
		else
			-- drugi ekran: stała tapeta
			wallpaper = os.getenv("HOME") .. "/wallpapers/black.png"
		end

		if wallpaper then
			gears.wallpaper.maximized(wallpaper, s, true)
		end
	end
end)

gears.wallpaper.maximized(os.getenv("HOME") .. "/wallpapers/black.png", screen[2], true)

awful.spawn.with_shell("setsid cliphist store >/dev/null 2>&1 &")
