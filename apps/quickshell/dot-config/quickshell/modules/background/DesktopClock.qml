// modules/background/DesktopClock.qml
// Time overlay on wallpaper. Configurable 9-point grid position.
// Semi-transparent background for readability against any wallpaper.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import config
import services
import "../../components"

Item {
    id: root

    property string position: Config.pending.background?.desktopClock?.position ?? "bottom-right"
    property real clockScale: Config.pending.background?.desktopClock?.scale ?? 1.0

    anchors.fill: parent
    anchors.margins: Appearance.padding.xl * 2

    // Skip animation on first load; flip after first event-loop tick
    property bool _ready: false
    Component.onCompleted: Qt.callLater(() => { _ready = true; })

    Rectangle {
        id: clockCard

        state: root._ready ? root.position : ""

        width: clockLayout.implicitWidth + Appearance.padding.lg * 2
        height: clockLayout.implicitHeight + Appearance.padding.lg * 2
        radius: Appearance.rounding.lg
        color: Qt.rgba(0, 0, 0, 0.35)

        states: [
            State {
                name: "top-left"
                AnchorChanges { target: clockCard; anchors.top: root.top; anchors.left: root.left }
            },
            State {
                name: "top-center"
                AnchorChanges { target: clockCard; anchors.top: root.top; anchors.horizontalCenter: root.horizontalCenter }
            },
            State {
                name: "top-right"
                AnchorChanges { target: clockCard; anchors.top: root.top; anchors.right: root.right }
            },
            State {
                name: "middle-left"
                AnchorChanges { target: clockCard; anchors.verticalCenter: root.verticalCenter; anchors.left: root.left }
            },
            State {
                name: "middle-center"
                AnchorChanges { target: clockCard; anchors.verticalCenter: root.verticalCenter; anchors.horizontalCenter: root.horizontalCenter }
            },
            State {
                name: "middle-right"
                AnchorChanges { target: clockCard; anchors.verticalCenter: root.verticalCenter; anchors.right: root.right }
            },
            State {
                name: "bottom-left"
                AnchorChanges { target: clockCard; anchors.bottom: root.bottom; anchors.left: root.left }
            },
            State {
                name: "bottom-center"
                AnchorChanges { target: clockCard; anchors.bottom: root.bottom; anchors.horizontalCenter: root.horizontalCenter }
            },
            State {
                name: "bottom-right"
                AnchorChanges { target: clockCard; anchors.bottom: root.bottom; anchors.right: root.right }
            }
        ]

        transitions: Transition {
            enabled: root._ready
            AnchorAnimation {
                duration: Appearance.anim.duration.expressiveDefault
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.expressiveDefaultSpatial
            }
        }

        ColumnLayout {
            id: clockLayout
            anchors.centerIn: parent
            spacing: Appearance.spacing.sm

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: Time.hours + ":" + Time.minutes
                color: Colours.palette.m3onSurface
                font.pixelSize: Appearance.font.xxl * 2 * root.clockScale
                font.bold: true
                lineHeight: 1.0
                lineHeightMode: Text.FixedHeight
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: Time.dateFull
                color: Colours.palette.m3onSurfaceVariant
                font.pixelSize: Appearance.font.lg * root.clockScale
                lineHeight: 1.0
                lineHeightMode: Text.FixedHeight
            }
        }
    }
}
