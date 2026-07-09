import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Row {
    id: workspacesRoot
    spacing: 6

    // Always-visible cap. Workspaces above this number only appear
    // when focused or when they contain at least one window.
    property int capAt: 5
    property int totalWorkspaces: 10

    property color activeColor: "#e0af68"
    property color occupiedColor: "#a9b1d6"
    property color emptyColor: "#5c5c5c"
    property color pillColor: "#00000055"

    // Recomputed whenever Hyprland's workspace/toplevel state changes.
    property var visibleWorkspaces: {
        // touch these so the binding re-evaluates on change
        var _a = Hyprland.workspaces.values.length
        var _b = Hyprland.focusedWorkspace

        var list = []
        for (var i = 1; i <= totalWorkspaces; i++) {
            if (i <= capAt) {
                list.push(i)
                continue
            }

            var ws = Hyprland.workspaces.values.find(function (w) { return w.id === i })
            var hasWindows = ws && ws.toplevels && ws.toplevels.values.length > 0
            var isFocused = Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === i

            if (hasWindows || isFocused) {
                list.push(i)
            }
        }
        return list
    }

    // Force refreshes so toplevel/workspace additions & removals are caught.
    Connections {
        target: Hyprland.workspaces
        function onObjectInsertedPost() { Hyprland.refreshWorkspaces() }
        function onObjectRemovedPost() { Hyprland.refreshWorkspaces() }
    }

    Repeater {
        model: workspacesRoot.visibleWorkspaces

        delegate: Rectangle {
            id: pill
            required property int modelData

            property var ws: Hyprland.workspaces.values.find(function (w) { return w.id === modelData })
            property bool isFocused: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === modelData
            property bool hasWindows: ws && ws.toplevels && ws.toplevels.values.length > 0

            width: 24
            height: 24
            radius: 8
            color: isFocused ? workspacesRoot.pillColor : "transparent"

            Behavior on color { ColorAnimation { duration: 120 } }

            Text {
                anchors.centerIn: parent
                text: modelData
                font.family: "Jetbrains Mono Nerd Font Propo"
                font.pixelSize: 14
                font.bold: pill.isFocused
                color: pill.isFocused ? workspacesRoot.activeColor
                       : pill.hasWindows ? workspacesRoot.occupiedColor
                       : workspacesRoot.emptyColor
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + pill.modelData)
            }
        }
    }
}
