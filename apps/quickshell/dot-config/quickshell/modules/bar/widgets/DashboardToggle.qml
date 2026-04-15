// modules/bar/widgets/DashboardToggle.qml
// Dashboard toggle icon button at the top of the bar.
// Uses WidgetContainer's built-in clicked() signal — no redeclaration.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import config
import services
import "../../../components"

WidgetContainer {
    id: root

    property bool active: false

    interactive: true
    tooltip: active ? "Close dashboard" : "Open dashboard"

    MaterialIcon {
        anchors.centerIn: parent
        icon: "dashboard"
        size: Appearance.font.xl
        fill: root.active ? 1 : 0
        fillAnimated: true
        color: root.active ? Colours.tPalette.m3primary : Colours.tPalette.m3onSurface
    }
}
