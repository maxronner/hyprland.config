// ToggleButton.qml
// M3 toggle switch component.
pragma ComponentBehavior: Bound
import QtQuick
import config
import services
import ".."

Rectangle {
    id: root

    property bool checked: false
    property bool disabled: false

    signal toggled()

    implicitWidth: 52
    implicitHeight: 32
    radius: Appearance.rounding.full

    opacity: disabled ? 0.38 : 1.0

    color: checked ? Colours.tPalette.m3primary : Colours.tPalette.m3surfaceContainerHighest

    Behavior on color { CAnim {} }

    // Thumb
    Rectangle {
        id: thumb

        readonly property real _checkedSize: 24
        readonly property real _uncheckedSize: 16

        implicitWidth: root.checked ? _checkedSize : _uncheckedSize
        implicitHeight: implicitWidth
        radius: Appearance.rounding.full

        color: root.checked ? Colours.palette.m3onPrimary : Colours.palette.m3outline

        // Horizontal position: left margin 8px unchecked, right margin 8px checked
        x: root.checked
            ? root.width - implicitWidth - (root.height - _checkedSize) / 2
            : (root.height - _uncheckedSize) / 2

        anchors.verticalCenter: parent.verticalCenter

        Behavior on x {
            NumberAnimation {
                duration: 200
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.standard
            }
        }
        Behavior on implicitWidth {
            NumberAnimation {
                duration: 200
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.standard
            }
        }
        Behavior on color { CAnim {} }
    }

    StateLayer {
        color: root.checked ? Colours.palette.m3primary : Colours.palette.m3onSurface
        radius: root.radius
        disabled: root.disabled

        onTapped: {
            if (!root.disabled) {
                root.toggled();
            }
        }
    }
}
