import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import Quickshell.Wayland

PanelWindow {
    id: centerWindow

    property bool centerOpen: false
    property real openProgress: 0

    readonly property int barHeight: 40
    readonly property int sidebarWidth: 420
    readonly property int cornerRadius: 16
    readonly property int bulgePadding: 16 // extra width on the left for shadow and fillet

    function toggle() { centerOpen = !centerOpen }
    function open() { centerOpen = true }
    function close() { centerOpen = false }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: centerOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    // Anchored directly to the top, bottom, and right edge of the screen
    anchors {
        top: true
        bottom: true
        right: true
    }

    implicitWidth: sidebarWidth + bulgePadding
    readonly property int availableHeight: centerWindow.height - barHeight

    visible: openProgress > 0.0001

    Behavior on openProgress {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }

    onCenterOpenChanged: {
        openProgress = centerOpen ? 1 : 0
        NotificationService.centerOpen = centerOpen
        if (centerOpen) {
            NotificationService.clearPopups()
            contentRoot.forceActiveFocus()
        }
    }

    readonly property bool hideForFullscreen: Boolean(Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.hasFullscreen)
    onHideForFullscreenChanged: {
        if (hideForFullscreen)
            centerOpen = false
    }

    // Input hit-test: only the visible region that has slid in under the bar receives input
    mask: Region {
        Region {
            shape: RegionShape.Rect
            x: Math.round(centerWindow.width - (centerWindow.openProgress * centerWindow.sidebarWidth))
            y: centerWindow.barHeight
            width: Math.round(centerWindow.openProgress * centerWindow.sidebarWidth)
            height: centerWindow.availableHeight
        }
    }

    // Fixed full-height sidebar shape with:
    //  - Top edge at Hbar (directly under the bar)
    //  - Concave fillet on top-left merging into the bottom of the bar
    //  - Straight vertical left wall all the way to the bottom
    //  - Sharp 90° bottom-left corner
    //  - Flat bottom edge reaching the bottom of the screen
    //  - Sharp 90° bottom-right corner flush to the monitor corner
    //  - Straight right wall flush to the screen edge
    readonly property string sidebarPathSvg: {
        var W = centerWindow.width
        var Hbar = centerWindow.barHeight
        var Ybottom = centerWindow.height
        var Xleft = bulgePadding
        var Xright = W
        var R = cornerRadius

        return "M " + Xright + " " + Hbar + " " +
               "L " + Xright + " " + Ybottom + " " +
               "L " + Xleft + " " + Ybottom + " " +
               "L " + Xleft + " " + (Hbar + R) + " " +
               "A " + R + " " + R + " 0 0 0 " + (Xleft - R) + " " + Hbar + " " +
               "Z"
    }

    // Entire panel slides horizontally from the right:
    // At openProgress=0, it is translated right by sidebarWidth (off-screen).
    // At openProgress=1, it is translated by 0 (fully visible).
    Item {
        id: container
        anchors.fill: parent
        opacity: centerWindow.openProgress
        visible: opacity > 0.0001

        transform: Translate {
            x: Math.round((1 - centerWindow.openProgress) * centerWindow.sidebarWidth)
        }

        // Sidebar background with smooth drop shadow
        Shape {
            id: sidebarShape
            anchors.fill: parent
            containsMode: Shape.FillContains
            preferredRendererType: Shape.CurveRenderer

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, 0.22)
                shadowBlur: 0.35
                shadowVerticalOffset: 0
                shadowHorizontalOffset: -3
            }

            ShapePath {
                fillColor: Colors.md3.background
                strokeWidth: 0

                PathSvg {
                    path: centerWindow.sidebarPathSvg
                }
            }
        }

        // Sidebar content container
        Item {
            id: contentRoot
            anchors.top: parent.top
            anchors.topMargin: centerWindow.barHeight
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            width: centerWindow.sidebarWidth
            focus: centerWindow.centerOpen

            Keys.onEscapePressed: centerWindow.close()

            component NotificationCard: Rectangle {
                id: card

                property var notification

                radius: 14
                color: Colors.md3.surface_container_high
                border.width: 1
                border.color: NotificationService.urgencyColor(notification ? notification.urgency : NotificationUrgency.Normal)
                clip: true

                implicitHeight: cardColumn.implicitHeight + 24

                ColumnLayout {
                    id: cardColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Rectangle {
                            width: 42
                            height: 42
                            radius: 10
                            color: Colors.md3.surface_container_highest
                            clip: true

                            Image {
                                anchors.fill: parent
                                anchors.margins: 4
                                source: card.notification ? NotificationService.iconSource(card.notification) : ""
                                sourceSize.width: 34
                                sourceSize.height: 34
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                                smooth: true
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Text {
                                    Layout.fillWidth: true
                                    text: card.notification ? (card.notification.appName || "Notification") : ""
                                    font.family: "Jetbrains Mono Nerd Font Propo"
                                    font.pixelSize: 11
                                    color: Colors.md3.on_surface_variant
                                    elide: Text.ElideRight
                                }

                                Rectangle {
                                    width: 8
                                    height: 8
                                    radius: 4
                                    color: NotificationService.urgencyColor(card.notification ? card.notification.urgency : NotificationUrgency.Normal)
                                    visible: card.notification && card.notification.urgency === NotificationUrgency.Critical
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: card.notification ? (card.notification.summary || "") : ""
                                font.family: "Jetbrains Mono Nerd Font Propo"
                                font.pixelSize: 13
                                font.bold: true
                                color: Colors.md3.on_surface
                                elide: Text.ElideRight
                                maximumLineCount: 2
                                wrapMode: Text.Wrap
                            }
                        }

                        Rectangle {
                            width: 26
                            height: 26
                            radius: 13
                            color: closeMouse.containsMouse ? Colors.md3.error_container : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "󰅖"
                                font.family: "Jetbrains Mono Nerd Font Propo"
                                font.pixelSize: 14
                                color: closeMouse.containsMouse ? Colors.md3.on_error_container : Colors.md3.on_surface_variant
                            }

                            MouseArea {
                                id: closeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (card.notification)
                                        card.notification.dismiss()
                                }
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: card.notification && card.notification.body && card.notification.body.length > 0
                        text: card.notification ? card.notification.body : ""
                        font.family: "Jetbrains Mono Nerd Font Propo"
                        font.pixelSize: 12
                        color: Colors.md3.on_surface_variant
                        wrapMode: Text.Wrap
                        maximumLineCount: 8
                        elide: Text.ElideRight
                        textFormat: Text.StyledText
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        visible: card.notification && card.notification.actions && card.notification.actions.length > 0

                        Repeater {
                            model: card.notification ? card.notification.actions : []

                            delegate: Rectangle {
                                required property var modelData

                                height: 28
                                width: actionLabel.implicitWidth + 16
                                radius: 8
                                color: actionMouse.containsMouse ? Colors.md3.primary : Colors.md3.surface_container_highest
                                border.color: Colors.md3.outline_variant
                                border.width: 1

                                Text {
                                    id: actionLabel
                                    anchors.centerIn: parent
                                    text: modelData.text || "Action"
                                    font.family: "Jetbrains Mono Nerd Font Propo"
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: actionMouse.containsMouse ? Colors.md3.on_primary : Colors.md3.on_surface
                                }

                                MouseArea {
                                    id: actionMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: modelData.invoke()
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        text: "󰂚 Notifications"
                        font.family: "Jetbrains Mono Nerd Font Propo"
                        font.pixelSize: 15
                        font.bold: true
                        color: Colors.md3.primary
                    }

                    Text {
                        text: "(" + NotificationService.trackedCount + ")"
                        font.family: "Jetbrains Mono Nerd Font Propo"
                        font.pixelSize: 12
                        color: Colors.md3.on_surface_variant
                    }

                    Item { Layout.fillWidth: true }

                    RowLayout {
                        spacing: 4
                        opacity: 0.8
                        Text { text: "Esc"; font.family: "Jetbrains Mono Nerd Font Propo"; font.pixelSize: 11; font.bold: true; color: Colors.md3.primary }
                        Text { text: "Close"; font.family: "Jetbrains Mono Nerd Font Propo"; font.pixelSize: 11; color: Colors.md3.on_surface_variant }
                    }

                    Rectangle {
                        width: clearText.implicitWidth + 18
                        height: 30
                        radius: 8
                        color: clearMouse.containsMouse ? Colors.md3.error_container : Colors.md3.surface_container_low
                        border.color: Colors.md3.outline_variant
                        border.width: 1
                        visible: NotificationService.trackedCount > 0

                        Text {
                            id: clearText
                            anchors.centerIn: parent
                            text: "Clear all"
                            font.family: "Jetbrains Mono Nerd Font Propo"
                            font.pixelSize: 11
                            font.bold: true
                            color: clearMouse.containsMouse ? Colors.md3.on_error_container : Colors.md3.error
                        }

                        MouseArea {
                            id: clearMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: NotificationService.dismissAll()
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Colors.md3.outline_variant
                    opacity: 0.5
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        visible: NotificationService.trackedCount === 0

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰂛"
                            font.family: "Jetbrains Mono Nerd Font Propo"
                            font.pixelSize: 40
                            color: Colors.md3.on_surface_variant
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "All caught up"
                            font.family: "Jetbrains Mono Nerd Font Propo"
                            font.pixelSize: 14
                            font.bold: true
                            color: Colors.md3.on_surface
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "No notifications right now"
                            font.family: "Jetbrains Mono Nerd Font Propo"
                            font.pixelSize: 11
                            color: Colors.md3.on_surface_variant
                        }
                    }

                    ListView {
                        id: notifList
                        anchors.fill: parent
                        clip: true
                        spacing: 10
                        visible: NotificationService.trackedCount > 0
                        model: NotificationService.server.trackedNotifications

                        delegate: Item {
                            id: listDelegate
                            required property var modelData
                            width: notifList.width
                            height: listCard.implicitHeight

                            NotificationCard {
                                id: listCard
                                width: parent.width
                                notification: listDelegate.modelData
                            }
                        }
                    }
                }
            }
        }
    }
}
