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
            valColor: Colours.severityColor(PerformanceModel.cpuSeverity, Colours.tPalette.m3onSurface)

            Sparkline {
                Layout.fillWidth:  true
                Layout.fillHeight: true
                values:    PerformanceModel.cpuHistory
                maxValue:  100
                lineColor: Colours.tPalette.m3primary
                fillColor: Qt.rgba(lineColor.r, lineColor.g, lineColor.b, 0.15)
                gridColor: Colours.tPalette.m3outlineVariant
            }
        }

        // Memory
        MetricCard {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            label:   "Memory"
            value:   PerformanceModel.memUsedGb.toFixed(1) + " / " + PerformanceModel.memTotalGb.toFixed(0) + " GB"
            valColor: Colours.severityColor(PerformanceModel.memSeverity, Colours.tPalette.m3onSurface)

            Sparkline {
                Layout.fillWidth:  true
                Layout.fillHeight: true
                values:    PerformanceModel.memHistory
                maxValue:  PerformanceModel.memTotalGb > 0 ? PerformanceModel.memTotalGb : 32
                lineColor: Colours.tPalette.m3secondary
                fillColor: Qt.rgba(lineColor.r, lineColor.g, lineColor.b, 0.15)
                gridColor: Colours.tPalette.m3outlineVariant
            }
        }

        // Temperature
        MetricCard {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            label:   "Temperature"
            value:   PerformanceModel.tempC + " °C"
            valColor: Colours.severityColor(PerformanceModel.tempSeverity, Colours.tPalette.m3onSurface)

            Sparkline {
                Layout.fillWidth:  true
                Layout.fillHeight: true
                values:    PerformanceModel.tempHistory
                maxValue:  100
                lineColor: Colours.palette.m3tertiary
                fillColor: Qt.rgba(lineColor.r, lineColor.g, lineColor.b, 0.15)
                gridColor: Colours.tPalette.m3outlineVariant
            }
        }

        // Battery
        MetricCard {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            label:   "Battery"
            value:   Math.round(PerformanceModel.batteryPercent) + "%"
            valColor: Colours.severityColor(PerformanceModel.batterySeverity, Colours.tPalette.m3onSurface)

            Sparkline {
                Layout.fillWidth:  true
                Layout.fillHeight: true
                values:    PerformanceModel.batteryHistory
                maxValue:  100
                lineColor: Colours.tPalette.m3primaryContainer
                fillColor: Qt.rgba(lineColor.r, lineColor.g, lineColor.b, 0.15)
                gridColor: Colours.tPalette.m3outlineVariant
            }
        }
    }
}
