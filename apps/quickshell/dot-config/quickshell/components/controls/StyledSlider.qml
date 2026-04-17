// StyledSlider.qml
// M3 slider with continuous and discrete (stepped) modes.
// Stateless: displays `value`, emits `moved()`. Caller owns the value.
pragma ComponentBehavior: Bound
import QtQuick
import config
import services
import ".."
import "../effects"

Item {
    id: root

    // Current value in [from, to]. Caller passes the raw value — the slider
    // normalizes internally for rendering.
    property real value: 0.0

    // Value range.
    property real from: 0.0
    property real to: 1.0

    // 0 = continuous; >0 = discrete with tick marks
    property real stepSize: 0

    // Emits the raw (mapped) value when user drags or clicks
    signal moved(real newValue)

    // Normalized position in [0, 1] derived from value/from/to.
    readonly property real _norm: {
        const span = to - from;
        if (span === 0) return 0;
        return Math.max(0, Math.min(1, (value - from) / span));
    }

    implicitWidth: 200
    implicitHeight: 20

    // --- Track background ---
    Rectangle {
        id: trackBg
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        height: 4
        radius: Appearance.rounding.full
        color: Colours.tPalette.m3surfaceContainerHighest

        // Filled portion
        Rectangle {
            id: trackFill
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: root._norm * parent.width
            height: parent.height
            radius: Appearance.rounding.full
            color: Colours.palette.m3primary

            Behavior on width {
                NumberAnimation {
                    duration: Appearance.anim.duration.xs
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.anim.standard
                }
            }
        }

        // Discrete tick marks (only when stepSize > 0 and spacing >= 20px)
        Repeater {
            id: tickRepeater

            readonly property int _count: root.stepSize > 0
                ? Math.round((root.to - root.from) / root.stepSize) + 1
                : 0
            readonly property real _spacing: _count > 1
                ? trackBg.width / (_count - 1)
                : 0
            readonly property bool _visible: _count > 1 && _spacing >= 20

            model: _visible ? _count : 0

            Rectangle {
                required property int index

                readonly property real _pos: index * tickRepeater._spacing
                readonly property bool _filled: _pos <= (root._norm * trackBg.width) + 1

                x: _pos - 2
                anchors.verticalCenter: parent.verticalCenter
                width: 4
                height: 4
                radius: Appearance.rounding.full
                color: _filled ? Colours.palette.m3primary : Colours.palette.m3outlineVariant
            }
        }

        // Track click/drag area
        MouseArea {
            anchors.fill: parent
            anchors.margins: -8
            cursorShape: Qt.PointingHandCursor

            onClicked: mouse => {
                const pos = Math.max(0, Math.min(1, mouse.x / trackBg.width));
                const snapped = root.stepSize > 0 ? _snapValue(pos) : pos;
                root.moved(root.from + snapped * (root.to - root.from));
            }

            onPositionChanged: mouse => {
                if (!pressed) return;
                const pos = Math.max(0, Math.min(1, mouse.x / trackBg.width));
                const snapped = root.stepSize > 0 ? _snapValue(pos) : pos;
                root.moved(root.from + snapped * (root.to - root.from));
            }
        }
    }

    // --- Thumb ---
    Rectangle {
        id: thumb

        width: 16
        height: 16
        radius: Appearance.rounding.full
        color: Colours.palette.m3primary

        x: root._norm * (root.width - width)
        anchors.verticalCenter: parent.verticalCenter

        Behavior on x {
            NumberAnimation {
                duration: Appearance.anim.duration.xs
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.standard
            }
        }

        Elevation {
            anchors.fill: parent
            level: 1
        }
    }

    // --- Snap helper ---
    function _snapValue(pos) {
        if (root.stepSize <= 0) return pos;
        const range = root.to - root.from;
        const steps = Math.round((root.to - root.from) / root.stepSize);
        const stepPos = 1.0 / steps;
        return Math.round(pos / stepPos) * stepPos;
    }
}
