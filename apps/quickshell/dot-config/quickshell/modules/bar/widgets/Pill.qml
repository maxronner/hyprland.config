// modules/bar/widgets/Pill.qml
// Grouped sub-container for bar widgets. Provides a subtle rounded background
// to visually cluster related widgets (e.g. clock+calendar, network+bluetooth).
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import config
import services
import "../../../components"

Rectangle {
    id: root

    default property alias content: innerLayout.data

    Layout.fillWidth: true
    Layout.leftMargin: Appearance.padding.xs
    Layout.rightMargin: Appearance.padding.xs
    implicitHeight: innerLayout.implicitHeight + Appearance.padding.xs * 2

    radius: Appearance.rounding.sm
    color: Colours.tPalette.m3surfaceContainerHigh

    Behavior on color { CAnim {} }

    ColumnLayout {
        id: innerLayout
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            margins: 2
        }
        spacing: Appearance.spacing.xs
    }
}
