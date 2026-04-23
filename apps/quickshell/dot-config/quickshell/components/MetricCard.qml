// MetricCard.qml
// Shared dashboard metric card shell for label/value + chart body.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import config
import services

Rectangle {
    id: card

    property string label: ""
    property string value: ""
    property color valColor: Colours.tPalette.m3onSurface

    default property alias content: contentHost.data

    color: Colours.tPalette.m3surfaceContainerLow
    radius: Appearance.rounding.md
    Behavior on color { CAnim {} }

    ColumnLayout {
        anchors {
            fill: parent
            margins: Appearance.padding.md
        }
        spacing: Appearance.spacing.xs

        StyledText {
            text: card.label
            color: Colours.tPalette.m3onSurfaceVariant
            font.pixelSize: Appearance.font.sm
        }

        StyledText {
            text: card.value
            color: card.valColor
            font.family: Appearance.font.family.mono
            font.pixelSize: Appearance.font.xl
            font.weight: Font.Medium
        }

        Item {
            id: contentHost
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
