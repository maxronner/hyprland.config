// WidgetContainer.qml
// M3-styled container for bar widgets. Transparent background with StateLayer
// for hover/press/ripple. Supports optional tooltip via PopupWindow.
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import QtQuick.Layouts
import config
import services

Rectangle {
    id: container

    property string tooltip: ""

    signal clicked()
    signal wheel(var event)
    property bool interactive: false

    implicitHeight: 32
    Layout.fillWidth: true
    Layout.preferredHeight: 32

    radius: Appearance.rounding.xs
    color: "transparent"

    // Wheel event forwarding (acceptedButtons: none so it won't steal clicks)
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        propagateComposedEvents: true
        onWheel: event => container.wheel(event)
    }

    // HoverHandler for tooltip — works alongside StateLayer's MouseArea
    HoverHandler {
        id: hoverHandler
    }

    property bool _showTip: hoverHandler.hovered && container.tooltip !== ""
    on_ShowTipChanged: {
        if (_showTip) tipTimer.start();
        else {
            tipTimer.stop();
            tipPopup.visible = false;
        }
    }

    Timer {
        id: tipTimer
        interval: 500
        onTriggered: tipPopup.visible = true
    }

    // StateLayer provides hover bg, ripple, and pointer cursor for interactive containers.
    StateLayer {
        color: Colours.palette.m3onSurface
        radius: container.radius
        clipRipple: true
        showHoverBackground: true
        disabled: !container.interactive

        onTapped: container.clicked()
    }

    PopupWindow {
        id: tipPopup
        anchor.item: container
        anchor.edges: Edges.Right
        anchor.gravity: Edges.Right
        anchor.rect.x: container.width + 8
        anchor.rect.y: (container.height - tipContent.height) / 2
        anchor.rect.width: 1
        anchor.rect.height: 1
        anchor.adjustment: PopupAdjustment.Slide
        visible: false
        color: "transparent"
        implicitWidth: tipContent.width
        implicitHeight: tipContent.height

        Rectangle {
            id: tipContent
            width: tipText.implicitWidth + 16
            height: tipText.implicitHeight + 12
            color: Colours.tPalette.m3surfaceContainerHigh
            radius: Appearance.rounding.sm

            Text {
                id: tipText
                anchors.centerIn: parent
                text: container.tooltip
                color: Colours.palette.m3onSurfaceVariant
                font.pixelSize: Appearance.font.md
                font.family: Appearance.font.family.sans
            }
        }
    }
}
