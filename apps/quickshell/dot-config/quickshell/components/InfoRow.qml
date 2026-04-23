// InfoRow.qml
// Reusable non-interactive row with icon + primary/secondary text.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import config
import services

RowLayout {
    id: root

    property string icon: ""
    property string primaryText: ""
    property string secondaryText: ""
    property int iconSize: Appearance.font.lg
    property color iconColor: Colours.tPalette.m3onSurfaceVariant
    property color primaryColor: Colours.tPalette.m3onSurface
    property color secondaryColor: Colours.tPalette.m3onSurfaceVariant

    spacing: Appearance.spacing.sm

    MaterialIcon {
        icon: root.icon
        size: root.iconSize
        color: root.iconColor
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2

        StyledText {
            Layout.fillWidth: true
            text: root.primaryText
            color: root.primaryColor
            font.pixelSize: Appearance.font.md
            elide: Text.ElideRight
        }

        StyledText {
            Layout.fillWidth: true
            text: root.secondaryText
            color: root.secondaryColor
            font.pixelSize: Appearance.font.sm
            visible: text.length > 0
            elide: Text.ElideRight
        }
    }
}
