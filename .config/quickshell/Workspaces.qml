import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Item {
    id: workspacesRoot

    property int capAt: 5
    property int totalWorkspaces: 10

    property color activeColor: Colors.md3.primary
    property color occupiedColor: Colors.md3.on_surface
    property color emptyColor: Colors.md3.outline

    property int itemSize: 20
    property int fontSize: 14
    property real hoverScale: 1

    property int underlineHeight: 2
    property int underlineBottomMargin: -5
    property int underlineAnimDuration: 150

    implicitWidth: pillsRow.implicitWidth
    implicitHeight: pillsRow.implicitHeight

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

    onVisibleWorkspacesChanged: Qt.callLater(updateUnderline)

    Connections {
        target: Hyprland.workspaces
        function onObjectInsertedPost() { Hyprland.refreshWorkspaces() }
        function onObjectRemovedPost() { Hyprland.refreshWorkspaces() }
    }

    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() { Qt.callLater(updateUnderline) }
    }

    function updateUnderline() {
        var focusedId = Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1
        var idx = visibleWorkspaces.indexOf(focusedId)
        if (idx < 0) return

        var item = repeater.itemAt(idx)
        if (!item) return

        var pos = item.mapToItem(workspacesRoot, 0, 0)
        underline.targetX = pos.x
        underline.targetWidth = item.width
    }

    Row {
        id: pillsRow
        spacing: 10

        Repeater {
            id: repeater
            model: workspacesRoot.visibleWorkspaces

            delegate: Item {
                id: pill
                required property int modelData

                property var ws: Hyprland.workspaces.values.find(function (w) { return w.id === modelData })
                property bool isFocused: Boolean(Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === modelData)
                property bool hasWindows: Boolean(ws && ws.toplevels && ws.toplevels.values.length > 0)
                property bool hovered: mouseArea.containsMouse

                width: Math.max(workspacesRoot.itemSize, numberText.paintedWidth + 6)
                height: workspacesRoot.itemSize

                scale: hovered ? workspacesRoot.hoverScale : 1.0
                Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }

                onIsFocusedChanged: if (isFocused) Qt.callLater(workspacesRoot.updateUnderline)
                onWidthChanged: if (isFocused) Qt.callLater(workspacesRoot.updateUnderline)
                Component.onCompleted: if (isFocused) Qt.callLater(workspacesRoot.updateUnderline)

                Text {
                    id: numberText
                    anchors.centerIn: parent
                    text: pill.modelData
                    font.family: "Jetbrains Mono Nerd Font Propo"
                    font.pixelSize: workspacesRoot.fontSize
                    font.bold: pill.isFocused
                    color: pill.isFocused ? workspacesRoot.activeColor
                           : pill.hasWindows ? workspacesRoot.occupiedColor
                           : workspacesRoot.emptyColor

                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    anchors.margins: -4
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch('hl.dsp.focus({ workspace = "' + pill.modelData + '" })')
                }
            }
        }
    }

    Rectangle {
        id: underline
        property real targetX: 0
        property real targetWidth: 0

        y: pillsRow.height - height - workspacesRoot.underlineBottomMargin
        height: workspacesRoot.underlineHeight
        radius: height / 2
        color: workspacesRoot.activeColor

        x: targetX
        width: targetWidth

        Behavior on x { NumberAnimation { duration: workspacesRoot.underlineAnimDuration; easing.type: Easing.OutCubic } }
        Behavior on width { NumberAnimation { duration: workspacesRoot.underlineAnimDuration; easing.type: Easing.OutCubic } }
    }
}
