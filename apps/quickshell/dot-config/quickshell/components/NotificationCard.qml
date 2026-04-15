// NotificationCard.qml
// Shared notification card used by toast popups and control center.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications
import config
import services

Rectangle {
    id: root

    property string appName: ""
    property string appIcon: ""
    property string summary: ""
    property string body: ""
    property string image: ""
    property int urgency: NotificationUrgency.Normal

    signal dismissed()

    implicitHeight: content.implicitHeight + Appearance.padding.md * 2
    radius: Appearance.rounding.md

    color: urgency === NotificationUrgency.Critical
        ? Qt.alpha(Colours.palette.m3errorContainer, 0.95)
        : Colours.tPalette.m3surfaceContainerHigh

    readonly property color _fg: urgency === NotificationUrgency.Critical
        ? Colours.palette.m3onErrorContainer
        : Colours.tPalette.m3onSurface

    readonly property color _fgSub: urgency === NotificationUrgency.Critical
        ? Colours.palette.m3onErrorContainer
        : Colours.tPalette.m3onSurfaceVariant

    RowLayout {
        id: content
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: Appearance.padding.md
        }
        spacing: Appearance.spacing.sm

        // Notification image thumbnail (absolute paths only)
        Image {
            source: root.image.startsWith("/") ? "file://" + root.image : ""
            sourceSize.width: 48
            sourceSize.height: 48
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            Layout.alignment: Qt.AlignTop
            visible: source !== "" && status === Image.Ready
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.xs

            // App icon + name
            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.xs

                Image {
                    source: root.appIcon.startsWith("/") ? "file://" + root.appIcon : ""
                    sourceSize.width: Appearance.font.lg
                    sourceSize.height: Appearance.font.lg
                    Layout.preferredWidth: Appearance.font.lg
                    Layout.preferredHeight: Appearance.font.lg
                    visible: source !== "" && status === Image.Ready
                }

                StyledText {
                    Layout.fillWidth: true
                    text: root.appName
                    font.pixelSize: Appearance.font.sm
                    color: root._fgSub
                    elide: Text.ElideRight
                }

                StyledText {
                    text: root.urgency === NotificationUrgency.Critical ? "critical"
                        : root.urgency === NotificationUrgency.Low ? "low" : ""
                    font.pixelSize: Appearance.font.sm
                    Layout.rightMargin: Appearance.padding.sm
                    color: root.urgency === NotificationUrgency.Critical
                        ? Colours.palette.m3error
                        : root._fgSub
                    visible: text !== ""
                }
            }

            // Summary
            StyledText {
                Layout.fillWidth: true
                text: root.summary
                font.pixelSize: Appearance.font.md
                font.weight: Font.Medium
                color: root._fg
                elide: Text.ElideRight
                visible: root.summary !== ""
            }

            // Body
            StyledText {
                Layout.fillWidth: true
                text: root.body
                font.pixelSize: Appearance.font.sm
                color: root._fgSub
                wrapMode: Text.WordWrap
                maximumLineCount: 3
                elide: Text.ElideRight
                visible: root.body !== ""
            }
        }
    }

    StateLayer {
        radius: parent.radius
        color: root.urgency === NotificationUrgency.Critical
            ? Colours.palette.m3onErrorContainer
            : Colours.palette.m3onSurface
        clipRipple: true
        onTapped: root.dismissed()
    }
}
