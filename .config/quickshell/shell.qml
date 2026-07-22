import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland

ShellRoot {
    IpcHandler {
        target: "qsIpc"

        function toggleWallpaperSwitcher() {
            panel.switcherOpen = !panel.switcherOpen
        }
        function openWallpaperSwitcher() {
            panel.switcherOpen = true
        }
        function closeWallpaperSwitcher() {
            panel.switcherOpen = false
        }
    }

    // Main Panel Window containing Top Bar & Overlay Wallpaper Switcher
    PanelWindow {
        id: panel
        anchors {
            top: true
            left: false
            right: false
        }

        WlrLayershell.layer: WlrLayer.Overlay
        exclusionMode: ExclusionMode.Normal
        exclusiveZone: barHeight

        readonly property int barHeight: 40
        readonly property int switcherHeight: 450
        property bool switcherOpen: false
        readonly property real openProgress: Math.max(0, Math.min(1, (implicitHeight - barHeight) / switcherHeight))

        implicitWidth: 1040
        implicitHeight: barHeight + (switcherOpen ? switcherHeight : 0)

        Behavior on implicitHeight {
            NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
        }

        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: Color.md3.surface_container_high
            radius: 16
            border.color: Color.md3.outline_variant
            border.width: 1
            clip: true

            // --- TOP BAR ---
            Rectangle {
                id: bar
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: panel.barHeight
                color: "transparent"
                z: 2

                // --- LEFT SECTION ---
                Row {
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                        leftMargin: 14
                    }
                    spacing: 8

                    Workspaces {}
                }

                // --- CENTER SECTION ---
                Clock {
                    anchors.centerIn: parent
                }

                // --- RIGHT SECTION ---
                RowLayout {
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 14
                    }
                    spacing: 20

                    // Wallpaper Switcher Button
                    Rectangle {
                        Layout.alignment: Qt.AlignVCenter
                        width: 28
                        height: 28
                        radius: 8
                        color: panel.switcherOpen ? Color.md3.primary_container : (wpMouse.containsMouse ? Color.md3.surface_container_highest : "transparent")

                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: "󰸉"
                            font.family: "Jetbrains Mono Nerd Font Propo"
                            font.pixelSize: 15
                            color: panel.switcherOpen ? Color.md3.on_primary_container : (wpMouse.containsMouse ? Color.md3.primary : Color.md3.on_surface)
                        }

                        MouseArea {
                            id: wpMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: panel.switcherOpen = !panel.switcherOpen
                        }
                    }

                    Wifi { Layout.alignment: Qt.AlignVCenter }
                    Volume { Layout.alignment: Qt.AlignVCenter }
                    Battery { Layout.alignment: Qt.AlignVCenter }
                }
            }

            // --- WALLPAPER SWITCHER SECTION ---
            Item {
                id: switcherSection
                anchors.top: bar.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: panel.switcherHeight
                visible: panel.implicitHeight > panel.barHeight
                opacity: panel.openProgress

                transform: Translate {
                    y: -14 * (1 - panel.openProgress)
                }

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: Color.md3.outline_variant
                }

                WallpaperSwitcher {
                    anchors.fill: parent
                    onWallpaperSelected: panel.switcherOpen = false
                }
            }
        }
    }

    // --- OSD WINDOW ---
    OSD {}
}
