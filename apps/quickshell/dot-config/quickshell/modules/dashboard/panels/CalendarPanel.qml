// panels/CalendarPanel.qml
// Interactive month calendar migrated from dashboard/Calendar.qml.
// Restyled with M3 tokens: today = m3primary pill, header in m3onSurface,
// day labels in m3onSurfaceVariant.
// Background: m3surfaceContainerLow, rounding: md.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import config
import services
import "../../../components"

Rectangle {
    id: root

    color:  Colours.tPalette.m3surfaceContainerLow
    radius: Appearance.rounding.md

    Behavior on color { CAnim {} }

    implicitWidth:  240
    implicitHeight: 260

    // ---- Calendar state ----
    property date currentDate:   new Date()
    property int  displayMonth:  currentDate.getMonth()
    property int  displayYear:   currentDate.getFullYear()

    // Refresh at midnight
    Timer {
        id: midnightTimer
        running: true
        repeat:  false
        interval: {
            var now      = new Date();
            var midnight = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1);
            return midnight - now + 1000;
        }
        onTriggered: {
            root.currentDate = new Date();
            midnightTimer.restart();
        }
    }

    function daysInMonth(month, year)   { return new Date(year, month + 1, 0).getDate() }
    function firstDayOffset(month, year){ return (new Date(year, month, 1).getDay() + 6) % 7 }
    function monthName(month) {
        return ["January","February","March","April","May","June",
                "July","August","September","October","November","December"][month]
    }

    // ---- Layout ----
    ColumnLayout {
        anchors {
            fill: parent
            margins: Appearance.padding.md
        }
        spacing: Appearance.spacing.sm

        // Month/year header + arrows
        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.xs

            // Previous month button
            Item {
                width: 24; height: 24

                MaterialIcon {
                    anchors.centerIn: parent
                    icon: "chevron_left"
                    size: Appearance.font.lg
                    color: Colours.tPalette.m3onSurface
                }

                StateLayer {
                    radius: Appearance.rounding.full
                    color:  Colours.palette.m3onSurface
                    onTapped: (_) => {
                        if (root.displayMonth === 0) {
                            root.displayMonth = 11
                            root.displayYear  -= 1
                        } else {
                            root.displayMonth -= 1
                        }
                    }
                }
            }

            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text:  root.monthName(root.displayMonth) + " " + root.displayYear
                font.weight:   Font.Medium
            }

            // Next month button
            Item {
                width: 24; height: 24

                MaterialIcon {
                    anchors.centerIn: parent
                    icon: "chevron_right"
                    size: Appearance.font.lg
                    color: Colours.tPalette.m3onSurface
                }

                StateLayer {
                    radius: Appearance.rounding.full
                    color:  Colours.palette.m3onSurface
                    onTapped: (_) => {
                        if (root.displayMonth === 11) {
                            root.displayMonth = 0
                            root.displayYear  += 1
                        } else {
                            root.displayMonth += 1
                        }
                    }
                }
            }
        }

        // Day-of-week headers
        Row {
            Layout.fillWidth: true
            spacing: 0

            Repeater {
                model: ["Mo","Tu","We","Th","Fr","Sa","Su"]

                delegate: StyledText {
                    required property string modelData
                    width: (root.width - Appearance.padding.md * 2) / 7
                    horizontalAlignment: Text.AlignHCenter
                    text:  modelData
                    color: Colours.tPalette.m3onSurfaceVariant
                    font.pixelSize: Appearance.font.sm
                }
            }
        }

        // Day grid
        Grid {
            id: dayGrid
            Layout.fillWidth:  true
            Layout.fillHeight: true
            columns: 7
            spacing: 0

            property int offset:    root.firstDayOffset(root.displayMonth, root.displayYear)
            property int totalDays: root.daysInMonth(root.displayMonth, root.displayYear)
            property int cellCount: offset + totalDays

            Repeater {
                model: dayGrid.cellCount

                delegate: Item {
                    required property int index
                    width:  (root.width - Appearance.padding.md * 2) / 7
                    height: 28

                    property int  dayNumber: index - dayGrid.offset + 1
                    property bool isDay:     index >= dayGrid.offset
                    property bool isToday:   isDay &&
                        dayNumber === root.currentDate.getDate() &&
                        root.displayMonth === root.currentDate.getMonth() &&
                        root.displayYear  === root.currentDate.getFullYear()

                    Rectangle {
                        anchors.centerIn: parent
                        width:  parent.width  - 4
                        height: parent.height - 2
                        radius: Appearance.rounding.full
                        color:  isToday ? Colours.tPalette.m3primary : "transparent"
                        Behavior on color { CAnim {} }

                        StyledText {
                            anchors.centerIn: parent
                            text:  isDay ? dayNumber : ""
                            color: isToday ? Colours.tPalette.m3onPrimary : Colours.tPalette.m3onSurface
                            font.pixelSize: Appearance.font.sm
                            font.weight:    isToday ? Font.Medium : Font.Normal
                        }
                    }
                }
            }
        }
    }
}
