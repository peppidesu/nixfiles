------------------
---- MONITORS ----
------------------
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

hl.monitor({
    output               = "eDP-1",
    mode                 = "2560x1600@165",
    position             = "0x0",
    scale                = 1.33,
    vrr                  = true,
})

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("OZONE_PLATFORM", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
-- hl.env("SDL_VIDEODRIVER", "wayland, x11")
hl.env("EGL_PLATFORM", "wayland")

-- XDG Desktop Portal
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- QT
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
-- hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")

-- Toolkit-specific scale
-- hl.env("GDK_SCALE", "1.5")
-- hl.env("XCURSOR_SIZE", "32")

--------------------------
---- HARDWARE CONFIG -----
--------------------------
-- See https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
    general = {
        allow_tearing = true,
    },

    cursor = {
        no_hardware_cursors = true,
    },

    opengl = {
        nvidia_anti_flicker = false,
        -- force_introspection = 2,
    },

    render = {
        direct_scanout        = 0,
        new_render_scheduling = true,
    },

    misc = {
        vrr = 2,
    },

    xwayland = {
        force_zero_scaling = true,
    },
})

-- experimental = {
--   xx_color_management_v4 = true,
-- }
-- (uncomment and add to hl.config above if needed)
-- hl.config({
--     experimental = {
--         xx_color_management_v4 = true,
--     },
-- })


--- Power saving ---
local BAT = "BAT1"
local AC  = "ACAD"

local function read_val(path)
  local f = io.open(path, "r"); if not f then return nil end
  local v = f:read("*l"); f:close(); return v
end

local function get_power_state()
  local base   = "/sys/class/power_supply/"
  local cap    = tonumber(read_val(base .. BAT .. "/capacity")) or 100
  local on_ac  = tonumber(read_val(base .. AC .. "/online")) == 1
  return cap, on_ac
end


local profiles = {
  saver       = {
                  decoration = { blur = { enabled = false } },
                  animations = { enabled = false } },
  balanced    = {
                  decoration = { blur = { enabled = true } } },
  performance = {
                  decoration = { blur = { enabled = true } } },
}

local current = nil
local function apply_profile(name)
  if name == current then return end
  current = name
  hl.config(profiles[name])            -- gaps/blur/animations
end

local function pick_profile(cap, on_ac)
  if on_ac then return "performance" end
  if cap <= 20 then return "saver" end
  return "balanced"
end

local function update_power_profile(cap, on_ac)
    local cap, on_ac = get_power_state()
    apply_profile(pick_profile(cap, on_ac))
end

update_power_profile()

hl.timer(update_power_profile, { timeout = 10000, type = "repeat" })
hl.on("hyprland.start", update_power_profile)

---
