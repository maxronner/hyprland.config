// StateLayer.qml
// M3 hover/press/ripple overlay. Place as a child of any interactive element.
// Propagates events to parent MouseAreas via propagateComposedEvents.
pragma ComponentBehavior: Bound
import QtQuick
import config
import services

MouseArea {
    id: root

    property bool disabled: false
    property bool showHoverBackground: true
    property color color: Colours.palette.m3onSurface
    property real radius: parent?.radius ?? 0 // qmllint disable missing-property
    property bool clipRipple: false

    signal tapped(var mouse)

    anchors.fill: parent

    enabled: !disabled
    cursorShape: disabled ? undefined : Qt.PointingHandCursor
    hoverEnabled: true
    propagateComposedEvents: true

    onClicked: mouse => {
        if (disabled) { mouse.accepted = false; return; }
        root.tapped(mouse);
        // Accept the click (default) so it doesn't propagate to siblings like Scrim
    }

    onPressed: mouse => {
        if (disabled) {
            mouse.accepted = false;
            return;
        }

        rippleAnim.startX = mouse.x;
        rippleAnim.startY = mouse.y;

        const dist = (ox, oy) => ox * ox + oy * oy;
        rippleAnim.targetRadius = Math.sqrt(Math.max(
            dist(mouse.x, mouse.y),
            dist(mouse.x, height - mouse.y),
            dist(width - mouse.x, mouse.y),
            dist(width - mouse.x, height - mouse.y)
        ));

        rippleAnim.restart();
        // Accept press so released/clicked events fire.
        // Composed events (clicked) propagate via propagateComposedEvents.
    }

    // Hover background
    Rectangle {
        id: hoverLayer

        anchors.fill: parent
        radius: root.radius
        color: Qt.alpha(root.color,
            root.disabled ? 0 :
            root.pressed ? 0.12 :
            (root.showHoverBackground && root.containsMouse) ? 0.08 : 0)

        Behavior on color {
            ColorAnimation {
                duration: Appearance.anim.duration.sm
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.standard
            }
        }
    }

    // Ripple container — optionally clipped
    Item {
        id: rippleContainer

        anchors.fill: parent
        clip: root.clipRipple

        Rectangle {
            id: ripple

            radius: Appearance.rounding.full
            color: root.color
            opacity: 0

            transform: Translate {
                x: -ripple.width / 2
                y: -ripple.height / 2
            }
        }
    }

    SequentialAnimation {
        id: rippleAnim

        property real startX
        property real startY
        property real targetRadius

        PropertyAction {
            target: ripple
            property: "x"
            value: rippleAnim.startX
        }
        PropertyAction {
            target: ripple
            property: "y"
            value: rippleAnim.startY
        }
        PropertyAction {
            target: ripple
            property: "opacity"
            value: 0.08
        }
        ParallelAnimation {
            NumberAnimation {
                target: ripple
                properties: "implicitWidth,implicitHeight"
                from: 0
                to: rippleAnim.targetRadius * 2
                duration: Appearance.anim.duration.md
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.standardDecel
            }
            NumberAnimation {
                target: ripple
                property: "opacity"
                to: 0
                duration: Appearance.anim.duration.md
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.standardDecel
            }
        }
    }
}
