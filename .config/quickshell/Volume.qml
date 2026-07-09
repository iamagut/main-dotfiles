import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

RowLayout {
    id: volumeRoot
    spacing: 6

    property var sink: Pipewire.defaultAudioSink
    
    readonly property bool ready: sink && sink.ready
    readonly property bool muted: ready && sink.audio.muted
    readonly property int vol: ready ? Math.round(sink.audio.volume * 100) : 0

    readonly property string icon: {
        if (!ready) return String.fromCodePoint(0xF0581)
        if (muted) return ""
        if (vol === 0) return ''
        if (vol < 50) return ''
        if (vol < 100) return ''

        return ''
    }

    Text {
        text: volumeRoot.icon
        color: 'white'
        font.pixelSize: 14
        font.family: 'Jetbrains Mono Nerd Font Propo'
    }

    Text {
        text: {
            if (!volumeRoot.ready) return '-'
            if (volumeRoot.muted) return 'Muted'
            return volumeRoot.vol + '%'
        }
        color: volumeRoot.muted ? "red" : "white"
        font.pixelSize: 14
        font.family: 'Jetbrains Mono Nerd Font Propo'
    }

    PwObjectTracker {
        objects: {volumeRoot.sink}
    }
}
