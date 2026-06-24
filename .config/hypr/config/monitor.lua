-- ╔═══════════════════════════════════════════════════════════════╗
-- ║                           Monitor                             ║
-- ╚═══════════════════════════════════════════════════════════════╝
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
 
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@75.00",
    position = "0x0",
    scale    = 1,
})

for i = 1, 5 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "HDMI-A-1", persistent = true })
end