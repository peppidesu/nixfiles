local terminal = "kitty"
local fileManager = "nautilus -w"
local menu = "anyrun"
local browser = "thorium-browser"
local mainMod = "SUPER"
require("hw")

hl.on("hyprland.start", function()
    hl.exec_cmd("dunst")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("waybar")
    hl.exec_cmd("hypridle")

    hl.exec_cmd("sleep 1 && hyprpm reload")

    -- Cursor theme
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 24")

    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/playerctl-inhibit.sh")

    -- Polkit agent
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

    -- Screenshare fix
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- syshud
    hl.exec_cmd("syshud")

    -- jellyfin mpv shim
    hl.exec_cmd("jellyfin-mpv-shim")

    hl.exec_cmd("anyrun daemon")

    -- Launch dims/ops are done inside hl.bind as [workspace 2 silent] -- see below
    hl.exec_cmd("[workspace 2 silent] discord")
end)
hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "altgr-intl",
		kb_options = "caps:hyper",
		follow_mouse = 1,
		sensitivity = 0.0,
		accel_profile = "adaptive",

		touchpad = {
			natural_scroll = true,
			scroll_factor = 0.78,
			clickfinger_behavior = true,
		},
	},
})

-- ---------------------------------------------------------------------------
-- GENERAL
-- ---------------------------------------------------------------------------
hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 10,
		border_size = 1,
		["col.active_border"] = "rgb(e57e80)",
		["col.inactive_border"] = "rgb(829181)",
		layout = "dwindle",
		allow_tearing = true,

		snap = {
			enabled = true,
			window_gap = 10,
			monitor_gap = 10,
			respect_gaps = true,
		},
	},
})

-- ---------------------------------------------------------------------------
-- DECORATION
-- ---------------------------------------------------------------------------
hl.config({
	decoration = {
		rounding = 5,
		dim_special = 0.3,
		active_opacity = 0.95,
		inactive_opacity = 0.8,

		blur = {
			enabled = true,
			size = 6,
			passes = 3,
			noise = 0.1,
			xray = false,
			special = false,
			brightness = 1.02,
			popups = false,
			ignore_opacity = true,
		},

		shadow = {
			enabled = true,
			range = 60,
			color = "rgba(0000004A)",
			offset = "0 15",
			scale = 0.985,
		},
	},
})

-- ---------------------------------------------------------------------------
-- ANIMATIONS
-- ---------------------------------------------------------------------------
hl.curve("myBezier", {
    type = "bezier",
    points = { {0.05, 0.9}, {0.1, 1.00} }
})

hl.animation({leaf = "windows", enabled = true, speed = 2, bezier = "myBezier"})
hl.animation({leaf = "windowsOut", enabled = true, speed = 2, bezier = "default", style = "popin 80%"})
hl.animation({leaf = "border", enabled = true, speed = 2, bezier = "default"})
hl.animation({leaf = "fade", enabled = true, speed = 2, bezier = "default"})
hl.animation({leaf ="fadeSwitch", enabled = true, speed = 9, bezier = "default"})
hl.animation({leaf = "fadeLayers", enabled = true, speed = 2, bezier = "default"})
hl.animation({leaf = "workspaces", enabled = true, speed = 2, bezier = "default", style = "slidefade 50%"})
hl.animation({leaf = "specialWorkspace", enabled = true, speed = 2, bezier = "default", style = "slidefadevert -20%"})

-- ---------------------------------------------------------------------------
-- DWINDLE
-- ---------------------------------------------------------------------------
hl.config({
	dwindle = {
		preserve_split = true,
		smart_resizing = true,
	},
})

-- ---------------------------------------------------------------------------
-- GROUP
-- ---------------------------------------------------------------------------
hl.config({
	group = {
		auto_group = false,
		drag_into_group = 2,
		["col.border_active"] = "rgb(81A092)",
		["col.border_inactive"] = "rgb(4B8384)",
		["col.border_locked_active"] = "rgb(86B376)",
		["col.border_locked_inactive"] = "rgb(699968)",

		groupbar = {
			font_size = 11,
			height = 20,
			["col.active"] = "rgb(4B8384)",
			["col.inactive"] = "rgb(4B8384)",
		},
	},
})

-- ---------------------------------------------------------------------------
-- GESTURES
-- ---------------------------------------------------------------------------
hl.config({
	gestures = {
		workspace_swipe_distance = 300,
	},
})
hl.gesture({fingers = 3, direction = "horizontal", action = "workspace"})

-- ---------------------------------------------------------------------------
-- MISC
-- ---------------------------------------------------------------------------
hl.config({
	misc = {
		font_family = "Maple Mono NF",
		disable_hyprland_logo = 1,
		background_color = "rgb(272e33)",
	},
})

-- ---------------------------------------------------------------------------
-- BINDS
-- ---------------------------------------------------------------------------
hl.config({
	binds = {
		workspace_center_on = 1,
	},
})

-- ---------------------------------------------------------------------------
-- WORKSPACES
-- ---------------------------------------------------------------------------
hl.workspace_rule({
	workspace = "special:scratchpad",
	gaps_in = 20,
	gaps_out = 40,
})

-- ---------------------------------------------------------------------------
-- WINDOW RULES
-- ---------------------------------------------------------------------------
-- Dialogs -------------------------------------------------------------------
hl.window_rule({
    name  = "dialogs",
    match = { modal = true },
    float = true,
    center = true,
})
-----------------------------------------------------------------------------

-- Picture-in-Picture --------------------------------------------------------
hl.window_rule({
    name  = "picture-in-picture",
    match = { title = "^(Picture(-| )in(-| )[Pp]icture)$" },
    keep_aspect_ratio = true,
    move  = {"73%", "72%"},
    size  = {"25%", "25%"},
    float = true,
    pin   = true,
})
-----------------------------------------------------------------------------

-- Games ---------------------------------------------------------------------
hl.window_rule({
    name    = "game",
    match   = { content = "game" },
    monitor = "0",
})

hl.window_rule({
    name      = "game-steam",
    match     = { class = "(steam_app)" },
    monitor   = "0",
    immediate = true,
})

hl.window_rule({
    name      = "game-minecraft",
    match     = { class = "([Mm]inecraft)" },
    monitor   = "0",
    immediate = true,
})

-- Fullscreen border ---------------------------------------------------------
hl.window_rule({
    name         = "fullscreen-border",
    match        = { fullscreen_state_client = 1 },
    border_color = "rgb(7fbbb3)",
})

-- Kitty opacity -------------------------------------------------------------
hl.window_rule({
    name     = "kitty",
    match    = { class = "^(kitty)$" },
    opacity  = "0.9 0.8",
})

-- Browser -------------------------------------------------------------------
hl.window_rule({
    name    = "browser",
    match   = { class = "thorium-browser" },
    opaque  = true,
})

-- Browser popup -------------------------------------------------------------
hl.window_rule({
    name    = "browser-popup",
    match   = { class = "^(thorium-.*-Profile_.*)$" },
    float   = true,
    move    = {"cursor_x-(window_w*0.5)", "cursor_y-(window_h*0.5)"},
})

-- Pavucontrol ---------------------------------------------------------------
hl.window_rule({
    name    = "pavucontrol",
    match   = { class = "^(org.pulseaudio.pavucontrol)$" },
    float   = true,
    center  = true,
})

-- Workspace presets ---------------------------------------------------------
hl.window_rule({
    name      = "steam",
    match     = { class = "^(steam)$" },
    workspace = "5",
})

hl.window_rule({
    name      = "discord",
    match     = { class = "^(discord)$" },
    workspace = "2",
})

hl.on("hyprland.start", function()
    hl.exec_cmd("discord", { workspace = "2 silent" })
end)

-- ---------------------------------------------------------------------------
-- LAYER RULES
-- ---------------------------------------------------------------------------
hl.layer_rule({
    name = "anyrun",
    match = { namespace = "^(anyrun)$" },
	dim_around = true,
})


-- General binds ----------------------------------------------------------------
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + F",  hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = 0 }))

hl.bind(mainMod .. " + return",    hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + W",         hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + space",     hl.dsp.exec_cmd(menu))

-- Widgets
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -nra"))
hl.bind(mainMod .. " + backspace", hl.dsp.exec_cmd("nwg-bar -f"))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("killall -SIGUSR1 waybar"))


-- Window manipulation binds ----------------------------------------------------
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left"  }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up"    }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down"  }))

hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left"  }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up"    }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down"  }))

-- Resize active window (repeating binds)
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.resize({ x = -20, y =  0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x =  20, y =  0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.resize({ x =  0, y = -20, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.resize({ x =  0, y =  20, relative = true }), { repeating = true })

-- Workspace binds --------------------------------------------------------------
-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad (special workspace)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:scratchpad" }))

-- Monitor focus / move
hl.bind(mainMod .. " + comma",  hl.dsp.focus({ monitor = "left"  }))
hl.bind(mainMod .. " + period", hl.dsp.focus({ monitor = "right" }))
hl.bind(mainMod .. " + SHIFT + comma",  hl.dsp.workspace.move({ monitor = "left"  }))
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.workspace.move({ monitor = "right" }))

-- Workspace scrolling
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + SHIFT + mouse_down", hl.dsp.window.move({ workspace = "m+1" }))
hl.bind(mainMod .. " + SHIFT + mouse_up",   hl.dsp.window.move({ workspace = "m-1" }))


-- Mouse binds ------------------------------------------------------------------
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })


-- Reload submap ----------------------------------------------------------------
hl.bind(mainMod .. " + ALT + R", hl.dsp.exec_cmd('notify-send "Reload submap (press escape to cancel)" -t 2000'))
hl.bind(mainMod .. " + ALT + R", hl.dsp.submap("reload"))

hl.define_submap("reload", function()
    -- B: restart waybar
    hl.bind("B", hl.dsp.exec_cmd("killall waybar; waybar"))
    hl.bind("B", hl.dsp.submap("reset"))

    -- H: reload hyprctl config
    hl.bind("H", hl.dsp.exec_cmd("hyprctl reload"))
    hl.bind("H", hl.dsp.submap("reset"))

    -- P: restart hyprpaper
    hl.bind("P", hl.dsp.exec_cmd("killall hyprpaper; hyprpaper"))
    hl.bind("P", hl.dsp.submap("reset"))

    -- escape exits the submap
    hl.bind("escape", hl.dsp.submap("reset"))
end)


-- Special keys -----------------------------------------------------------------
-- Volume & mic control (repeating binds)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"), { repeating = true })
hl.bind(mainMod .. " + equal",  hl.dsp.exec_cmd("pamixer -i 5"), { repeating = true })
hl.bind(mainMod .. " + minus",  hl.dsp.exec_cmd("pamixer -d 5"), { repeating = true })

-- Mute (not repeating)
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pamixer --default-source -t"))
hl.bind("XF86AudioMute",    hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"))

-- Media controls
hl.bind("XF86AudioPlay",   hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPause",  hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext",   hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev",   hl.dsp.exec_cmd("playerctl previous"))

-- Brightness controls (locked + repeating — fires on the lockscreen)
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set +5%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

hl.bind("print", function()
    hl.plugin.hyprcapture.open()
end)
hl.bind("SHIFT + print", function()
    hl.plugin.hyprcapture.open("fullscreen")
end)

-- Hyper (Caps lock) layer ------------------------------------------------------
hl.bind("MOD3 + D", hl.dsp.exec_cmd("darkman toggle"))
hl.bind(mainMod .. " + F10", hl.dsp.pass({ window = "class:^(com\\.obsproject\\.Studio)$" }))
hl.bind(mainMod .. " + F11", hl.dsp.pass({ window = "class:^(com\\.obsproject\\.Studio)$" }))
