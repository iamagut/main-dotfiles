import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking

Row {
    id: wifiRoot
    spacing: 6

    property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi)
    property var active: wifiDevice ? wifiDevice.networks.values.find(n => n.connected) : null 

    readonly property real signal: active ? active.signalStrength : 0

    readonly property string icon: {
        if (!Networking.wifiEnabled) return '󰤮'
        if (!active) return '󰤯'

        let tier = signal >= 0.75 ? 4
                 : signal >= 0.5 ? 3
                 : signal >= 0.25 ? 2
                 : 1

        return String.fromCodePoint(0xF091F + (tier - 1) * 3)
    }

    Text {
        text: wifiRoot.icon
        font.pixelSize: 14
        font.family: 'Jetbrains Mono Nerd Font Propo'
        color: Networking.wifiEnabled ? (wifiRoot.active ? Color.md3.primary : Color.md3.outline) : Color.md3.error
    }

    Text {
        text: {
            if (!Networking.wifiEnabled) return 'Off'
            if (!wifiRoot.active) return 'Disconnected'
            return wifiRoot.active.name
        }

        color: wifiRoot.active ? Color.md3.on_surface : Color.md3.on_surface_variant
        font.pixelSize: 14
        font.family: 'Jetbrains Mono Nerd Font Propo'
    }
}
