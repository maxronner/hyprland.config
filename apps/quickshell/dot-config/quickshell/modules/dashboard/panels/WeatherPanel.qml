// panels/WeatherPanel.qml
// Weather icon + temperature + condition. Data from HomeAssistant service
// (falls back to wttr.in). Includes dog walk timer when HA available.
// Background: m3surfaceContainerLow, rounding: lg.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import config
import services
import "../../../components"

Rectangle {
    id: root

    color:  Colours.tPalette.m3surfaceContainerLow
    radius: Appearance.rounding.lg

    Behavior on color { CAnim {} }

    implicitWidth:  180
    implicitHeight: 200

    // ---- wttr.in fallback data ----
    property var _wttr: QtObject {
        property string icon:      ""
        property string temp:      ""
        property string condition: ""
    }

    readonly property string dogWalkSeverity:
        HomeAssistant.dogWalkMinutes > 360 ? "critical"
      : HomeAssistant.dogWalkMinutes > 240 ? "warning"
      : "normal"

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

    // ---- Content ----
    ColumnLayout {
        anchors {
            fill: parent
            margins: Appearance.padding.md
        }
        spacing: Appearance.spacing.sm

        // Weather icon (emoji or Unicode)
        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: HomeAssistant.available
                  ? (HomeAssistant.conditionIcons[HomeAssistant.weatherCondition] ?? "")
                  : root._wttr.icon
            font.pixelSize: 48
            horizontalAlignment: Text.AlignHCenter
        }

        // Temperature
        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: HomeAssistant.available ? HomeAssistant.weatherTemperature : root._wttr.temp
            font.pixelSize: Appearance.font.xl
            font.weight:    Font.Medium
            horizontalAlignment: Text.AlignHCenter
        }

        // Condition
        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: HomeAssistant.available ? HomeAssistant.weatherCondition : root._wttr.condition
            color: Colours.tPalette.m3onSurfaceVariant
            horizontalAlignment: Text.AlignHCenter
        }

        // Separator before dog walk
        Rectangle {
            visible: HomeAssistant.available
            Layout.fillWidth: true
            height: 1
            color:  Colours.tPalette.m3outlineVariant
            Behavior on color { CAnim {} }
        }

        // Dog walk section
        ColumnLayout {
            visible: HomeAssistant.available && HomeAssistant.dogWalkTime !== ""
            Layout.fillWidth: true
            spacing: Appearance.spacing.xs

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: "\uf1b0"
                color: Colours.severityColor(root.dogWalkSeverity, Colours.tPalette.m3onSurface)
                font.family:    Appearance.font.family.mono
                font.pixelSize: 28
                horizontalAlignment: Text.AlignHCenter
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: HomeAssistant.dogWalkTime
                color: Colours.tPalette.m3onSurfaceVariant
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: "since last walk"
                color: Colours.tPalette.m3onSurfaceVariant
                font.pixelSize: Appearance.font.sm
            }
        }

        Item { Layout.fillHeight: true }
    }
}
