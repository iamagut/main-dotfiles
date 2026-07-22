import QtQuick
import Quickshell

Row {
    id: clockRoot
    spacing: 6

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

    Text {
        text: Qt.formatDateTime(systemClock.date, "hh:mm")
        color: Color.md3.on_surface
        font.pixelSize: 14
        font.bold: true
        font.family: "Jetbrains Mono Nerd Font Propo"
    }
}