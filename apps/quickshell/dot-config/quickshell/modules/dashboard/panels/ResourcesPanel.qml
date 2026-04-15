// panels/ResourcesPanel.qml
// NEW: Vertical progress bars for CPU / Memory / Temperature.
// Data from PerformanceModel singleton.
// Three bars colored with primary/secondary/tertiary tokens.
// Bar fill height animates smoothly (0–100%).
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

    implicitWidth:  180
    implicitHeight: 120

    // Helper: select severity color for a given metric
    function severityColor(severity, trackColor) {
        if (severity === "critical") return Colours.tPalette.m3error
        if (severity === "warning")  return Colours.palette.m3tertiary
        return trackColor
    }

    RowLayout {
        anchors {
            fill: parent
            margins: Appearance.padding.md
        }
        spacing: Appearance.spacing.lg

        Item { Layout.fillWidth: true } // left spacer

        // ---- CPU Bar ----
        ColumnLayout {
            Layout.fillHeight: true
            spacing: Appearance.spacing.xs

            // Bar
            Item {
                Layout.preferredWidth: 12
                Layout.fillHeight: true

                // Track
                Rectangle {
                    anchors.fill: parent
                    radius: Appearance.rounding.full
                    color:  Colours.tPalette.m3surfaceContainerHighest
                    Behavior on color { CAnim {} }
                }

                // Fill
                Rectangle {
                    id: cpuFill
                    anchors {
                        bottom: parent.bottom
                        left:   parent.left
                        right:  parent.right
                    }
                    radius: Appearance.rounding.full
                    color:  root.severityColor(PerformanceModel.cpuSeverity, Colours.tPalette.m3primary)
                    Behavior on color { CAnim {} }

                    height: parent.height * Math.min(PerformanceModel.cpuUsage / 100, 1.0)
                    Behavior on height {
                        NumberAnimation {
                            duration: Appearance.anim.duration.md
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Appearance.anim.standard
                        }
                    }
                }
            }

            // Label
            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                icon: "memory"
                size: Appearance.font.md
                color: Colours.tPalette.m3onSurfaceVariant
            }
        }

        // ---- Memory Bar ----
        ColumnLayout {
            Layout.fillHeight: true
            spacing: Appearance.spacing.xs

            Item {
                Layout.preferredWidth: 12
                Layout.fillHeight: true

                Rectangle {
                    anchors.fill: parent
                    radius: Appearance.rounding.full
                    color:  Colours.tPalette.m3surfaceContainerHighest
                    Behavior on color { CAnim {} }
                }

                Rectangle {
                    anchors {
                        bottom: parent.bottom
                        left:   parent.left
                        right:  parent.right
                    }
                    radius: Appearance.rounding.full
                    color:  root.severityColor(PerformanceModel.memSeverity, Colours.tPalette.m3secondary)
                    Behavior on color { CAnim {} }

                    height: parent.height * (PerformanceModel.memTotalGb > 0
                            ? Math.min(PerformanceModel.memUsedGb / PerformanceModel.memTotalGb, 1.0)
                            : 0)
                    Behavior on height {
                        NumberAnimation {
                            duration: Appearance.anim.duration.md
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Appearance.anim.standard
                        }
                    }
                }
            }

            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                icon: "dns"
                size: Appearance.font.md
                color: Colours.tPalette.m3onSurfaceVariant
            }
        }

        // ---- Temperature Bar ----
        ColumnLayout {
            Layout.fillHeight: true
            spacing: Appearance.spacing.xs

            Item {
                Layout.preferredWidth: 12
                Layout.fillHeight: true

                Rectangle {
                    anchors.fill: parent
                    radius: Appearance.rounding.full
                    color:  Colours.tPalette.m3surfaceContainerHighest
                    Behavior on color { CAnim {} }
                }

                Rectangle {
                    anchors {
                        bottom: parent.bottom
                        left:   parent.left
                        right:  parent.right
                    }
                    radius: Appearance.rounding.full
                    color:  root.severityColor(PerformanceModel.tempSeverity, Colours.palette.m3tertiary)
                    Behavior on color { CAnim {} }

                    // 100°C = full bar
                    height: parent.height * Math.min(PerformanceModel.tempC / 100, 1.0)
                    Behavior on height {
                        NumberAnimation {
                            duration: Appearance.anim.duration.md
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Appearance.anim.standard
                        }
                    }
                }
            }

            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                icon: "thermometer"
                size: Appearance.font.md
                color: Colours.tPalette.m3onSurfaceVariant
            }
        }

        Item { Layout.fillWidth: true } // right spacer
    }
}
