-- ╔═══════════════════════════════════════════════════════════════╗
-- ║                        Environment                            ║
-- ╚═══════════════════════════════════════════════════════════════╝
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
--
-- NOTE: If you launch Hyprland via uwsm, prefer putting env vars in
--   ~/.config/uwsm/env          (all Wayland sessions)
--   ~/.config/uwsm/env-hyprland (Hyprland-exclusive: AQ_*, HYPR*)
 
hl.env("XCURSOR_SIZE",    "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XDG_MENU_PREFIX", "plasma-")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
