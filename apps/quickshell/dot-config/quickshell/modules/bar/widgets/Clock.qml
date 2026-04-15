// modules/bar/widgets/Clock.qml
// Two-line clock: hours (bold, m3onSurface) and minutes (m3onSurfaceVariant).
// Reads from the Time singleton — no own Timer.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import config
import services
import "../../../components"

WidgetContainer {
    id: root

    tooltip: Time.dateFull

    implicitHeight: clockColumn.implicitHeight + Appearance.padding.md

    Column {
        id: clockColumn
        anchors.centerIn: parent
        spacing: 0

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Time.hours
            color: Colours.tPalette.m3onSurface
            font.pixelSize: Appearance.font.lg
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
        }

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Time.minutes
            color: Colours.tPalette.m3onSurfaceVariant
            font.pixelSize: Appearance.font.md
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
