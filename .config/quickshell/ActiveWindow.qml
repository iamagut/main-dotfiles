import QtQuick
import Quickshell
import Quickshell.Hyprland

Item {
    id: root

    property int maxWidth: 320
    property int fontSize: 14
    property string fontFamily: "Jetbrains Mono Nerd Font Propo"
    // Match Workspaces.itemSize so we share the same vertical band
    // (underline hangs below and shouldn't shift this text).
    property int contentHeight: 20
    // Manual fine-tune in pixels (positive = down) if it still looks off.
    property real verticalOffset: 10

    readonly property var toplevel: Hyprland.activeToplevel
    readonly property string title: toplevel ? (toplevel.title || "") : ""
    readonly property string appClass: {
        if (!toplevel || !toplevel.lastIpcObject)
            return ""
        return toplevel.lastIpcObject.class || toplevel.lastIpcObject.initialClass || ""
    }
    readonly property bool hasWindow: title !== "" || appClass !== ""
    readonly property string displayText: title || appClass || "Desktop"

    // What is actually painted. Lags displayText only during a window-switch fade.
    property string shownText: displayText
    property bool fadingOut: false

    implicitWidth: Math.min(Math.ceil(metrics.advanceWidth), maxWidth)
    implicitHeight: contentHeight
    width: implicitWidth
    height: implicitHeight
    opacity: hasWindow ? 1 : 0.55

    // Measures the *target* text so the width animates in step with the fade.
    TextMetrics {
        id: metrics
        font: textItem.font
        text: root.displayText
    }

    FontMetrics {
        id: fm
        font: textItem.font
    }

    Text {
        id: textItem
        // Centre the cap-height band (where digits and capitals sit) on the
        // bar's midline instead of centring the whole line box. The line box
        // includes descender space, which makes text look elevated next to
        // the workspace numbers and clock.
        y: Math.round(root.height / 2 + fm.capHeight / 2 - baselineOffset + root.verticalOffset)
        width: root.width
        text: root.shownText
        color: Colors.md3.on_surface
        font.pixelSize: root.fontSize
        font.family: root.fontFamily
        elide: Text.ElideRight
        maximumLineCount: 1
        // Window titles are untrusted; never let them be parsed as rich text.
        textFormat: Text.PlainText
    }

    // Title changes within the same window (tab switches, terminal titles)
    // update instantly; only switching windows gets the fade, so noisy
    // titles don't flicker.
    onToplevelChanged: {
        swap.restart()
        // lastIpcObject can be empty right after focus moves; pull fresh data.
        if (toplevel && !appClass)
            Hyprland.refreshToplevels()
    }

    onDisplayTextChanged: {
        if (!fadingOut)
            shownText = displayText
    }

    SequentialAnimation {
        id: swap

        ScriptAction { script: root.fadingOut = true }
        NumberAnimation {
            target: textItem
            property: "opacity"
            to: 0
            duration: 70
            easing.type: Easing.InQuad
        }
        ScriptAction {
            script: {
                root.fadingOut = false
                root.shownText = root.displayText
            }
        }
        NumberAnimation {
            target: textItem
            property: "opacity"
            to: 1
            duration: 110
            easing.type: Easing.OutQuad
        }
    }

    Behavior on implicitWidth {
        NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
    }

    Behavior on opacity {
        NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
    }
}
