// modules/background/Background.qml
// Per-screen fullscreen background window. Renders wallpaper, desktop clock,
// and visualiser at WlrLayer.Background.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import config
import services

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: win

        required property ShellScreen modelData

        screen: modelData
        WlrLayershell.layer: WlrLayer.Background
        exclusionMode: ExclusionMode.Ignore
        surfaceFormat.opaque: false
        color: "black"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        Wallpaper {
            anchors.fill: parent
            visible: Config.pending.background?.wallpaperEnabled ?? true
        }

        DesktopClock {
            visible: Config.pending.background?.desktopClock?.enabled ?? false
        }

        Visualiser {}
    }
}
