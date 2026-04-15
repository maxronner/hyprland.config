// StyledRect.qml
// Rectangle with a smooth M3 color transition. Use as the base for any
// surface that changes color on state changes (hover, active, selected, etc.).
pragma ComponentBehavior: Bound
import QtQuick

Rectangle {
    color: "transparent"

    Behavior on color {
        CAnim {}
    }
}
