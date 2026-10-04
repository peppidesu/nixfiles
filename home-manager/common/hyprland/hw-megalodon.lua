------------------
---- MONITORS ----
------------------
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

hl.monitor({
    output               = "DP-1",
    mode                 = "3840x2160@240",
    position             = "0x0",
    scale                = 1.33,
    vrr                  = true,
})
hl.monitor({
    output               = "HDMI-A-1",
    transform            = 3,
})

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("OZONE_PLATFORM", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
-- hl.env("SDL_VIDEODRIVER", "wayland, x11")
-- hl.env("EGL_PLATFORM", "wayland")

-- XDG Desktop Portal
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- QT
-- hl.env("QT_QPA_PLATFORM", "wayland")
-- hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
-- hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
-- hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
-- hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")

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


---
