// MaterialIcon.qml
// Material Symbols Rounded icon with M3 defaults and optional fill animation.
//
// fill: 0 = outlined, 1 = filled. Can be bound to any boolean/int expression.
//
// fillAnimated: false (default) — single Text element; styleName switches
//   instantly between "Outlined" and "Filled" variants. Zero overhead.
//
// fillAnimated: true — Loader lazily creates a second Text element and
//   crossfades opacity between outlined and filled over 200 ms. Use for
//   interactive icons (toggle buttons, favorites) where the fill change is a
//   deliberate response to user action. Do NOT use for icons that change fill
//   on every data update (live metrics, status polling).
pragma ComponentBehavior: Bound
import QtQuick
import config
import services

Item {
    id: root

    property string icon: ""
    property real size: Appearance.font.xl
    property color color: Colours.tPalette.m3onSurface
    // 0 = outlined, 1 = filled
    property int fill: 0
    property bool fillAnimated: false

    implicitWidth: size
    implicitHeight: size

    // --- Static path (fillAnimated: false) ---
    Text {
        id: staticIcon
        visible: !root.fillAnimated
        anchors.centerIn: parent

        text: root.icon
        color: root.color
        font.family: Appearance.font.family.icons
        font.pixelSize: root.size
        // Toggle between weight variants used by Material Symbols Rounded.
        // "Regular" = outlined weight, "Filled" = filled weight.
        font.styleName: root.fill === 1 ? "Filled" : "Regular"

        Behavior on color {
            CAnim {}
        }
    }

    // --- Animated path (fillAnimated: true) ---
    // Outlined layer — always present once Loader is active.
    Loader {
        id: outlinedLoader
        active: root.fillAnimated
        anchors.centerIn: parent

        sourceComponent: Text {
            text: root.icon
            color: root.color
            font.family: Appearance.font.family.icons
            font.pixelSize: root.size
            font.styleName: "Regular"
            // Visible (opacity 1) when fill == 0, hidden when fill == 1.
            opacity: root.fill === 0 ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.anim.standard
                }
            }
            Behavior on color {
                CAnim {}
            }
        }
    }

    // Filled layer — lazily created alongside the outlined layer.
    Loader {
        id: filledLoader
        active: root.fillAnimated
        anchors.centerIn: parent

        sourceComponent: Text {
            text: root.icon
            color: root.color
            font.family: Appearance.font.family.icons
            font.pixelSize: root.size
            font.styleName: "Filled"
            // Visible (opacity 1) when fill == 1, hidden when fill == 0.
            opacity: root.fill === 1 ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.anim.standard
                }
            }
            Behavior on color {
                CAnim {}
            }
        }
    }
}
