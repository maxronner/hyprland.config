// modules/background/Background.qml
// Per-screen fullscreen background window. Renders wallpaper, desktop clock,
// and visualiser at WlrLayer.Background. The wallpaper is inset inside a
// rounded frame so the bar sits in the outer margin on the solid bg color.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import config
import services

Variants {
    id: root

    property real leftInsetWidth: Appearance.sizes.bar
    property bool barVisible: true

    model: Quickshell.screens

    PanelWindow {
        id: win

        required property ShellScreen modelData

        readonly property var monitor: Hyprland.monitorFor(win.modelData)
        readonly property bool monitorFullscreen: monitor?.activeWorkspace?.hasFullscreen ?? false
        readonly property bool barSuppressed: !root.barVisible || win.monitorFullscreen
        readonly property real leftInset: win.barSuppressed ? Appearance.inset.gapOuter : root.leftInsetWidth

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
