// modules/bar/widgets/Cpu.qml
// CPU usage icon with severity coloring. Data from PerformanceModel singleton.
// critical (>80%): m3error, warning (>60%): m3tertiary, normal: m3onSurface.
pragma ComponentBehavior: Bound
import QtQuick
import config
import services
import "../../../components"

WidgetContainer {
    id: root

    tooltip: "CPU: " + Math.round(PerformanceModel.cpuUsage) + "%"

    readonly property color _color: {
        if (PerformanceModel.cpuUsage > 85) return Colours.tPalette.m3tertiary;
        return Colours.tPalette.m3onSurface;
    }

    MaterialIcon {
        anchors.centerIn: parent
        icon: "memory"
        size: Appearance.font.xl
        color: root._color
    }
}
