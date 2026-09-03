------------------
---- MONITORS ----
------------------
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

hl.monitor({
    output               = "eDP-1",
    mode                 = "2560x1600@165",
    position             = "0x0",
    scale                = 1.33,
    sdr_max_luminance    = 120,
    sdr_min_luminance    = 0.005,
    min_luminance        = 0.005,
    max_luminance        = 1000,
    vrr                  = true,
    -- bitdepth             = 10,
})

hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@60",
    position = "-1080x-280",
    scale    = 1,
    transform = 1,
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
        allow_tearing = false,
    },

    cursor = {
        no_hardware_cursors = true,
    },

    opengl = {
        nvidia_anti_flicker = false,
        -- force_introspection = 2,
    },

    render = {
        direct_scanout        = 1,
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
