// modules/controlcenter/NavRail.qml
// Vertical icon+label navigation rail for the Control Center.
// Items: Audio, Network, Bluetooth, Notifications, Appearance, Session
// Session is pinned to the bottom.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import config
import services
import "../../components"

Item {
    id: root

    property int activeIndex: 0
    signal indexChanged(int index)

    implicitWidth: 96
    implicitHeight: layout.implicitHeight

    // Nav items data
    readonly property var _items: [
        { icon: "volume_up",      label: "Audio" },
        { icon: "wifi",           label: "Network" },
        { icon: "bluetooth",      label: "Bluetooth" },
        { icon: "notifications",  label: "Notifications" },
        { icon: "palette",        label: "Appearance" },
    ]

    ColumnLayout {
        id: layout

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        spacing: Appearance.spacing.xs

        // Top padding
        Item { implicitHeight: Appearance.padding.lg }

        // Main nav items (0-4)
        Repeater {
            model: root._items

            delegate: NavItem {
                required property var modelData
                required property int index

                Layout.alignment: Qt.AlignHCenter

                icon: modelData.icon
                label: modelData.label
                active: root.activeIndex === index
                navIndex: index
                onActivated: idx => root.indexChanged(idx)
            }
        }

        // Spacer — pushes Session to bottom
        Item { Layout.fillHeight: true }

        // Session (index 5) — pinned to bottom
        NavItem {
            Layout.alignment: Qt.AlignHCenter

            icon: "power_settings_new"
            label: "Session"
            active: root.activeIndex === 5
            navIndex: 5
            onActivated: idx => root.indexChanged(idx)
        }

        // Bottom padding
        Item { implicitHeight: Appearance.padding.lg }
    }

    // ---- Inline NavItem component ----
    component NavItem: Item {
        id: navItem

        property string icon: ""
        property string label: ""
        property bool active: false
        property int navIndex: 0

        signal activated(int idx)

        implicitWidth: 64
        implicitHeight: iconBg.implicitHeight + labelText.implicitHeight + Appearance.spacing.xs

        // Active pill background
        Rectangle {
            id: iconBg

            anchors.horizontalCenter: parent.horizontalCenter
            y: 0

            implicitWidth: 56
            implicitHeight: 32
            radius: Appearance.rounding.full

            color: navItem.active
                ? Colours.tPalette.m3secondaryContainer
                : "transparent"

            Behavior on color { CAnim {} }

            MaterialIcon {
                anchors.centerIn: parent
                icon: navItem.icon
                size: Appearance.font.xl
                fill: navItem.active ? 1 : 0
                fillAnimated: true
                color: navItem.active
                    ? Colours.palette.m3onSecondaryContainer
                    : Colours.tPalette.m3onSurfaceVariant

                Behavior on color { CAnim {} }
            }

            StateLayer {
                color: navItem.active
                    ? Colours.palette.m3onSecondaryContainer
                    : Colours.palette.m3onSurface
                radius: parent.radius
                clipRipple: true

                onTapped: navItem.activated(navItem.navIndex)
            }
        }

        StyledText {
            id: labelText

            anchors {
                top: iconBg.bottom
                topMargin: Appearance.spacing.xs
                horizontalCenter: parent.horizontalCenter
            }

            text: navItem.label
            font.pixelSize: Appearance.font.sm
            color: navItem.active
                ? Colours.tPalette.m3onSurface
                : Colours.tPalette.m3onSurfaceVariant

            Behavior on color { CAnim {} }
        }
    }
}
