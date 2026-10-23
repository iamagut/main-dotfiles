import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland

Item {
    id: root

    readonly property int popupWidth: 360
    readonly property int barOffset: 52

    component NotificationCard: Rectangle {
        id: card

        property var notification
        property bool compact: true

        signal closeRequested()
        signal activated()

        radius: 14
        color: Colors.md3.surface_container_high
        border.width: 1
        border.color: NotificationService.urgencyColor(notification ? notification.urgency : NotificationUrgency.Normal)
        clip: true

        implicitHeight: cardColumn.implicitHeight + 20

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, 0.22)
            shadowBlur: 0.35
            shadowVerticalOffset: 3
            shadowHorizontalOffset: 0
        }

        ColumnLayout {
            id: cardColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 10
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    width: 36
                    height: 36
                    radius: 10
                    color: Colors.md3.surface_container_highest
                    clip: true

                    Image {
                        anchors.fill: parent
                        anchors.margins: 4
                        source: card.notification ? NotificationService.iconSource(card.notification) : ""
                        sourceSize.width: 28
                        sourceSize.height: 28
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        smooth: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        text: card.notification ? (card.notification.appName || "Notification") : ""
                        font.family: "Jetbrains Mono Nerd Font Propo"
                        font.pixelSize: 11
                        color: Colors.md3.on_surface_variant
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: card.notification ? (card.notification.summary || "") : ""
                        font.family: "Jetbrains Mono Nerd Font Propo"
                        font.pixelSize: 12
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
                            card.closeRequested()
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
                maximumLineCount: 3
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
                            onClicked: {
                                modelData.invoke()
                                card.activated()
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }

        MouseArea {
            anchors.fill: parent
            z: -1
            cursorShape: Qt.PointingHandCursor
            onClicked: card.activated()
        }
    }

    PanelWindow {
        id: popupWindow

        WlrLayershell.layer: WlrLayer.Overlay
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        anchors {
            top: true
            right: true
        }
        margins {
            top: root.barOffset
            right: 14
        }

        implicitWidth: root.popupWidth
        implicitHeight: Math.max(1, popupColumn.implicitHeight)

        visible: NotificationService.popupList.length > 0 && !NotificationService.centerOpen

        mask: Region {
            Region {
                shape: RegionShape.Rect
                x: 0
                y: 0
                width: NotificationService.popupList.length > 0 && !NotificationService.centerOpen ? popupWindow.width : 0
                height: NotificationService.popupList.length > 0 && !NotificationService.centerOpen ? popupWindow.height : 0
            }
        }

        Column {
            id: popupColumn
            width: parent.width
            spacing: 10

            Repeater {
                model: NotificationService.popupList

                delegate: Item {
                    id: popupDelegate
                    required property var modelData
                    required property int index

                    readonly property var notif: modelData

                    width: popupColumn.width
                    height: popupCard.implicitHeight

                    property bool shown: false

                    Component.onCompleted: shown = true

                    opacity: shown ? 1 : 0
                    transform: Translate {
                        x: shown ? 0 : 40
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                    }

                    NotificationCard {
                        id: popupCard
                        width: parent.width
                        notification: popupDelegate.notif

                        onCloseRequested: NotificationService.hidePopup(popupDelegate.notif)
                        onActivated: {
                            NotificationService.hidePopup(popupDelegate.notif)
                        }
                    }

                    Timer {
                        interval: popupDelegate.notif ? NotificationService.timeoutFor(popupDelegate.notif) : NotificationService.defaultTimeoutMs
                        running: interval > 0 && !NotificationService.centerOpen && popupDelegate.notif
                        repeat: false
                        onTriggered: {
                            var n = popupDelegate.notif
                            NotificationService.hidePopup(n)
                            if (n && n.transient)
                                n.expire()
                        }
                    }
                }
            }
        }
    }
}
