// modules/dashboard/Dashboard.qml
// Main dashboard surface: M3 card at ~60% × 50% of screen, elevation level 3.
// Contains Tabs at the top and a StackLayout for per-tab content below.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import config
import services
import "../../components"
import "panels"

Rectangle {
    id: root

    property real topPadding: 0

    // Screen dimensions injected from parent (Screen attached property may be 0 before window maps)
    property real screenWidth:  1920
    property real screenHeight: 1080

    // ~60% width, ~50% height — clamp so it is never wider than 1200px
    implicitWidth:  Math.min(Math.round(screenWidth  * 0.60), 1200)
    implicitHeight: Math.round(screenHeight * 0.50)

    color:  Colours.tPalette.m3surfaceContainer
    radius: Appearance.rounding.lg


    Behavior on color { CAnim {} }

    ColumnLayout {
        anchors {
            fill: parent
            topMargin:    root.topPadding + Appearance.padding.lg
            bottomMargin: Appearance.padding.lg
            leftMargin:   Appearance.padding.lg
            rightMargin:  Appearance.padding.lg
        }
        spacing: Appearance.spacing.md

        // ---- Tab bar ----
        Tabs {
            id: tabs
            Layout.fillWidth: true
            onTabChanged: (index) => stack.currentIndex = index
        }

        // ---- Tab content ----
        StackLayout {
            id: stack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabs.currentIndex

            // Tab 0: Dashboard overview
            GridLayout {
                id: overviewGrid
                columns: 3
                rowSpacing:    Appearance.spacing.md
                columnSpacing: Appearance.spacing.md

                // Row 0, col 0: DateTime (tall)
                DateTimePanel {
                    Layout.rowSpan: 1
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumWidth: 160
                }

                // Row 0, col 1: Calendar
                CalendarPanel {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumWidth: 220
                }

                // Row 0, col 2: Weather
                WeatherPanel {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                // Row 1, col 0: Resources
                ResourcesPanel {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 120
                }

                // Row 1, col 1-2: SystemInfo
                SystemInfoPanel {
                    Layout.columnSpan: 2
                    Layout.fillWidth:  true
                    Layout.fillHeight: true
                }
            }

            // Tab 1: Performance
            PerformancePanel {
                Layout.fillWidth:  true
                Layout.fillHeight: true
            }

            // Tab 2: Weather (expanded)
            WeatherExpandedPanel {
                Layout.fillWidth:  true
                Layout.fillHeight: true
            }
        }
    }
}
