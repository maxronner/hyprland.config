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

    Flickable {
        anchors.fill: parent
        anchors.margins: Appearance.padding.lg
        contentHeight: layout.implicitHeight
        clip: true

        ColumnLayout {
            id: layout
            width: parent.width
            spacing: Appearance.spacing.md

            StyledText {
                text: "Bluetooth"
                font.pixelSize: Appearance.font.xl
                color: Colours.tPalette.m3onSurface
            }

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

                RowLayout {
                    id: deviceRow
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        margins: Appearance.padding.md
                    }
                    spacing: Appearance.spacing.sm

                    MaterialIcon {
                        icon: "headphones"
                        size: Appearance.font.lg
                        fill: BluetoothService.connectedDevice !== "" ? 1 : 0
                        color: BluetoothService.connectedDevice !== ""
                            ? Colours.palette.m3onSecondaryContainer
                            : Colours.tPalette.m3onSurfaceVariant

                        Behavior on color { CAnim {} }
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: BluetoothService.connectedDevice !== ""
                            ? BluetoothService.connectedDevice
                            : "No device connected"
                        color: BluetoothService.connectedDevice !== ""
                            ? Colours.palette.m3onSecondaryContainer
                            : Colours.tPalette.m3onSurfaceVariant
                        elide: Text.ElideRight
                    }
                }
            }

            // ---- Device list placeholder ----
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Colours.tPalette.m3outlineVariant
                opacity: 0.5
                visible: BluetoothService.powered
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: btPlaceholderRow.implicitHeight + Appearance.padding.lg * 2
                radius: Appearance.rounding.md
                color: Colours.tPalette.m3surfaceContainerLow
                visible: BluetoothService.powered

                RowLayout {
                    id: btPlaceholderRow
                    anchors.centerIn: parent

                    MaterialIcon {
                        icon: "info"
                        size: Appearance.font.lg
                        color: Colours.tPalette.m3onSurfaceVariant
                    }

                    StyledText {
                        text: "Device scan requires bluetoothctl"
                        color: Colours.tPalette.m3onSurfaceVariant
                        font.pixelSize: Appearance.font.sm
                    }
                }
            }

            Item { implicitHeight: Appearance.padding.md }
        }
    }
}
