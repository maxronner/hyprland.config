// IconButton.qml
// M3 icon button with filled, tonal, and text variants.
pragma ComponentBehavior: Bound
import QtQuick
import config
import services
import ".."

Rectangle {
    id: root

    // "filled" | "tonal" | "text"
    property string type: "tonal"
    property string icon: ""
    property real iconSize: Appearance.font.xl
    property bool checked: false
    property bool disabled: false

    signal clicked()

    implicitWidth: Appearance.sizes.button
    implicitHeight: Appearance.sizes.button
    radius: Appearance.rounding.md

    opacity: disabled ? 0.38 : 1.0

    color: {
        if (type === "filled") return Colours.tPalette.m3primary;
        if (type === "tonal")  return Colours.tPalette.m3secondaryContainer;
        return "transparent"; // text
    }

    Behavior on color { CAnim {} }

    MaterialIcon {
        anchors.centerIn: parent
        icon: root.icon
        size: root.iconSize
        fillAnimated: true
        fill: root.checked ? 1 : 0

        color: {
            if (root.type === "filled") return Colours.palette.m3onPrimary;
            if (root.type === "tonal")  return Colours.palette.m3onSecondaryContainer;
            return Colours.palette.m3primary; // text
        }
    }

    StateLayer {
        color: {
            if (root.type === "filled") return Colours.palette.m3onPrimary;
            if (root.type === "tonal")  return Colours.palette.m3onSecondaryContainer;
            return Colours.palette.m3primary; // text
        }
        radius: root.radius
        clipRipple: true
        disabled: root.disabled

        onTapped: root.clicked()
    }
}
