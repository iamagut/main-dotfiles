-- ╔═══════════════════════════════════════════════════════════════╗
-- ║                  hyprland.lua — entry point                   ║
-- ║            Converted hyprlang .conf to Lua (≥ 0.55)           ║
-- ╚═══════════════════════════════════════════════════════════════╝
-- Docs: https://wiki.hypr.land/Configuring/Start/
 
require("config.monitor")     -- monitor layout
require("config.env")         -- environment variables
require("config.autostart")   -- exec-once → hl.on("hyprland.start")
require("config.decorations") -- general, decoration, animations, dwindle, misc
require("config.userinputs")  -- input, gestures, per-device
require("config.keybinds") -- hl.bind(…)
require("config.windowrules") -- hl.window_rule / hl.layer_rule
 
-- ─── PERMISSIONS (uncomment to enable) ─────────────────────────
-- hl.config({ ecosystem = { enforce_permissions = true } })
-- hl.permission("/usr/(bin|local/bin)/grim",                            "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm",                          "plugin",     "allow")
