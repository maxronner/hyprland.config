// modules/controlcenter/Panes.qml
// All 6 CC panes loaded upfront. Crossfades between active pane.
pragma ComponentBehavior: Bound
import QtQuick
import config
import "panes"

Item {
    id: root

    property int activeIndex: 0

    implicitWidth: 340
    clip: true

    // Pane 0 — Audio
    Audio {
        anchors.fill: parent
        visible: opacity > 0
        opacity: root.activeIndex === 0 ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Appearance.anim.duration.md; easing.type: Easing.BezierSpline; easing.bezierCurve: Appearance.anim.emphasized } }
    }

    // Pane 1 — Network
    Network {
        anchors.fill: parent
        visible: opacity > 0
        opacity: root.activeIndex === 1 ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Appearance.anim.duration.md; easing.type: Easing.BezierSpline; easing.bezierCurve: Appearance.anim.emphasized } }
    }

    // Pane 2 — Bluetooth
    Bluetooth {
        anchors.fill: parent
        visible: opacity > 0
        opacity: root.activeIndex === 2 ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Appearance.anim.duration.md; easing.type: Easing.BezierSpline; easing.bezierCurve: Appearance.anim.emphasized } }
    }

    // Pane 3 — Notifications
    Notifications {
        anchors.fill: parent
        visible: opacity > 0
        opacity: root.activeIndex === 3 ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Appearance.anim.duration.md; easing.type: Easing.BezierSpline; easing.bezierCurve: Appearance.anim.emphasized } }
    }

    // Pane 4 — Appearance
    AppearancePane {
        anchors.fill: parent
        visible: opacity > 0
        opacity: root.activeIndex === 4 ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Appearance.anim.duration.md; easing.type: Easing.BezierSpline; easing.bezierCurve: Appearance.anim.emphasized } }
    }

    // Pane 5 — Session
    Session {
        anchors.fill: parent
        visible: opacity > 0
        opacity: root.activeIndex === 5 ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Appearance.anim.duration.md; easing.type: Easing.BezierSpline; easing.bezierCurve: Appearance.anim.emphasized } }
    }
}
