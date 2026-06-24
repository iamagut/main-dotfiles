-- ╔═══════════════════════════════════════════════════════════════╗
-- ║                        Environment                            ║
-- ╚═══════════════════════════════════════════════════════════════╝
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
--
-- NOTE: If you launch Hyprland via uwsm, prefer putting env vars in
--   ~/.config/uwsm/env          (all Wayland sessions)
--   ~/.config/uwsm/env-hyprland (Hyprland-exclusive: AQ_*, HYPR*)

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.env("XDG_MENU_PREFIX", "plasma-")

--Qt
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCEEN_SCALE_FACTOR", "1.25")

-- Backend
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")

-- XDG
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Nvidia
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")