// panes/Notifications.qml
// Notifications pane: DND toggle, notification list, clear all button.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications
import config
import services
import "../../../components"
import "../../../components/controls"

Item {
    id: root

    Flickable {
        anchors.fill: parent
        anchors.margins: Appearance.padding.lg
        contentHeight: layout.implicitHeight
        clip: true

        ColumnLayout {
            id: layout
            width: parent.width
            spacing: Appearance.spacing.md

            // ---- Header row ----
            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.sm

                StyledText {
                    Layout.fillWidth: true
                    text: "Notifications"
                    font.pixelSize: Appearance.font.xl
                    color: Colours.tPalette.m3onSurface
                }

                // DND toggle
                RowLayout {
                    spacing: Appearance.spacing.xs

                    MaterialIcon {
                        icon: NotificationService.dndEnabled ? "do_not_disturb_on" : "notifications_active"
                        size: Appearance.font.lg
                        color: Colours.tPalette.m3onSurfaceVariant
                    }

                    ToggleButton {
                        checked: NotificationService.dndEnabled
                        onToggled: NotificationService.toggleDnd()
                    }
                }
            }

            // ---- Clear all button ----
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: Appearance.sizes.button
                radius: Appearance.rounding.sm
                color: Colours.tPalette.m3surfaceContainerHigh
                visible: notifRepeater.count > 0

                RowLayout {
                    anchors.centerIn: parent
                    spacing: Appearance.spacing.xs

                    MaterialIcon {
                        icon: "clear_all"
                        size: Appearance.font.lg
                        color: Colours.tPalette.m3onSurface
                    }

                    StyledText {
                        text: "Clear all"
                        color: Colours.tPalette.m3onSurface
                    }
                }

                StateLayer {
                    radius: parent.radius
                    color: Colours.palette.m3onSurface
                    clipRipple: true
                    onTapped: NotificationService.dismissAll()
                }
            }

            // ---- Empty state ----
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 80
                radius: Appearance.rounding.md
                color: Colours.tPalette.m3surfaceContainerLow
                visible: notifRepeater.count === 0

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Appearance.spacing.xs

                    MaterialIcon {
                        Layout.alignment: Qt.AlignHCenter
                        icon: "notifications_none"
                        size: Appearance.font.xxl
                        color: Colours.tPalette.m3onSurfaceVariant
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: "No notifications"
                        color: Colours.tPalette.m3onSurfaceVariant
                        font.pixelSize: Appearance.font.sm
                    }
                }
            }

            // ---- Notification cards ----
            Repeater {
                id: notifRepeater
                model: NotificationService.notifications

                delegate: NotificationCard {
                    required property var modelData

                    Layout.fillWidth: true
                    appName: modelData.appName || ""
                    appIcon: modelData.appIcon || ""
                    summary: modelData.summary || ""
                    body: modelData.body || ""
                    image: modelData.image || ""
                    urgency: modelData.urgency ?? NotificationUrgency.Normal
                    onDismissed: NotificationService.dismiss(modelData)
                }
            }

            Item { implicitHeight: Appearance.padding.md }
        }
    }
}
