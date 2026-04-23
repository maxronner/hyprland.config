// panes/Bluetooth.qml
// Bluetooth pane: power toggle + connected device display.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import config
import services
import "../../../components"
import "../../../components/controls"

Item {
    id: root

    PaneScaffold {
        anchors.fill: parent
        title: "Bluetooth"

            // ---- Power toggle row ----
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: powerRow.implicitHeight + Appearance.padding.md * 2
                radius: Appearance.rounding.md
                color: Colours.tPalette.m3surfaceContainerHigh

                RowLayout {
                    id: powerRow
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        margins: Appearance.padding.md
                    }
                    spacing: Appearance.spacing.sm

                    MaterialIcon {
                        icon: BluetoothService.powered ? "bluetooth" : "bluetooth_disabled"
                        size: Appearance.font.xxl
                        fill: BluetoothService.powered ? 1 : 0
                        color: BluetoothService.powered
                            ? Colours.tPalette.m3primary
                            : Colours.tPalette.m3onSurfaceVariant

                        Behavior on color { CAnim {} }
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: "Bluetooth"
                        font.pixelSize: Appearance.font.md
                        color: Colours.tPalette.m3onSurface
                    }

                    ToggleButton {
                        checked: BluetoothService.powered
                        // BluetoothService doesn't expose a setter — toggle via bluetoothctl
                        onToggled: btToggleProc.running = true

                        property var btToggleProc: Process {
                            command: BluetoothService.powered
                                ? ["bluetoothctl", "power", "off"]
                                : ["bluetoothctl", "power", "on"]
                            running: false
                        }
                    }
                }
            }

        // ---- Connected device ----
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: deviceRow.implicitHeight + Appearance.padding.md * 2
            radius: Appearance.rounding.md
            color: BluetoothService.connectedDevice !== ""
                ? Colours.tPalette.m3secondaryContainer
                : Colours.tPalette.m3surfaceContainerLow
            visible: BluetoothService.powered

            Behavior on color { CAnim {} }

            InfoRow {
                id: deviceRow
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: Appearance.padding.md
                }
                icon: "headphones"
                primaryText: BluetoothService.connectedDevice !== ""
                    ? BluetoothService.connectedDevice
                    : "No device connected"
                primaryColor: BluetoothService.connectedDevice !== ""
                    ? Colours.palette.m3onSecondaryContainer
                    : Colours.tPalette.m3onSurfaceVariant
                iconColor: BluetoothService.connectedDevice !== ""
                    ? Colours.palette.m3onSecondaryContainer
                    : Colours.tPalette.m3onSurfaceVariant
            }
        }

        // ---- Device list placeholder ----
        Separator {
            visible: BluetoothService.powered
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: btPlaceholderRow.implicitHeight + Appearance.padding.lg * 2
            radius: Appearance.rounding.md
            color: Colours.tPalette.m3surfaceContainerLow
            visible: BluetoothService.powered

            InfoRow {
                id: btPlaceholderRow
                anchors.centerIn: parent
                icon: "info"
                primaryText: "Device scan requires bluetoothctl"
                primaryColor: Colours.tPalette.m3onSurfaceVariant
                iconColor: Colours.tPalette.m3onSurfaceVariant
            }
        }

        Item { implicitHeight: Appearance.padding.md }
    }
}
