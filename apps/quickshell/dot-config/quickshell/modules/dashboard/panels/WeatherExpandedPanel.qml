// panels/WeatherExpandedPanel.qml
// Task 19: Expanded weather view for the Weather tab.
// Shows all available HA weather data (or wttr.in fallback) with larger presentation.
// Background: m3surfaceContainerLow, rounding: lg.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import config
import services
import "../../../components"

Item {
    id: root

    // ---- wttr.in fallback data (shared with WeatherPanel logic) ----
    property var _wttr: QtObject {
        property string icon:      ""
        property string temp:      ""
        property string condition: ""
    }

    Timer {
        interval: 1800000
        running:  !HomeAssistant.available
        repeat:   true
        onTriggered: wttrProc.running = true
    }

    Component.onCompleted: { if (!HomeAssistant.available) wttrProc.running = true }

    Process {
        id: wttrProc
        command: ["curl", "-sf", "--max-time", "5", "wttr.in/?format=%c|%t|%C"]
        stdout: StdioCollector {
            onStreamFinished: {
                let parts = this.text.trim().split("|")
                if (parts.length >= 3) {
                    root._wttr.icon      = parts[0].trim()
                    root._wttr.temp      = parts[1].trim().replace("+", "")
                    root._wttr.condition = parts[2].trim()
                }
            }
        }
    }

    // ---- Layout ----
    Rectangle {
        anchors.fill: parent
        color:  Colours.tPalette.m3surfaceContainerLow
        radius: Appearance.rounding.lg
        Behavior on color { CAnim {} }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Appearance.spacing.xl

            // Giant weather icon
            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: HomeAssistant.available
                      ? (HomeAssistant.conditionIcons[HomeAssistant.weatherCondition] ?? "🌤")
                      : root._wttr.icon
                font.pixelSize: 96
                horizontalAlignment: Text.AlignHCenter
            }

            // Temperature — xxl
            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: HomeAssistant.available ? HomeAssistant.weatherTemperature : root._wttr.temp
                font.pixelSize: Appearance.font.xxl * 2
                font.weight:    Font.Light
                horizontalAlignment: Text.AlignHCenter
            }

            // Condition
            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: HomeAssistant.available ? HomeAssistant.weatherCondition : root._wttr.condition
                color: Colours.tPalette.m3onSurfaceVariant
                font.pixelSize: Appearance.font.xl
                horizontalAlignment: Text.AlignHCenter
            }

            // Fallback notice when neither HA nor wttr loaded yet
            StyledText {
                visible: !HomeAssistant.available && root._wttr.temp === ""
                Layout.alignment: Qt.AlignHCenter
                text: "Loading weather data…"
                color: Colours.tPalette.m3onSurfaceVariant
            }

            // Dog walk section if HA available
            Rectangle {
                visible: HomeAssistant.available && HomeAssistant.dogWalkTime !== ""
                Layout.alignment: Qt.AlignHCenter
                color:  Colours.tPalette.m3surfaceContainer
                radius: Appearance.rounding.md
                implicitWidth:  280
                implicitHeight: dogCol.implicitHeight + Appearance.padding.lg * 2
                Behavior on color { CAnim {} }

                ColumnLayout {
                    id: dogCol
                    anchors.centerIn: parent
                    spacing: Appearance.spacing.xs

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: "\uf1b0"
                        color: {
                            if (HomeAssistant.dogWalkMinutes > 360) return Colours.tPalette.m3error
                            if (HomeAssistant.dogWalkMinutes > 240) return Colours.palette.m3tertiary
                            return Colours.tPalette.m3onSurface
                        }
                        font.family:    Appearance.font.family.mono
                        font.pixelSize: 40
                        horizontalAlignment: Text.AlignHCenter
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: HomeAssistant.dogWalkTime + " since last walk"
                        color: Colours.tPalette.m3onSurfaceVariant
                        font.pixelSize: Appearance.font.lg
                    }
                }
            }
        }
    }
}
