// Scrim.qml
// Shared overlay backdrop for dashboard and control center.
// Uses raw palette.m3scrim (not tPalette) for consistent dimming regardless of
// the transparency setting.
pragma ComponentBehavior: Bound
import QtQuick
import config
import services

Rectangle {
    id: root

    property bool active: false

    signal dismissed()

    anchors.fill: parent
    color: Colours.palette.m3scrim

    opacity: active ? 0.32 : 0

    Behavior on opacity {
        NumberAnimation {
            duration: Appearance.anim.duration.expressiveDefault
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.standard
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.active
        onClicked: root.dismissed()
    }
}
