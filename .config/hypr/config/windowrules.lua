-- ╔═══════════════════════════════════════════════════════════════╗
-- ║                       Windowrules                             ║
-- ╚═══════════════════════════════════════════════════════════════╝
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- Rules are evaluated top to bottom — order matters.

-- ── Globals ──────────────────────────────────────────────────────
hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

-- ── Floating + centred utility windows ───────────────────────────
hl.window_rule({
	match = { class = "org.pulseaudio.pavucontrol" },
	float = true,
	size = "800 600",
	center = true,
})

hl.window_rule({
	match = { class = "nm-connection-editor" },
	float = true,
	size = "800 600",
	center = true,
})

hl.window_rule({
	match = { class = "nwg-look" },
	float = true,
	size = "800 600",
	center = true,
})

hl.window_rule({
	match = { class = "waypaper" },
	float = true,
	center = true,
})

hl.window_rule({
	match = { class = "qalculate-gtk" },
	float = true,
	center = true,
})

-- ── Picture-in-Picture ───────────────────────────────────────────
hl.window_rule({
	name = "pip-tag",
	match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
	tag = "+picture-in-picture",
})

hl.window_rule({
	name = "pip-style",
	match = { tag = "picture-in-picture" },
	float = true,
	keep_aspect_ratio = true,
	move = { "monitor_w - window_w - monitor_w * 0.025", "monitor_h - window_h - monitor_h * 0.029" },
	size = { "monitor_w * 0.22", "monitor_h * 0.22" },
	pin = true,
	opacity = "1.0 override",
})

-- ── Opacity — editors & theming tools ────────────────────────────
-- Format: "active override inactive override fullscreen override"
-- ($& in the old syntax mapped to the override keyword)
hl.window_rule({
	match = { class = "^([Cc]ode)$" },
	opacity = "0.80 override 0.80 override 1.0 override",
})
hl.window_rule({
	match = { class = "^(code-url-handler)$" },
	opacity = "0.80 override 0.80 override 1.0 override",
})
hl.window_rule({
	match = { class = "^(code-insiders-url-handler)$" },
	opacity = "0.80 override 0.80 override 1.0 override",
})
hl.window_rule({
	match = { class = "^(nwg-look)$" },
	opacity = "0.80 override 0.80 override 1.0 override",
})
hl.window_rule({
	match = { class = "^(qalculate-gtk)$" },
	opacity = "0.80 override 0.80 override 1.0 override",
})
hl.window_rule({
	match = { class = "^(qt5ct)$" },
	opacity = "0.80 override 0.80 override 1.0 override",
})
hl.window_rule({
	match = { class = "^(qt6ct)$" },
	opacity = "0.80 override 0.80 override 1.0 override",
})
hl.window_rule({
	match = { class = "^(kvantummanager)$" },
	opacity = "0.80 override 0.80 override 1.0 override",
})

-- Opacity — system utilities (more transparent when inactive)
hl.window_rule({
	match = { class = "^(org.pulseaudio.pavucontrol)$" },
	opacity = "0.80 override 0.70 override 1.0 override",
})
hl.window_rule({
	match = { class = "^(blueman-manager)$" },
	opacity = "0.80 override 0.70 override 1.0 override",
})
hl.window_rule({
	match = { class = "^(nm-applet)$" },
	opacity = "0.80 override 0.70 override 1.0 override",
})
hl.window_rule({
	match = { class = "^(nm-connection-editor)$" },
	opacity = "0.80 override 0.70 override 1.0 override",
})
hl.window_rule({
	match = { class = "^(org.kde.polkit-kde-authentication-agent-1)$" },
	opacity = "0.80 override 0.70 override 1.0 override",
})
hl.window_rule({
	match = { class = "^(polkit-gnome-authentication-agent-1)$" },
	opacity = "0.80 override 0.70 override 1.0 override",
})
hl.window_rule({
	match = { class = "^(org.freedesktop.impl.portal.desktop.gtk)$" },
	opacity = "0.80 override 0.70 override 1.0 override",
})
hl.window_rule({
	match = { class = "^(org.freedesktop.impl.portal.desktop.hyprland)$" },
	opacity = "0.80 override 0.70 override 1.0 override",
})
hl.window_rule({
	match = { class = "^([Ss]team)$" },
	opacity = "0.70 override 0.70 override 1.0 override",
})
hl.window_rule({
	match = { class = "^(steamwebhelper)$" },
	opacity = "0.70 override 0.70 override 1.0 override",
})

-- Opacity — GTK / Qt apps (multiplicative, no override)
hl.window_rule({ match = { class = "^(com.github.rafostar.Clapper)$" }, opacity = "0.90 0.90" }) -- Clapper
hl.window_rule({ match = { class = "^(com.github.tchx84.Flatseal)$" }, opacity = "0.80 0.80" }) -- Flatseal
hl.window_rule({ match = { class = "^(hu.kramo.Cartridges)$" }, opacity = "0.80 0.80" }) -- Cartridges
hl.window_rule({ match = { class = "^(com.obsproject.Studio)$" }, opacity = "0.80 0.80" }) -- OBS
hl.window_rule({ match = { class = "^(gnome-boxes)$" }, opacity = "0.80 0.80" }) -- Boxes
hl.window_rule({ match = { class = "^(app.drey.Warp)$" }, opacity = "0.80 0.80" }) -- Warp
hl.window_rule({ match = { class = "^(net.davidotek.pupgui2)$" }, opacity = "0.80 0.80" }) -- ProtonUp
hl.window_rule({ match = { class = "^(yad)$" }, opacity = "0.80 0.80" }) -- Protontricks
hl.window_rule({ match = { class = "^(Signal)$" }, opacity = "0.80 0.80" }) -- Signal
hl.window_rule({ match = { class = "^(io.github.alainm23.planify)$" }, opacity = "0.80 0.80" }) -- Planify
hl.window_rule({ match = { class = "^(io.gitlab.theevilskeleton.Upscaler)$" }, opacity = "0.80 0.80" }) -- Upscaler
hl.window_rule({ match = { class = "^(com.github.unrud.VideoDownloader)$" }, opacity = "0.80 0.80" }) -- VideoDownloader
hl.window_rule({ match = { class = "^(io.gitlab.adhami3310.Impression)$" }, opacity = "0.80 0.80" }) -- Impression
hl.window_rule({ match = { class = "^(io.missioncenter.MissionCenter)$" }, opacity = "0.80 0.80" }) -- MissionCenter
hl.window_rule({ match = { class = "^(io.github.flattool.Warehouse)$" }, opacity = "0.80 0.80" }) -- Warehouse

-- ── Float rules ──────────────────────────────────────────────────
local floatClasses = {
	"^(Signal)$",
	"^(kvantummanager)$",
	"^(com.github.rafostar.Clapper)$",
	"^(app.drey.Warp)$",
	"^(net.davidotek.pupgui2)$",
	"^(yad)$",
	"^(eog)$",
	"^(io.github.alainm23.planify)$",
	"^(io.gitlab.theevilskeleton.Upscaler)$",
	"^(com.github.unrud.VideoDownloader)$",
	"^(io.gitlab.adhami3310.Impression)$",
	"^(io.missioncenter.MissionCenter)$",
}
for _, cls in ipairs(floatClasses) do
	hl.window_rule({ match = { class = cls }, float = true })
end

-- ── JetBrains IDE popup flicker workaround ───────────────────────
hl.window_rule({
	match = { class = "^(.*jetbrains.*)$", title = "^(win[0-9]+)$" },
	no_initial_focus = true,
})

-- ── Layer rules ──────────────────────────────────────────────────
hl.layer_rule({ match = { namespace = "logout_dialog" }, blur = true })
hl.layer_rule({
	name = "notification-anims",
	match = { namespace = "swaync-control-center" },
	animation = "slide top",
})
