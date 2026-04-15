// StyledText.qml
// Opinionated Text element with M3 defaults: native rendering, plain text
// format, semantic color, and smooth color transitions.
//
// animate: true — opt-in scale pulse on text changes. Enable for infrequent
// status labels (power profile, connection state, etc.). DO NOT enable for
// clocks, live metrics, or any value that updates more than once per second;
// the scale animation would stutter and waste GPU cycles.
pragma ComponentBehavior: Bound
import QtQuick
import config
import services

Text {
    id: root

    // Whether to animate text changes with a shrink-expand scale pulse.
    property bool animate: false

    renderType: Text.NativeRendering
    textFormat: Text.PlainText

    color: Colours.tPalette.m3onSurface
    font.family: Appearance.font.family.sans
    font.pixelSize: Appearance.font.md

    Behavior on color {
        CAnim {}
    }

    // Scale-pulse animation on text changes. Only installed when animate: true.
    // Uses standardAccel (shrink) and standardDecel (expand) at 75 ms each —
    // short enough to feel snappy without overwhelming adjacent content.
    onTextChanged: {
        if (root.animate) scalePulse.restart()
    }

    SequentialAnimation {
        id: scalePulse
        running: false

        NumberAnimation {
            target: root
            property: "scale"
            to: 0.8
            duration: 75
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.standardAccel
        }
        NumberAnimation {
            target: root
            property: "scale"
            to: 1.0
            duration: 75
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.standardDecel
        }
    }
}
