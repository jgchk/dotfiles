-- Commands to be executed at launch.
-- Migrated from exec.conf.
--
-- hyprlang's `exec-once` ran only at startup; `exec` re-ran on every config
-- reload as well. That split is preserved here via two event handlers:
--   hyprland.start  -> everything, in the original file order
--   config.reloaded -> only the former `exec` entries

local home = os.getenv("HOME")

-- Former `exec` entries: re-run on every config reload.
local function reload_execs()
    -- EWW bar
    hl.exec_cmd("eww open bar_1")
end

hl.on("hyprland.start", function()
    -- Auth Agent
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

    -- XDG Desktop Portal
    -- See https://gist.github.com/PowerBall253/2dea6ddf6974ba4e5d26c3139ffb7580
    -- and https://wiki.hypr.land/Hypr-Ecosystem/xdg-desktop-portal-hyprland/
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- hyprsunset — blue-light filter (schedule in ~/.config/hypr/hyprsunset.conf)
    -- See https://wiki.hypr.land/Hypr-Ecosystem/hyprsunset/
    hl.exec_cmd("dbus-update-activation-environment --systemd HYPRLAND_INSTANCE_SIGNATURE")
    hl.exec_cmd("hyprsunset")

    -- Clipboard
    hl.exec_cmd("wl-paste --type text --watch cliphist store")  -- Stores only text data
    hl.exec_cmd("wl-paste --type image --watch cliphist store") -- Stores only image data

    -- Notifications
    hl.exec_cmd("swaync")

    -- Automount
    hl.exec_cmd("udiskie")

    -- EWW. No explicit `eww daemon` here on purpose: `eww open` auto-starts the
    -- daemon, and launching both back-to-back races them. The client connects
    -- before the daemon accepts connections, then lingers as a second window
    -- owner — which is how the bar ends up rendered twice.
    reload_execs()
    hl.exec_cmd(home .. "/.config/eww/scripts/reopen-bar-on-monitor-added.sh")

    -- Wallpaper
    hl.exec_cmd("hyprpaper")
end)

hl.on("config.reloaded", reload_execs)
