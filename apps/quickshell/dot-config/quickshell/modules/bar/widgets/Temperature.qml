// modules/bar/widgets/Temperature.qml
// CPU temperature icon with severity coloring. Data from PerformanceModel singleton.
// critical (>=80°C): m3error, warning (>=60°C): m3tertiary, normal: m3onSurface.
pragma ComponentBehavior: Bound
import QtQuick
import config
import services
import "../../../components"

WidgetContainer {
    id: root

    tooltip: "CPU temp: " + PerformanceModel.tempC + "°C"

    readonly property color _color: {
        if (PerformanceModel.tempSeverity === "critical") return Colours.tPalette.m3error;
        if (PerformanceModel.tempSeverity === "warning")  return Colours.tPalette.m3tertiary;
        return Colours.tPalette.m3onSurface;
    }

    readonly property string _icon: {
        if (PerformanceModel.tempSeverity === "critical") return "device_thermostat";
        return "thermostat";
    }

    MaterialIcon {
        anchors.centerIn: parent
        icon: root._icon
        size: Appearance.font.xl
        color: root._color
    }
}
