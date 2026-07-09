import QtQuick
import Quickshell

Row {
    id: clockRoot
    spacing: 6

    SystemClock {
        id: systemClock
        precision: SystemClock.minutes
    }

    // Time Text
    Text {
        text: Qt.formatDateTime(systemClock.date, "hh:mm")
        color: 'white'
        font.pixelSize: 14
        font.family: "Jetbrains Mono Nerd Font Propo"
    }
}