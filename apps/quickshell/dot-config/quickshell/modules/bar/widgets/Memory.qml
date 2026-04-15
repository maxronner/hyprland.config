// modules/bar/widgets/Memory.qml
// Memory usage icon with severity coloring. Data from PerformanceModel singleton.
// critical (>85% used): m3error, normal: m3onSurface.
pragma ComponentBehavior: Bound
import QtQuick
import config
import services
import "../../../components"

WidgetContainer {
    id: root

    tooltip: "Memory: " + PerformanceModel.memUsedGb.toFixed(1) + "G / " + PerformanceModel.memTotalGb.toFixed(1) + "G"

    readonly property color _color: {
        if (PerformanceModel.memTotalGb > 0 && (PerformanceModel.memUsedGb / PerformanceModel.memTotalGb) > 0.85)
            return Colours.tPalette.m3tertiary;
        return Colours.tPalette.m3onSurface;
    }

    MaterialIcon {
        anchors.centerIn: parent
        icon: "developer_board"
        size: Appearance.font.xl
        color: root._color
    }
}
