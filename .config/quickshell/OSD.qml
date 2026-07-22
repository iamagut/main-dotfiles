import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Wayland

PanelWindow {
    id: osdWindow

    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    // Floating bottom-center OSD
    anchors {
        bottom: true
        top: false
        left: false
        right: false
    }
    margins {
        bottom: 50
    }

    implicitWidth: 260
    implicitHeight: 64
    color: "transparent"

    property var sink: Pipewire.defaultAudioSink
    readonly property bool ready: sink && sink.ready
    readonly property bool muted: ready && sink.audio.muted
    readonly property real volumeLevel: ready ? sink.audio.volume : 0
    readonly property int volPercent: Math.round(volumeLevel * 100)

    property bool isShown: false

    Timer {
        id: hideTimer
        interval: 2000
        repeat: false
        onTriggered: osdWindow.isShown = false
    }

    property int lastVol: -1
    property bool lastMuted: false
    property bool initialized: false

    onVolPercentChanged: {
        if (!initialized) return
        if (volPercent !== lastVol) {
            lastVol = volPercent
            triggerOSD()
        }
    }

    onMutedChanged: {
        if (!initialized) return
        if (muted !== lastMuted) {
            lastMuted = muted
            triggerOSD()
        }
    }

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

    function triggerOSD() {
        if (!initialized) return
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

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            anchors.topMargin: 10
            anchors.bottomMargin: 10
            spacing: 14

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
    }

    PwObjectTracker {
        objects: osdWindow.sink ? [osdWindow.sink] : []
    }
}
