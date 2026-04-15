// modules/bar/Bar.qml
// M3 sidebar bar layout. Grouped widgets in a ColumnLayout.
// Background: m3surfaceContainer, radius: md (17px).
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import config
import services
import "../../components"
import "widgets"

Rectangle {
    id: root

    // Dashboard toggle state passed in from BarWrapper / shell.qml
    property bool dashboardVisible: false
    signal dashboardToggled()

    // Bar dimensions — 52px wide, fills parent height
    implicitWidth: 52
    implicitHeight: parent?.height ?? 600

    color: Colours.tPalette.m3surfaceContainer
    radius: Appearance.rounding.md

    Behavior on color { CAnim {} }

    ColumnLayout {
        id: layout
        anchors {
            fill: parent
            topMargin: Appearance.padding.xl
            bottomMargin: Appearance.padding.xl
            leftMargin: Appearance.padding.sm
            rightMargin: Appearance.padding.sm
        }
        spacing: Appearance.spacing.sm

        DashboardToggle {
            id: dashToggle
            active: root.dashboardVisible
            onClicked: root.dashboardToggled()
        }

        Pill {
            Notifications {}
            Weather {}
            Dog {}
            Workspaces {}
        }

        // ── Spacer pushes system widgets to the bottom ──
        Item { Layout.fillHeight: true }

        IdleInhibitor {}

        Calendar {}
        Clock {}

        Pill {
            Network {}
            Bluetooth {}
            PulseAudio {}
        }

        Battery {}
    }
}
