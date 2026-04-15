// modules/bar/widgets/Network.qml
// Network status icon. Data from NetworkService singleton.
// wifi: signal icon, ethernet: lan icon, disconnected: wifi_off.
pragma ComponentBehavior: Bound
import QtQuick
import config
import services
import "../../../components"

WidgetContainer {
    id: root

    tooltip: {
        if (NetworkService.connectionType === "") return "Disconnected";
        const name = NetworkService.activeConnection || NetworkService.connectionType;
        if (NetworkService.connectionType === "wifi")
            return name + " — " + NetworkService.signalStrength + "%";
        return name;
    }

    readonly property string _icon: {
        if (NetworkService.connectionType === "ethernet") return "lan";
        if (NetworkService.connectionType === "wifi") {
            const s = NetworkService.signalStrength;
            if (s <= 0) return "wifi_off";
            if (s < 25) return "network_wifi_1_bar";
            if (s < 50) return "network_wifi_2_bar";
            if (s < 75) return "network_wifi_3_bar";
            return "wifi";
        }
        return "wifi_off";
    }

    readonly property color _color: {
        if (NetworkService.status === "unavailable") return Colours.tPalette.m3onSurfaceVariant;
        if (NetworkService.connectionType === "") return Colours.tPalette.m3error;
        return Colours.tPalette.m3onSurface;
    }

    MaterialIcon {
        anchors.centerIn: parent
        icon: root._icon
        size: Appearance.font.xl
        color: root._color
    }
}
