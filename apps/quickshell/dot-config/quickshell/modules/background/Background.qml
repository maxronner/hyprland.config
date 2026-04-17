// modules/background/Background.qml
// Per-screen fullscreen background window. Renders wallpaper, desktop clock,
// and visualiser at WlrLayer.Background. The wallpaper is inset inside a
// rounded frame so the bar sits in the outer margin on the solid bg color.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import config
import services

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: win

        required property ShellScreen modelData

        // Left inset = bar width (bar sits flush against the wallpaper frame
        // and against the screen edge — no extra gap on this edge).
        readonly property real leftInset: Appearance.sizes.bar

        screen: modelData
        WlrLayershell.layer: WlrLayer.Background
        exclusionMode: ExclusionMode.Ignore
        surfaceFormat.opaque: false
        color: Colours.palette.m3surface

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        ClippingRectangle {
            id: frame
            color: "transparent"
            radius: Appearance.inset.radius
            anchors.fill: parent
            anchors.leftMargin: win.leftInset
            anchors.topMargin: Appearance.inset.gapOuter
            anchors.rightMargin: Appearance.inset.gapOuter
            anchors.bottomMargin: Appearance.inset.gapOuter

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
}
