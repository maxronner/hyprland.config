// modules/bar/BarSurfaces.qml
// Per-screen top-layer bar surfaces that own reservation and visibility.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import config

Variants {
    id: root

    property real leftFrameWidth: Math.max(Appearance.sizes.bar, Appearance.inset.gapOuter)
    property bool dashboardVisible: false
    property bool barVisible: true

    signal dashboardToggleRequested()

    model: Quickshell.screens

    Item {
        id: surface

        required property ShellScreen modelData
        readonly property real leftFrameWidth: root.leftFrameWidth

        PanelWindow {
            id: reservePanel

            screen: surface.modelData

            anchors {
                top: true
                left: true
                bottom: true
            }

            implicitWidth: surface.leftFrameWidth

            margins {
                top: 0
                bottom: 0
            }

            exclusionMode: ExclusionMode.Normal
            exclusiveZone: root.barVisible ? Math.round(surface.leftFrameWidth) : 0
            WlrLayershell.layer: WlrLayer.Bottom
            focusable: false
            visible: root.barVisible

            color: "transparent"
        }

        PanelWindow {
            id: barPanel

            readonly property var monitor: Hyprland.monitorFor(surface.modelData)
            readonly property bool monitorFullscreen: monitor?.activeWorkspace?.hasFullscreen ?? false
            readonly property bool wrapperFullscreen: !root.barVisible || barPanel.monitorFullscreen

            screen: surface.modelData

            anchors {
                top: true
                left: true
                bottom: true
            }

            implicitWidth: surface.leftFrameWidth

            margins {
                top: 0
                bottom: 0
            }

            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Top
            focusable: false
            visible: root.barVisible

            color: "transparent"

            BarWrapper {
                anchors.fill: parent
                dashboardVisible: root.dashboardVisible
                fullscreen: barPanel.wrapperFullscreen
                onDashboardToggleRequested: root.dashboardToggleRequested()
            }
        }
    }
}
