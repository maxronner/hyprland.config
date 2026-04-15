// panels/PerformancePanel.qml
// Live performance values + sparklines. Migrated from dashboard/PerformanceTab.qml.
// Each metric in its own M3 card (surfaceContainerLow, rounding: md).
// Sparklines recolored with M3 tokens. All existing sparkline drawing logic preserved.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import config
import services
import "../../../components"

Item {
    id: root

    // ---- Metric card component ----
    component MetricCard: Rectangle {
        id: card

        property string label:    ""
        property string value:    ""
        property color  valColor: Colours.tPalette.m3onSurface
        property var    history:  []
        property real   maxVal:   100
        property color  lineCol:  Colours.tPalette.m3primary

        color:  Colours.tPalette.m3surfaceContainerLow
        radius: Appearance.rounding.md
        Behavior on color { CAnim {} }

        ColumnLayout {
            anchors {
                fill:    parent
                margins: Appearance.padding.md
            }
            spacing: Appearance.spacing.xs

            // Label row
            StyledText {
                text:  card.label
                color: Colours.tPalette.m3onSurfaceVariant
                font.pixelSize: Appearance.font.sm
            }

            // Live value
            StyledText {
                text:  card.value
                color: card.valColor
                font.family:    Appearance.font.family.mono
                font.pixelSize: Appearance.font.xl
                font.weight:    Font.Medium
            }

            // Sparkline
            Sparkline {
                Layout.fillWidth:  true
                Layout.fillHeight: true
                values:    card.history
                maxValue:  card.maxVal
                lineColor: card.lineCol
                fillColor: Qt.rgba(card.lineCol.r, card.lineCol.g, card.lineCol.b, 0.15)
                gridColor: Colours.tPalette.m3outlineVariant
            }
        }
    }

    // ---- Grid of metric cards ----
    GridLayout {
        anchors.fill: parent
        columns:      2
        rowSpacing:   Appearance.spacing.md
        columnSpacing: Appearance.spacing.md

        // CPU
        MetricCard {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            label:   "CPU"
            value:   Math.round(PerformanceModel.cpuUsage) + "%"
            valColor: {
                if (PerformanceModel.cpuSeverity === "critical") return Colours.tPalette.m3error
                if (PerformanceModel.cpuSeverity === "warning")  return Colours.palette.m3tertiary
                return Colours.tPalette.m3onSurface
            }
            history:  PerformanceModel.cpuHistory
            maxVal:   100
            lineCol:  Colours.tPalette.m3primary
        }

        // Memory
        MetricCard {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            label:   "Memory"
            value:   PerformanceModel.memUsedGb.toFixed(1) + " / " + PerformanceModel.memTotalGb.toFixed(0) + " GB"
            valColor: PerformanceModel.memSeverity === "critical"
                      ? Colours.tPalette.m3error
                      : Colours.tPalette.m3onSurface
            history:  PerformanceModel.memHistory
            maxVal:   PerformanceModel.memTotalGb > 0 ? PerformanceModel.memTotalGb : 32
            lineCol:  Colours.tPalette.m3secondary
        }

        // Temperature
        MetricCard {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            label:   "Temperature"
            value:   PerformanceModel.tempC + " °C"
            valColor: {
                if (PerformanceModel.tempSeverity === "critical") return Colours.tPalette.m3error
                if (PerformanceModel.tempSeverity === "warning")  return Colours.palette.m3tertiary
                return Colours.tPalette.m3onSurface
            }
            history:  PerformanceModel.tempHistory
            maxVal:   100
            lineCol:  Colours.palette.m3tertiary
        }

        // Battery
        MetricCard {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            label:   "Battery"
            value:   Math.round(PerformanceModel.batteryPercent) + "%"
            valColor: {
                if (PerformanceModel.batterySeverity === "critical") return Colours.tPalette.m3error
                if (PerformanceModel.batterySeverity === "warning")  return Colours.palette.m3tertiary
                return Colours.tPalette.m3onSurface
            }
            history:  PerformanceModel.batteryHistory
            maxVal:   100
            lineCol:  Colours.tPalette.m3primaryContainer
        }
    }
}
