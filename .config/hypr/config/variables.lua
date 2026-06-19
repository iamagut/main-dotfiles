-- ╔═══════════════════════════════════════════════════════════════╗
-- ║                         Variables                             ║
-- ╚═══════════════════════════════════════════════════════════════╝
-- These are module-level values returned as a table so config files
-- can use require("config.variables") safely.

local M = {
    mainMod      = "SUPER",
    terminal     = "kitty",
    fileManager  = "kitty -e yazi",
    menu         = "rofi -show drun",
    browser      = "vivaldi --password-store=basic",
    editor       = "codium",
    scrPath      = os.getenv("HOME") .. "/.config/hypr/scripts",
}

return M
