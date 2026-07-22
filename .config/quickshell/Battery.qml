import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower

RowLayout {
    id: batteryRoot
    spacing: 6

    property var battery: UPower.displayDevice
    
    readonly property bool charging: battery ? battery.state === UPowerDeviceState.Charging : false
    readonly property int level: battery ? Math.round(battery.percentage * 100) : 0

    readonly property string icon: {
        if (charging) return String.fromCodePoint(0xF0084)
        
        if (level >= 100) return String.fromCodePoint(0xF0079)
        if (level < 10) return String.fromCodePoint(0xF0083)
        
        return String.fromCodePoint(0xF007A + Math.floor(level / 10) - 1)
    }

    Text {
        text: batteryRoot.icon
        color: batteryRoot.charging ? Color.md3.primary
                             : batteryRoot.level <= 15 ? Color.md3.error
                             : batteryRoot.level <= 30 ? Color.md3.tertiary
                             : Color.md3.on_surface

        font.pixelSize: 14
        font.family: "Jetbrains Mono Nerd Font Propo"
    }

    Text {
        text: batteryRoot.level + '%'
        color: Color.md3.on_surface
        font.pixelSize: 14
        font.family: "Jetbrains Mono Nerd Font Propo"
    }
}
