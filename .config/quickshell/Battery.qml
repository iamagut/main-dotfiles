import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower

RowLayout {
    id: batteryRoot
    spacing: 6

    property var battery: UPower.displayDevice
    
    property bool charging: battery.state === UPowerDeviceState.Charging
    readonly property int level: Math.round(battery.percentage * 100)

    readonly property string icon: {
        if (charging) return String.fromCodePoint(0xF0084)
        
        // Safe fallback glyph hex values so the function does not crash
        if (level >= 100) return String.fromCodePoint(0xF0079) // 100% full icon
        if (level < 10) return String.fromCodePoint(0xF0083)  // Empty warning icon
        
        return String.fromCodePoint(0xF007A + Math.floor(level / 10) - 1)
    }

    Text {
        text: batteryRoot.icon
        color: batteryRoot.charging ? '#74ff6f'
                             : batteryRoot.level <= 15 ? '#ffe72d'
                             : batteryRoot.level <= 30 ? '#d4ff65'
                             : 'white'

        font.pixelSize: 14
        font.family: "Jetbrains Mono Nerd Font Propo"
    }

    Text {
        text: batteryRoot.level + '%'
        color: "white"
        font.pixelSize: 14
        font.family: "Jetbrains Mono Nerd Font Propo"
    }
}
