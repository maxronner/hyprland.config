// modules/dashboard/DashWrapper.qml
// Animated top-down drawer for the M3 dashboard.
//
// offsetScale: 0 = fully visible, 1 = fully hidden (above viewport).
// Content slides in/out via anchors.topMargin using an expressive spatial curve (500ms).
// contentHeight is snapshotted at animation start to prevent layout jitter mid-flight.
// A Scrim child dims the background whenever the drawer is not fully hidden.
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import config
import services
import "../../components"

Item {
    id: root

    // 0 = visible, 1 = hidden. Driven by shell.qml.
    property real offsetScale: 1.0
    property real leftInsetWidth: Math.max(Appearance.sizes.bar, Appearance.inset.gapOuter)
    property bool barVisible: true

    readonly property real frameLeftInset: root.barVisible ? root.leftInsetWidth : Appearance.inset.gapOuter
    readonly property real frameTopInset: Appearance.inset.gapOuter
    readonly property real dashboardInset: Appearance.inset.gapInner

    signal dismissed()

    anchors.fill: parent

    // ---- Snapshotted height for animation ----
    // When idle (animation not running) this tracks the live content height.
    // On animation start it is frozen so topMargin calculation stays stable.
    property real _snapshotHeight: dashboardContent.implicitHeight
    property bool _animating: false

    // ---- Scrim ----
    Scrim {
        id: scrim
        active: root.offsetScale < 1.0
        onDismissed: root.dismissed()
    }

    // ---- Sliding content container ----
    Item {
        id: slideContainer

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        // Slide up by (contentHeight + shadow buffer) * offsetScale
        readonly property real shadowOffset: 32
        anchors.topMargin: -(root._snapshotHeight + shadowOffset) * root.offsetScale

        // Fade out as it slides away
        opacity: 1.0 - root.offsetScale

        height: dashboardContent.implicitHeight + shadowOffset
        clip: false

        Dashboard {
            id: dashboardContent

            anchors {
                top: parent.top
                left: parent.left
                topMargin: root.frameTopInset + root.dashboardInset
                leftMargin: root.frameLeftInset + root.dashboardInset
            }

            screenWidth:  root.width
            screenHeight: root.height
            topPadding: Appearance.padding.xl
        }
    }

    // ---- Animation on offsetScale ----
    Behavior on offsetScale {
        NumberAnimation {
            id: slideAnim
            duration: Appearance.anim.duration.expressiveDefault
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.expressiveDefaultSpatial

            onRunningChanged: {
                if (running) {
                    // Snapshot height at the moment animation starts
                    root._snapshotHeight = dashboardContent.implicitHeight
                    root._animating = true
                } else {
                    root._animating = false
                    // Restore live tracking when idle
                    root._snapshotHeight = Qt.binding(() => dashboardContent.implicitHeight)
                }
            }
        }
    }

    // ---- Keyboard handling ----
    Keys.onEscapePressed: root.dismissed()

    // Accept focus so key events reach us
    focus: root.offsetScale < 1.0
}
