-- ╔═══════════════════════════════════════════════════════════════╗
-- ║                          Autostart                            ║
-- ╚═══════════════════════════════════════════════════════════════╝
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
--
-- hl.on("hyprland.start") fires once at compositor startup and NOT
-- on config reloads — the direct replacement for exec-once.

hl.on("hyprland.start", function()
	hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
	hl.exec_cmd("nm-applet")
	hl.exec_cmd("swaync")
	hl.exec_cmd("swaync-client -rs")
	hl.exec_cmd("dbus-update-activation-environment")
	hl.exec_cmd("waybar")
	hl.exec_cmd("awww-daemon &")
	hl.exec_cmd("systemctl --user start hyprpolkitagent &")
	hl.exec_cmd("waypaper --restore")
	hl.exec_cmd("wl-paste --watch cliphist store")
	hl.exec_cmd("kbuildsycoca6 --noincremental")
end)

