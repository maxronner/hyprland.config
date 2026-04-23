// panes/Network.qml
// Network pane: current connection display + WiFi placeholder.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import config
import services
import "../../../components"
import "../../../components/controls"

Item {
    id: root

    PaneScaffold {
        anchors.fill: parent
        title: "Network"

        // ---- Active connection card ----
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: connRow.implicitHeight + Appearance.padding.md * 2
            radius: Appearance.rounding.md
            color: Colours.tPalette.m3surfaceContainerHigh

            RowLayout {
                id: connRow
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: Appearance.padding.md
                }
                spacing: Appearance.spacing.sm

                MaterialIcon {
                    icon: {
                        if (NetworkService.connectionType === "wifi") return "wifi"
                        if (NetworkService.connectionType === "ethernet") return "lan"
                        return "wifi_off"
                    }
                    size: Appearance.font.xxl
                    color: NetworkService.status === "available"
                        ? Colours.tPalette.m3primary
                        : Colours.tPalette.m3onSurfaceVariant
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    StyledText {
                        text: NetworkService.status === "available"
                            ? NetworkService.activeConnection
                            : "Not connected"
                        font.pixelSize: Appearance.font.md
                        color: Colours.tPalette.m3onSurface
                        elide: Text.ElideRight
                    }

                    StyledText {
                        text: {
                            if (NetworkService.status === "loading") return "Connecting..."
                            if (NetworkService.connectionType === "wifi") return "Wi-Fi"
                            if (NetworkService.connectionType === "ethernet") return "Ethernet"
                            return "Disconnected"
                        }
                        font.pixelSize: Appearance.font.sm
                        color: Colours.tPalette.m3onSurfaceVariant
                    }
                }
            }
        }

        // ---- WiFi list placeholder ----
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Colours.tPalette.m3outlineVariant
            opacity: 0.5
        }

        StyledText {
            text: "Available Networks"
            font.pixelSize: Appearance.font.md
            color: Colours.tPalette.m3onSurfaceVariant
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: placeholderRow.implicitHeight + Appearance.padding.lg * 2
            radius: Appearance.rounding.md
            color: Colours.tPalette.m3surfaceContainerLow

            InfoRow {
                id: placeholderRow
                anchors.centerIn: parent
                icon: "info"
                primaryText: "Wi-Fi scan requires nmcli"
                primaryColor: Colours.tPalette.m3onSurfaceVariant
                iconColor: Colours.tPalette.m3onSurfaceVariant
            }
        }

        Item { implicitHeight: Appearance.padding.md }
    }
}
