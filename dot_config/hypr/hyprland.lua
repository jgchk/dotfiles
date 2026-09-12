-- Hyprland configuration (Lua).
-- Migrated from hyprland.conf — hyprlang/.conf support is removed in Hyprland 0.57.
-- Reference: /usr/share/hypr/hyprland.lua, type stubs: /usr/share/hypr/stubs/hl.meta.lua
-- Wiki: https://wiki.hypr.land/Configuring/Start/

local colors = require("configs.colors")

------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "DP-2",
    mode     = "2560x1440@143.912003",
    position = "auto",
    scale    = "auto",
})

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")

-- NVIDIA
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

-----------------------
---- LOOK AND FEEL ----
-----------------------

-- For all categories, see https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    cursor = {
        no_hardware_cursors = true,
    },

    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = false,
        },
    },

    general = {
        gaps_in     = 5,
        gaps_out    = 14,
        border_size = 2,

        col = {
            active_border   = "rgba(" .. colors.active_border .. ")",
            inactive_border = "rgba(" .. colors.inactive_border .. ")",
        },

        layout = "dwindle",
    },

    decoration = {
        rounding = 1,

        blur = {
            enabled           = true,
            size              = 3,
            passes            = 1,
            new_optimizations = true,
        },

        shadow = {
            enabled      = true,
            range        = 6,
            render_power = 3,
            color        = "rgba(000000ff)",
        },
    },

    animations = {
        enabled = true,
    },

    -- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
    -- Note: the old `pseudotile` option was removed in Hyprland 0.55.
    -- Pseudotiling is now a per-window state toggled by the `pseudo` dispatcher.
    dwindle = {
        preserve_split = true, -- you probably want this
    },

    -- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
    master = {
        new_status = "master",
    },

    misc = {
        focus_on_activate = true,
    },
})

----------------------
---- ANIMATIONS  -----
----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("bezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })

hl.animation({ leaf = "windows",    enabled = true, speed = 2, bezier = "bezier", style = "slide" })
hl.animation({ leaf = "border",     enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "fade",       enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

------------------
---- GESTURES ----
------------------

-- Uncomment to enable workspace swiping with 3 fingers
-- hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
-- hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })

--------------------------
---- SPLIT-OUT CONFIG ----
--------------------------

require("configs.exec")
require("configs.graphics")
require("configs.keybinds")
require("configs.windows")
