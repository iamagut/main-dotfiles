pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    property alias server: notifServer
    property var popupList: []
    property bool centerOpen: false

    readonly property int maxPopups: 4
    readonly property int defaultTimeoutMs: 5000

    readonly property int trackedCount: {
        var vals = notifServer.trackedNotifications.values
        return vals ? vals.length : 0
    }

    function iconSource(notification) {
        if (!notification)
            return Quickshell.iconPath("preferences-system-notifications-symbolic", "dialog-information")
        if (notification.image && notification.image !== "")
            return notification.image
        if (notification.appIcon && notification.appIcon !== "") {
            if (notification.appIcon.startsWith("/") || notification.appIcon.startsWith("file:") || notification.appIcon.startsWith("image:"))
                return notification.appIcon.startsWith("/") ? ("file://" + notification.appIcon) : notification.appIcon
            return Quickshell.iconPath(notification.appIcon, "preferences-system-notifications-symbolic")
        }
        return Quickshell.iconPath("preferences-system-notifications-symbolic", "dialog-information")
    }

    function urgencyColor(urgency) {
        if (urgency === NotificationUrgency.Critical)
            return Colors.md3.error
        if (urgency === NotificationUrgency.Low)
            return Colors.md3.outline
        return Colors.md3.primary
    }

    function showPopup(notification) {
        if (centerOpen)
            return

        var list = []
        for (var i = 0; i < popupList.length; i++) {
            if (popupList[i] && popupList[i].id !== notification.id)
                list.push(popupList[i])
        }
        list.unshift(notification)
        while (list.length > maxPopups)
            list.pop()
        popupList = list
    }

    function hidePopup(notification) {
        if (!notification)
            return
        var list = []
        for (var i = 0; i < popupList.length; i++) {
            if (popupList[i] && popupList[i].id !== notification.id)
                list.push(popupList[i])
        }
        popupList = list
    }

    function clearPopups() {
        popupList = []
    }

    function dismissAll() {
        var tracked = notifServer.trackedNotifications.values || []
        for (var i = tracked.length - 1; i >= 0; i--) {
            if (tracked[i])
                tracked[i].dismiss()
        }
        popupList = []
    }

    function timeoutFor(notification) {
        var t = notification.expireTimeout
        if (t === 0)
            return 0
        if (t < 0)
            return defaultTimeoutMs
        return t < 100 ? (t * 1000) : t
    }

    NotificationServer {
        id: notifServer
        keepOnReload: true
        persistenceSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        actionsSupported: true
        actionIconsSupported: true
        imageSupported: true
        inlineReplySupported: false

        onNotification: function(notification) {
            notification.tracked = !notification.transient
            root.showPopup(notification)
            notification.closed.connect(function() {
                root.hidePopup(notification)
            })
        }
    }
}
