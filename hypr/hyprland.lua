------------------
---- MONITORS ----
------------------
hl.monitor({ output = "eDP-1",    mode = "1920x1080@60", position = "0x0",  scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "auto", scale = 1 })

---------------------
---- MY PROGRAMS ----
---------------------
local home          = os.getenv("HOME")
local cursor_size   = os.getenv("XCURSOR_SIZE")
local eww           = home .. "/ewwd/target/release/eww"
local terminal      = "kitty"
local fileManager   = "thunar"
local menu          = "rofi -show drun"
local browser       = "brave --password-store=basic"
local ocr           = home .. "/.config/scripts/ocr"
local camera_toggle = home .. "/.config/scripts/toggle-webcam"
local touch_pad     = "elan1200:00-04f3:309f-touchpad"

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"') -- GTK4
    hl.exec_cmd('gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3"')       -- GTK3
    hl.exec_cmd('gsettings set org.gnome.desktop.interface cursor-theme "BreezeX-RosePine-Linux"')
    hl.exec_cmd('gsettings set org.gnome.desktop.interface cursor-size ' .. cursor_size)
    hl.exec_cmd("uwsm app -- env EWW=" .. eww .. " " .. home .. "/.config/eww/scripts/bars.sh watch")
    hl.exec_cmd(camera_toggle)
    hl.exec_cmd("fcitx5 -d")
end)

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
    general = {
        border_size = 1,
        gaps_in     = 1,
        gaps_out    = 1,
        col = {
            active_border   = { colors = { "rgba(00FFFFee)", "rgba(FFFF00ee)" }, angle = 225 },
            inactive_border = "rgba(A16D28aa)",
        },
        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding         = 3,
        rounding_power   = 3,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled      = false, -- save power
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },
        blur = {
            enabled  = false, -- save power
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = { enabled = true },

    dwindle = { preserve_split = true },
    master  = { new_status = "master" },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },

    input = {
        kb_layout    = "us",
        kb_options   = "caps:escape",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = { natural_scroll = true },
    },
})

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}    } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}  } })

local function anim(leaf, speed, curve, style)
    hl.animation({ leaf = leaf, enabled = true, speed = speed, bezier = curve, style = style })
end
anim("global",        10,   "default")
anim("border",        5.39, "easeOutQuint")
anim("windows",       4.79, "easeOutQuint")
anim("windowsIn",     4.1,  "easeOutQuint", "popin 87%")
anim("windowsOut",    1.49, "linear",       "popin 87%")
anim("fadeIn",        1.73, "almostLinear")
anim("fadeOut",       1.46, "almostLinear")
anim("fade",          3.03, "quick")
anim("layers",        3.81, "easeOutQuint")
anim("layersIn",      4,    "easeOutQuint", "fade")
anim("layersOut",     1.5,  "linear",       "fade")
anim("fadeLayersIn",  1.79, "almostLinear")
anim("fadeLayersOut", 1.39, "almostLinear")
anim("workspaces",    1.94, "almostLinear", "fade")
anim("workspacesIn",  1.21, "almostLinear", "fade")
anim("workspacesOut", 1.94, "almostLinear", "fade")

---------------
---- INPUT ----
---------------
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.device({ name = touch_pad, enabled = true })

---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER"
local function key(k) return mainMod .. " + " .. k end

hl.bind(key("Q"), hl.dsp.exec_cmd(terminal))
hl.bind(key("C"), hl.dsp.window.close())
hl.bind(key("M"), hl.dsp.exit())
hl.bind(key("E"), hl.dsp.exec_cmd(fileManager))
hl.bind(key("V"), hl.dsp.window.float({ action = "toggle" }))
hl.bind(key("R"), hl.dsp.exec_cmd(menu))
hl.bind(key("P"), hl.dsp.window.pseudo()) -- dwindle
hl.bind(key("B"), hl.dsp.exec_cmd(browser))
hl.bind(key("S"), hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind(key("L"), hl.dsp.exec_cmd("hyprlock"))
hl.bind(key("F"), hl.dsp.exec_cmd("rofimoji --selector rofi --action copy"))
hl.bind(key("W"), hl.dsp.exec_cmd(ocr))
hl.bind(key("G"), hl.dsp.exec_cmd("EWW=" .. eww .. " " .. home .. "/.config/eww/scripts/bars.sh toggle"))
hl.bind(key("H"), hl.dsp.exec_cmd(eww .. " open power_menu --toggle"))
hl.bind(key("T"), hl.dsp.exec_cmd("EWW=" .. eww .. " " .. home .. "/.config/scripts/voyager-theme toggle")) -- bar + dunst light/dark

-- Move focus with mainMod + arrow keys
hl.bind(key("left"),  hl.dsp.focus({ direction = "left" }))
hl.bind(key("right"), hl.dsp.focus({ direction = "right" }))
hl.bind(key("up"),    hl.dsp.focus({ direction = "up" }))
hl.bind(key("down"),  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9], move window with mainMod + SHIFT + [1-9]
for i = 1, 10 do
    local k = i % 10
    hl.bind(key(k), hl.dsp.focus({ workspace = i }))
    if i < 10 then
        hl.bind(key("SHIFT + " .. k), hl.dsp.window.move({ workspace = i }))
    end
end

-- Cycle through existing workspaces
hl.bind(key("mouse_down"),  hl.dsp.focus({ workspace = "e+1" }))
hl.bind(key("mouse_up"),    hl.dsp.focus({ workspace = "e-1" }))
hl.bind(key("tab"),         hl.dsp.focus({ workspace = "e+1" }))
hl.bind(key("SHIFT + tab"), hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(key("mouse:272"), hl.dsp.window.drag(),   { mouse = true })
hl.bind(key("mouse:273"), hl.dsp.window.resize(), { mouse = true })

-- Multimedia keys for volume and LCD brightness
local le = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume",         hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),   le)
hl.bind("XF86AudioLowerVolume",         hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),        le)
hl.bind("XF86AudioMute",                hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),       le)
hl.bind("SHIFT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SOURCE@ 5%+"), le)
hl.bind("SHIFT + XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-"),      le)
hl.bind("SHIFT + XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),     le)
hl.bind("XF86MonBrightnessUp",          hl.dsp.exec_cmd("brightnessctl -e2 -n2 set 5%+"),                    le)
hl.bind("XF86MonBrightnessDown",        hl.dsp.exec_cmd("brightnessctl -e2 -n2 set 5%-"),                    le)
hl.bind("XF86WebCam",                   hl.dsp.exec_cmd(camera_toggle),                                      le)
hl.bind("XF86TouchpadToggle", hl.dsp.exec_cmd(home .. "/.config/scripts/touchpad " .. touch_pad))

-- Requires playerctl
local l = { locked = true }
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       l)
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), l)
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), l)
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   l)
hl.bind("XF86AudioStop",  hl.dsp.exec_cmd("playerctl stop"),       l)

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
-- Ignore maximize requests from apps
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})
