// modules/bar/widgets/IdleInhibitor.qml
// Idle inhibitor toggle. Active: lock icon with m3tertiary color.
// Inactive: lock_open with m3onSurfaceVariant.
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import config
import services
import "../../../components"

WidgetContainer {
    id: root

    interactive: true

    property bool inhibited: false

    tooltip: inhibited ? "Idle inhibitor: on" : "Idle inhibitor: off"

    onClicked: {
        root.inhibited = !root.inhibited;
        inhibitProc.running = root.inhibited;
    }

    MaterialIcon {
        anchors.centerIn: parent
        icon: root.inhibited ? "lock" : "lock_open"
        size: Appearance.font.xl
        fill: root.inhibited ? 1 : 0
        fillAnimated: true
        color: root.inhibited ? Colours.tPalette.m3tertiary : Colours.tPalette.m3onSurfaceVariant
    }

    Process {
        id: inhibitProc
        command: ["systemd-inhibit", "--what=idle", "--who=quickshell", "--why=User request", "--mode=block", "sleep", "infinity"]
        running: false
    }
}
