// panels/DateTimePanel.qml
// Large clock display using Time service.
// Hour/minute rendered in primary/secondary M3 colors, Rubik font, xxl size.
// Date below in m3onSurfaceVariant.
// Background: m3surfaceContainerLow, rounding: xl (38px).
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import config
import services
import "../../../components"

Rectangle {
    id: root

    color:  Colours.tPalette.m3surfaceContainerLow
    radius: Appearance.rounding.xl

    Behavior on color { CAnim {} }

    implicitWidth:  200
    implicitHeight: 160

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Appearance.spacing.xs

        // Hour : Minute on one line, two-tone
        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: 0

            StyledText {
                text: Time.hours
                color: Colours.tPalette.m3primary
                font.pixelSize: Appearance.font.xxl
                font.weight: Font.Medium
            }

            StyledText {
                text: ":"
                color: Colours.tPalette.m3onSurfaceVariant
                font.pixelSize: Appearance.font.xxl
                font.weight: Font.Medium
            }

            StyledText {
                text: Time.minutes
                color: Colours.tPalette.m3secondary
                font.pixelSize: Appearance.font.xxl
                font.weight: Font.Medium
            }
        }

        // Full date
        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Time.dateFull
            color: Colours.tPalette.m3onSurfaceVariant
        }
    }
}
