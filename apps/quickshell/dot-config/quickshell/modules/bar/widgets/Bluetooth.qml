// modules/bar/widgets/Bluetooth.qml
// Bluetooth status icon. Data from BluetoothService singleton.
// Hidden when no adapter. Dimmed when off. Connected: success color + battery.
pragma ComponentBehavior: Bound
import QtQuick
import config
import services
import "../../../components"

WidgetContainer {
    id: root

    visible: BluetoothService.status !== "unavailable"
    interactive: true

    tooltip: {
        if (!BluetoothService.powered) return "Bluetooth: off";
        if (BluetoothService.connectedDevice !== "") {
            let t = BluetoothService.connectedDevice;
            if (BluetoothService.batteryPercent >= 0)
                t += " — " + BluetoothService.batteryPercent + "%";
            return t;
        }
        return "Bluetooth: on (no device)";
    }

    readonly property string _icon: {
        if (!BluetoothService.powered) return "bluetooth_disabled";
        if (BluetoothService.connectedDevice !== "") return "bluetooth_connected";
        return "bluetooth";
    }

    readonly property color _color: {
        if (!BluetoothService.powered) return Colours.tPalette.m3onSurfaceVariant;
        return Colours.tPalette.m3onSurface;
    }

    MaterialIcon {
        anchors.centerIn: parent
        icon: root._icon
        size: Appearance.font.xl
        color: root._color
    }
}
