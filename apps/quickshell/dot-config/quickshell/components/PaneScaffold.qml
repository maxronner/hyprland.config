// PaneScaffold.qml
// Shared scrollable pane scaffold: title + spaced content column.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import config
import services

Item {
    id: root

    property string title: ""
    property real margins: Appearance.padding.lg
    property real spacing: Appearance.spacing.md
    property real titlePixelSize: Appearance.font.xl

    default property alias content: contentLayout.data

    Flickable {
        anchors.fill: parent
        anchors.margins: root.margins
        contentHeight: layout.implicitHeight
        clip: true

        ColumnLayout {
            id: layout
            width: parent.width
            spacing: root.spacing

            StyledText {
                text: root.title
                font.pixelSize: root.titlePixelSize
                color: Colours.tPalette.m3onSurface
                visible: root.title.length > 0
            }

            ColumnLayout {
                id: contentLayout
                Layout.fillWidth: true
                spacing: root.spacing
            }
        }
    }
}
