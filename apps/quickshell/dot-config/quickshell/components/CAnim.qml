// CAnim.qml
// M3-defaulted ColorAnimation. Drop in as a Behavior target or inside
// SequentialAnimation / ParallelAnimation. Duration and curve track the
// active Appearance preset automatically.
pragma ComponentBehavior: Bound
import QtQuick
import config

ColorAnimation {
    duration: Appearance.anim.duration.md  // 400 ms
    easing.type: Easing.BezierSpline
    easing.bezierCurve: Appearance.anim.standard
}
