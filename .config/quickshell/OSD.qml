import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Wayland

PanelWindow {
    id: osdWindow

    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    // Display-only: never capture pointer events (even while visible/fading).
    // Without a mask, the PanelWindow blocks apps in its 260×64 region.
    mask: Region {
        shape: RegionShape.Rect
        x: 0
        y: 0
        width: 0
        height: 0
    }

    // Floating bottom-center OSD
    anchors {
        bottom: true
        top: false
        left: false
        right: false
    }
    margins {
        bottom: 150
    }

    implicitWidth: 260
    implicitHeight: 64
    color: "transparent"

    // --- Volume properties ---
    property var sink: Pipewire.defaultAudioSink
    readonly property bool ready: sink && sink.ready
    readonly property bool muted: ready && sink.audio.muted
    readonly property real volumeLevel: ready ? sink.audio.volume : 0
    readonly property int volPercent: Math.round(volumeLevel * 100)

    // --- Caps Lock properties ---
    property bool capsLockOn: false

    // --- OSD state ---
    // "volume" or "capslock"
    property string osdMode: "volume"
    property bool isShown: false

    Timer {
        id: hideTimer
        interval: 2000
        repeat: false
        onTriggered: osdWindow.isShown = false
    }

    // --- Volume change tracking ---
    property int lastVol: -1
    property bool lastMuted: false
    property bool initialized: false

    onVolPercentChanged: {
        if (!initialized) return
        if (volPercent !== lastVol) {
            lastVol = volPercent
            triggerOSD("volume")
        }
    }

    onMutedChanged: {
        if (!initialized) return
        if (muted !== lastMuted) {
            lastMuted = muted
            triggerOSD("volume")
        }
    }

    // --- Caps Lock polling ---
    property bool capsInitialized: false

    Timer {
        id: capsPoller
        interval: 200
        running: true
        repeat: true
        onTriggered: capsProcess.running = true
    }

    Process {
        id: capsProcess
        command: ["sh", "-c", "cat /sys/class/leds/input*::capslock/brightness 2>/dev/null | head -1"]
        stdout: SplitParser {
            onRead: data => {
                var val = data.trim() === "1"
                if (!osdWindow.capsInitialized) {
                    osdWindow.capsLockOn = val
                    osdWindow.capsInitialized = true
                    return
                }
                if (val !== osdWindow.capsLockOn) {
                    osdWindow.capsLockOn = val
                    osdWindow.triggerOSD("capslock")
                }
            }
        }
    }

    // --- Init delay (volume) ---
    Timer {
        id: initDelay
        interval: 1000
        running: true
        repeat: false
        onTriggered: {
            if (osdWindow.ready) {
                osdWindow.lastVol = osdWindow.volPercent
                osdWindow.lastMuted = osdWindow.muted
            }
            osdWindow.initialized = true
        }
    }

    function triggerOSD(mode) {
        if (!initialized && mode === "volume") return
        osdMode = mode
        isShown = true
        hideTimer.restart()
    }

    Rectangle {
        id: contentCard
        anchors.fill: parent
        radius: 16
        color: Color.md3.surface_container_highest
        border.color: Color.md3.outline_variant
        border.width: 1
        opacity: osdWindow.isShown ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }

        // --- Volume OSD content ---
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            anchors.topMargin: 10
            anchors.bottomMargin: 10
            spacing: 14
            visible: osdWindow.osdMode === "volume"

            Text {
                text: osdWindow.muted ? "󰝟" : (osdWindow.volPercent === 0 ? "󰕿" : (osdWindow.volPercent < 50 ? "󰖀" : "󰕾"))
                font.family: "Jetbrains Mono Nerd Font Propo"
                font.pixelSize: 22
                color: osdWindow.muted ? Color.md3.error : Color.md3.primary
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Volume"
                        font.pixelSize: 12
                        font.bold: true
                        font.family: "Jetbrains Mono Nerd Font Propo"
                        color: Color.md3.on_surface
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: osdWindow.muted ? "Muted" : (osdWindow.volPercent + "%")
                        font.pixelSize: 12
                        font.family: "Jetbrains Mono Nerd Font Propo"
                        color: osdWindow.muted ? Color.md3.error : Color.md3.on_surface_variant
                    }
                }

                // Progress track
                Rectangle {
                    Layout.fillWidth: true
                    height: 6
                    radius: 3
                    color: Color.md3.surface_variant

                    Rectangle {
                        width: osdWindow.muted ? 0 : Math.min(parent.width, parent.width * (osdWindow.volPercent / 100.0))
                        height: parent.height
                        radius: 3
                        color: Color.md3.primary

                        Behavior on width {
                            NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
                        }
                    }
                }
            }
        }

        // --- Caps Lock OSD content ---
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            anchors.topMargin: 10
            anchors.bottomMargin: 10
            spacing: 14
            visible: osdWindow.osdMode === "capslock"

            Text {
                text: osdWindow.capsLockOn ? "󰬈" : "󰬈"
                font.family: "Jetbrains Mono Nerd Font Propo"
                font.pixelSize: 22
                color: osdWindow.capsLockOn ? Color.md3.primary : Color.md3.outline
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Caps Lock"
                        font.pixelSize: 12
                        font.bold: true
                        font.family: "Jetbrains Mono Nerd Font Propo"
                        color: Color.md3.on_surface
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: osdWindow.capsLockOn ? "On" : "Off"
                        font.pixelSize: 12
                        font.family: "Jetbrains Mono Nerd Font Propo"
                        color: osdWindow.capsLockOn ? Color.md3.primary : Color.md3.on_surface_variant
                    }
                }

                // Indicator bar (full when on, empty when off)
                Rectangle {
                    Layout.fillWidth: true
                    height: 6
                    radius: 3
                    color: Color.md3.surface_variant

                    Rectangle {
                        width: osdWindow.capsLockOn ? parent.width : 0
                        height: parent.height
                        radius: 3
                        color: Color.md3.primary

                        Behavior on width {
                            NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                        }
                    }
                }
            }
        }
    }

    PwObjectTracker {
        objects: osdWindow.sink ? [osdWindow.sink] : []
    }
}
