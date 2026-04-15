// modules/bar/widgets/Notifications.qml
// Bell icon with badge. Data from NotificationService.
// Click opens control center notifications pane via IPC.
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import config
import services
import "../../../components"

WidgetContainer {
    id: root

    interactive: true

    onClicked: ipcProc.running = true

    Process {
        id: ipcProc
        command: ["qs", "ipc", "call", "open-controlcenter-pane", "open", "3"]
        running: false
    }

    tooltip: NotificationService.count > 0
        ? "Notifications: " + NotificationService.count
        : "No notifications"

    MaterialIcon {
        anchors.centerIn: parent
        icon: NotificationService.count > 0 ? "notifications_active" : "notifications"
        size: Appearance.font.xl
        fill: NotificationService.count > 0 ? 1 : 0
        fillAnimated: true
        color: NotificationService.count > 0
            ? Colours.tPalette.m3primary
            : Colours.tPalette.m3onSurfaceVariant
    }

    // Badge showing notification count (shown when > 0)
    Rectangle {
        visible: NotificationService.count > 0
        anchors {
            top: parent.top
            right: parent.right
            topMargin: 2
            rightMargin: 2
        }
        width: Math.max(14, badgeText.implicitWidth + 4)
        height: 14
        radius: 7
        color: Colours.tPalette.m3error

        StyledText {
            id: badgeText
            anchors.centerIn: parent
            text: NotificationService.count > 99 ? "99+" : String(NotificationService.count)
            color: Colours.tPalette.m3onError
            font.pixelSize: Appearance.font.sm - 2
            font.bold: true
        }
    }
}
