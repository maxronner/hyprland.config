// modules/bar/widgets/Calendar.qml
// Day-of-month number display. Reads from Time singleton.
pragma ComponentBehavior: Bound
import QtQuick
import config
import services
import "../../../components"

WidgetContainer {
    id: root

    tooltip: Time.dateFull

    MaterialIcon {
        anchors.centerIn: parent
        icon: "calendar_today"
        size: Appearance.font.xl
        color: Colours.tPalette.m3onSurface
    }
}
