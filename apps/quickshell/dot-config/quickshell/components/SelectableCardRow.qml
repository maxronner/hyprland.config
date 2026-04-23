// SelectableCardRow.qml
// Reusable selectable row card with icon, text, and ripple state-layer.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import config
import services

Rectangle {
    id: root

    property string icon: ""
    property string primaryText: ""
    property string secondaryText: ""
    property bool selected: false
    property bool disabled: false
    property int iconSize: Appearance.font.lg
    property real iconFill: 0

    property color selectedColor: Colours.tPalette.m3secondaryContainer
    property color unselectedColor: Colours.tPalette.m3surfaceContainerHigh

    signal tapped()

    Layout.fillWidth: true
    implicitHeight: contentRow.implicitHeight + Appearance.padding.md * 2
    radius: Appearance.rounding.sm
    color: root.selected ? root.selectedColor : root.unselectedColor
    opacity: root.disabled ? 0.38 : 1.0

    Behavior on color { CAnim {} }

    RowLayout {
        id: contentRow
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: Appearance.padding.md
        }
        spacing: Appearance.spacing.sm

        MaterialIcon {
            icon: root.icon
            size: root.iconSize
            fill: root.iconFill
            color: root.selected
                ? Colours.palette.m3onSecondaryContainer
                : Colours.tPalette.m3onSurface
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            StyledText {
                text: root.primaryText
                font.pixelSize: Appearance.font.md
                color: root.selected
                    ? Colours.palette.m3onSecondaryContainer
                    : Colours.tPalette.m3onSurface
                elide: Text.ElideRight
            }

            StyledText {
                text: root.secondaryText
                font.pixelSize: Appearance.font.sm
                color: root.selected
                    ? Colours.palette.m3onSecondaryContainer
                    : Colours.tPalette.m3onSurfaceVariant
                visible: text.length > 0
                elide: Text.ElideRight
            }
        }
    }

    StateLayer {
        radius: parent.radius
        color: root.selected
            ? Colours.palette.m3onSecondaryContainer
            : Colours.palette.m3onSurface
        disabled: root.disabled
        clipRipple: true
        onTapped: root.tapped()
    }
}
