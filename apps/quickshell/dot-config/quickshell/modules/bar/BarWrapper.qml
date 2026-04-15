// modules/bar/BarWrapper.qml
// Animated reveal wrapper for the M3 sidebar bar.
// Handles slide-in/out animation, auto-hide on fullscreen, and hover-based
// visibility when Config.pending.bar.persistent is false.
//
// This item lives inside the PanelWindow in shell.qml (anchors.fill: parent).
// The PanelWindow owns the exclusive zone; BarWrapper handles animated content.
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland
import config
import services

Item {
    id: root

    // Passed in from shell.qml
    property bool dashboardVisible: false

    // Emitted when user clicks the dashboard toggle button inside Bar
    signal dashboardToggleRequested()

    readonly property bool persistent: Config.pending.bar?.persistent ?? true

    property bool _mouseOver: false
    property bool _fullscreen: {
        let w = Hyprland.activeWindow;
        return w ? (w.fullscreen ?? false) : false;
    }

    readonly property bool _shouldShow: !_fullscreen && (persistent || _mouseOver)

    clip: true
    anchors.fill: parent

    // --- Bar content ---
    Bar {
        id: bar
        dashboardVisible: root.dashboardVisible
        onDashboardToggled: root.dashboardToggleRequested()

        // Animate width: full (implicitWidth) when shown, 0 when hidden
        width: root._shouldShow ? implicitWidth : 0
        height: parent.height

        Behavior on width {
            NumberAnimation {
                duration: Appearance.anim.duration.expressiveDefault  // 500 ms
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.expressiveDefaultSpatial
            }
        }

        clip: true
        visible: width > 0
    }

    // Hover detection strip — active in auto-hide mode only.
    MouseArea {
        id: hoverStrip
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: root.persistent ? 0 : Math.max(bar.width, 8)
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        propagateComposedEvents: true

        onContainsMouseChanged: root._mouseOver = containsMouse
    }
}
