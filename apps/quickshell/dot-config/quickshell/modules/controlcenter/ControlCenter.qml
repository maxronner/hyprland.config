// modules/controlcenter/ControlCenter.qml
// M3 Control Center — NavRail + Panes layout with animated reveal.
//
// offsetScale: 0 = visible, 1 = hidden (off-screen right).
// Slides in from the right using an expressive spatial curve.
// Contains a Scrim to dismiss on outside click.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import config
import services
import "../../components"
import "../../components/effects"

Item {
    id: root

    // 0 = visible, 1 = hidden. Driven by shell.qml.
    property real offsetScale: 1.0

    signal dismissed()

    anchors.fill: parent

    // ---- Scrim ----
    Scrim {
        id: scrim
        active: root.offsetScale < 1.0
        onDismissed: root.dismissed()
    }

    // ---- Sliding content container ----
    // Anchored to the right wall; slides out by translating rightward.
    Item {
        id: slideContainer

        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
        }

        // Natural width: navRail + divider + panes + outer margins on both sides
        width: navRail.implicitWidth + 1 + panesArea.implicitWidth + Appearance.padding.xl * 2

        // Translate right by (width * offsetScale) to slide off screen
        transform: Translate {
            x: slideContainer.width * root.offsetScale
        }

        opacity: 1.0 - root.offsetScale * 0.3

        // Absorb clicks so they don't fall through to the Scrim
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
        }

        // ---- M3 Surface Card ----
        Rectangle {
            id: ccCard

            anchors {
                fill: parent
                margins: Appearance.padding.xl
            }

            color: Colours.tPalette.m3surfaceContainer
            radius: Appearance.rounding.md

            RowLayout {
                anchors.fill: parent
                spacing: 0

                // ---- NavRail ----
                NavRail {
                    id: navRail

                    Layout.fillHeight: true

                    activeIndex: root._activeIndex
                    onIndexChanged: index => root._activeIndex = index

                    // Scroll wheel switches panes
                    WheelHandler {
                        onWheel: event => {
                            if (event.angleDelta.y < 0)
                                root._activeIndex = Math.min(root._activeIndex + 1, 5)
                            else if (event.angleDelta.y > 0)
                                root._activeIndex = Math.max(root._activeIndex - 1, 0)
                        }
                    }
                }

                // Divider
                Rectangle {
                    Layout.fillHeight: true
                    implicitWidth: 1
                    color: Colours.tPalette.m3outlineVariant
                    opacity: 0.5
                }

                // ---- Panes ----
                Panes {
                    id: panesArea

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    activeIndex: root._activeIndex
                }
            }
        }
    }

    // ---- Animation on offsetScale ----
    Behavior on offsetScale {
        NumberAnimation {
            duration: Appearance.anim.duration.expressiveDefault
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.expressiveDefaultSpatial
        }
    }

    // ---- Keyboard handling ----
    Keys.onEscapePressed: root.dismissed()

    // Accept focus so key events reach us
    focus: root.offsetScale < 1.0

    // ---- Active pane index (persists across open/close) ----
    property int _activeIndex: 0
}
