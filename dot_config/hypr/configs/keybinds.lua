-- Migrated from keybinds.conf
-- See https://wiki.hypr.land/Configuring/Basics/Binds/

local mainMod = "SUPER"
local home    = os.getenv("HOME")

-- ─────────────────────────────────────────────────────────────────────────────
-- Window management  (mainMod + CTRL)
-- Letter keys on bare mainMod are reserved for workspaces (see below), so all
-- window-management actions live on the mainMod + CTRL layer.
-- ─────────────────────────────────────────────────────────────────────────────
hl.bind(mainMod .. " + CTRL + q",         hl.dsp.window.close())
hl.bind(mainMod .. " + CTRL + SHIFT + q", hl.dsp.exit())
hl.bind(mainMod .. " + CTRL + f",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + CTRL + p",         hl.dsp.window.pin())
hl.bind(mainMod .. " + CTRL + s",         hl.dsp.layout("togglesplit")) -- dwindle

-- Move focus with mainMod + CTRL + hjkl
hl.bind(mainMod .. " + CTRL + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + CTRL + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + CTRL + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + CTRL + j", hl.dsp.focus({ direction = "down" }))

-- ─────────────────────────────────────────────────────────────────────────────
-- Workspaces  (mainMod + <key>)
-- Every letter and digit is its own workspace. Digits are native numbered
-- workspaces; letters are named workspaces (e.g. "D" for Docker, "M" for Mongo).
--   mainMod          + <key>  → switch to that workspace
--   mainMod + SHIFT  + <key>  → move the active window to that workspace
-- ─────────────────────────────────────────────────────────────────────────────

-- Digits → native numbered workspaces (0 maps to 10)
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Letters → named workspaces
for letter in ("ABCDEFGHIJKLMNOPQRSTUVWXYZ"):gmatch(".") do
    local ws = "name:" .. letter
    hl.bind(mainMod .. " + " .. letter,         hl.dsp.focus({ workspace = ws }))
    hl.bind(mainMod .. " + SHIFT + " .. letter, hl.dsp.window.move({ workspace = ws }))
end

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ─────────────────────────────────────────────────────────────────────────────
-- Programs
-- ─────────────────────────────────────────────────────────────────────────────
hl.bind(mainMod .. " + RETURN",           hl.dsp.exec_cmd("ghostty"))
hl.bind(mainMod .. " + Space",            hl.dsp.exec_cmd(home .. "/.config/rofi/scripts/launcher_t4"))
hl.bind(mainMod .. " + CTRL + SHIFT + P", hl.dsp.exec_cmd(home .. "/.config/rofi/scripts/powermenu_t1"))
hl.bind(mainMod .. " + CTRL + b",         hl.dsp.exec_cmd("blueman-manager"))

-- hyprvoice
hl.bind(mainMod .. " + CTRL + r", hl.dsp.exec_cmd("hyprvoice toggle"))
