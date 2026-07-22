import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Row {
    id: workspacesRoot
    spacing: 6

    property int capAt: 5
    property int totalWorkspaces: 10

    property color activeColor: Color.md3.primary
    property color occupiedColor: Color.md3.on_surface
    property color emptyColor: Color.md3.outline
    property color pillColor: Color.md3.primary_container

    property var visibleWorkspaces: {
        var _a = Hyprland.workspaces.values.length
        var _b = Hyprland.focusedWorkspace

        var list = []
        for (var i = 1; i <= totalWorkspaces; i++) {
            if (i <= capAt) {
                list.push(i)
                continue
            }

            var ws = Hyprland.workspaces.values.find(function (w) { return w.id === i })
            var hasWindows = Boolean(ws && ws.toplevels && ws.toplevels.values.length > 0)
            var isFocused = Boolean(Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === i)

            if (hasWindows || isFocused) {
                list.push(i)
            }
        }
        return list
    }

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
            property bool isFocused: Boolean(Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === modelData)
            property bool hasWindows: Boolean(ws && ws.toplevels && ws.toplevels.values.length > 0)

            width: 26
            height: 26
            radius: 8
            color: isFocused ? workspacesRoot.pillColor : "transparent"

            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: modelData
                font.family: "Jetbrains Mono Nerd Font Propo"
                font.pixelSize: 13
                font.bold: pill.isFocused
                color: pill.isFocused ? Color.md3.on_primary_container
                       : pill.hasWindows ? workspacesRoot.occupiedColor
                       : workspacesRoot.emptyColor
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch('hl.dsp.focus({ workspace = "' + pill.modelData + '" })')
            }
        }
    }
}
