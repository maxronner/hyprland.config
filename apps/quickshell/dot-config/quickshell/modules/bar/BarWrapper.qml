// modules/bar/BarWrapper.qml
// Reveal wrapper for the M3 sidebar bar.
// Handles fullscreen/auto-hide width changes and hover-based
// visibility when Config.pending.bar.persistent is false.
//
// This item lives inside the PanelWindow in shell.qml (anchors.fill: parent).
// The PanelWindow owns the exclusive zone; BarWrapper handles the bar content.
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import config
import services

Item {
    id: root

    // Passed in from shell.qml
    property bool dashboardVisible: false
    property bool fullscreen: false

    // Emitted when user clicks the dashboard toggle button inside Bar
    signal dashboardToggleRequested()

    readonly property bool persistent: Config.pending.bar?.persistent ?? true

    property bool _mouseOver: false
    readonly property bool _shouldShow: !fullscreen && (persistent || _mouseOver)
    readonly property real contentWidth: bar.width

    clip: true
    anchors.fill: parent

    // --- Bar content ---
    Bar {
        id: bar
        dashboardVisible: root.dashboardVisible
        onDashboardToggled: root.dashboardToggleRequested()

        width: root._shouldShow ? implicitWidth : 0
        height: parent.height

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
