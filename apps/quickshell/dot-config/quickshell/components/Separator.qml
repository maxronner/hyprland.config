// Separator.qml
// M3 horizontal divider. 1px outline-variant line with xs top/bottom margins.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import config
import services

Rectangle {
    height: 1
    color: Colours.tPalette.m3outlineVariant
    Layout.fillWidth: true
    Layout.topMargin: Appearance.spacing.xs
    Layout.bottomMargin: Appearance.spacing.xs
}
