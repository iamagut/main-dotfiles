import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

ShellRoot {
    PanelWindow {
        id: panel
        anchors {
            top: true
            // If you want a full-width top bar, these should usually be true.
            // If you want a floating pill-shaped bar, keep them false.
            left: false
            right: false
        }

        // --- Sizing ---
        readonly property int barHeight: 37
        readonly property int switcherHeight: 220
        property bool switcherOpen: false

        implicitWidth: 1000
        implicitHeight: barHeight + (switcherOpen ? switcherHeight : 0)

        // Easing animation for the downward expand/collapse
        Behavior on implicitHeight {
            NumberAnimation { duration: 320; easing.type: Easing.InOutCubic }
        }

        color: "transparent"

        Item {
            anchors.fill: parent

            // --- TOP BAR ---
            Rectangle {
                id: bar
                width: parent.width
                height: panel.barHeight
                bottomLeftRadius: panel.switcherOpen ? 0 : 15
                bottomRightRadius: panel.switcherOpen ? 0 : 15
                color: "brown"

                Behavior on bottomLeftRadius { NumberAnimation { duration: 200 } }
                Behavior on bottomRightRadius { NumberAnimation { duration: 200 } }

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
                Row {
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 14
                    }
                    spacing: 30

                    Wifi {}
                    Volume {}
                    Battery {}
                }
            }
        }
    }
}
