// panes/Appearance.qml
// Appearance pane: transparency, rounding, font size, animation preset.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import config
import services
import "../../../components"
import "../../../components/controls"

Item {
    id: root

    Flickable {
        anchors.fill: parent
        anchors.margins: Appearance.padding.lg
        contentHeight: layout.implicitHeight
        clip: true

        ColumnLayout {
            id: layout
            width: parent.width
            spacing: Appearance.spacing.md

            StyledText {
                text: "Appearance"
                font.pixelSize: Appearance.font.xl
                color: Colours.tPalette.m3onSurface
            }

            // ======== TRANSPARENCY ========
            StyledText {
                text: "Transparency"
                font.pixelSize: Appearance.font.md
                color: Colours.tPalette.m3onSurfaceVariant
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.sm

                StyledText {
                    text: "Enable"
                    Layout.fillWidth: true
                    color: Colours.tPalette.m3onSurface
                }

                ToggleButton {
                    checked: Appearance.transparency.enabled
                    onToggled: Config.set("appearance.transparency.enabled", !checked)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.sm
                enabled: Appearance.transparency.enabled
                opacity: enabled ? 1.0 : 0.38

                Behavior on opacity { NumberAnimation { duration: 150 } }

                StyledText {
                    text: "Opacity"
                    color: Colours.tPalette.m3onSurface
                }

                StyledSlider {
                    Layout.fillWidth: true
                    value: Appearance.transparency.base
                    from: 0.0
                    to: 1.0
                    onMoved: newVal => {
                        if (newVal !== Appearance.transparency.base)
                            Config.set("appearance.transparency.base", newVal)
                    }
}
            }

            // ======== ROUNDING ========
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Colours.tPalette.m3outlineVariant
                opacity: 0.5
            }

            StyledText {
                text: "Rounding"
                font.pixelSize: Appearance.font.md
                color: Colours.tPalette.m3onSurfaceVariant
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.sm

                StyledText {
                    text: "Scale"
                    color: Colours.tPalette.m3onSurface
                }

                StyledSlider {
                    Layout.fillWidth: true
                    value: (Appearance.rounding.scale - 0.5) / 1.5
                    from: 0.5
                    to: 2.0
                    stepSize: 0.25
                    onMoved: newVal => Config.set("appearance.rounding.scale", newVal)
                }
            }

            // ======== FONT SIZE ========
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Colours.tPalette.m3outlineVariant
                opacity: 0.5
            }

            StyledText {
                text: "Font Size"
                font.pixelSize: Appearance.font.md
                color: Colours.tPalette.m3onSurfaceVariant
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.sm

                StyledText {
                    text: "Scale"
                    color: Colours.tPalette.m3onSurface
                }

                StyledSlider {
                    Layout.fillWidth: true
                    value: (Appearance.font.scale - 0.5) / 1.5
                    from: 0.5
                    to: 2.0
                    stepSize: 0.25
                    onMoved: newVal => Config.set("appearance.font.sizeScale", newVal)
                }
            }

            // ======== ANIMATION PRESET ========
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Colours.tPalette.m3outlineVariant
                opacity: 0.5
            }

            StyledText {
                text: "Animation Style"
                font.pixelSize: Appearance.font.md
                color: Colours.tPalette.m3onSurfaceVariant
            }

            // M3 Default preset row
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: m3Row.implicitHeight + Appearance.padding.md * 2
                radius: Appearance.rounding.sm
                color: Appearance.anim.preset === "m3"
                    ? Colours.tPalette.m3secondaryContainer
                    : Colours.tPalette.m3surfaceContainerHigh

                Behavior on color { CAnim {} }

                RowLayout {
                    id: m3Row
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        margins: Appearance.padding.md
                    }
                    spacing: Appearance.spacing.sm

                    MaterialIcon {
                        icon: "animation"
                        size: Appearance.font.lg
                        fill: Appearance.anim.preset === "m3" ? 1 : 0
                        color: Appearance.anim.preset === "m3"
                            ? Colours.palette.m3onSecondaryContainer
                            : Colours.tPalette.m3onSurface
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        StyledText {
                            text: "M3 Default"
                            font.pixelSize: Appearance.font.md
                            color: Appearance.anim.preset === "m3"
                                ? Colours.palette.m3onSecondaryContainer
                                : Colours.tPalette.m3onSurface
                        }

                        StyledText {
                            text: "Expressive spatial curves"
                            font.pixelSize: Appearance.font.sm
                            color: Appearance.anim.preset === "m3"
                                ? Colours.palette.m3onSecondaryContainer
                                : Colours.tPalette.m3onSurfaceVariant
                        }
                    }
                }

                StateLayer {
                    radius: parent.radius
                    color: Appearance.anim.preset === "m3"
                        ? Colours.palette.m3onSecondaryContainer
                        : Colours.palette.m3onSurface
                    clipRipple: true
                    onTapped: Config.set("appearance.anim.preset", "m3")
                }
            }

            // Snappy preset row
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: snappyRow.implicitHeight + Appearance.padding.md * 2
                radius: Appearance.rounding.sm
                color: Appearance.anim.preset === "snappy"
                    ? Colours.tPalette.m3secondaryContainer
                    : Colours.tPalette.m3surfaceContainerHigh

                Behavior on color { CAnim {} }

                RowLayout {
                    id: snappyRow
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        margins: Appearance.padding.md
                    }
                    spacing: Appearance.spacing.sm

                    MaterialIcon {
                        icon: "speed"
                        size: Appearance.font.lg
                        fill: Appearance.anim.preset === "snappy" ? 1 : 0
                        color: Appearance.anim.preset === "snappy"
                            ? Colours.palette.m3onSecondaryContainer
                            : Colours.tPalette.m3onSurface
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        StyledText {
                            text: "Snappy"
                            font.pixelSize: Appearance.font.md
                            color: Appearance.anim.preset === "snappy"
                                ? Colours.palette.m3onSecondaryContainer
                                : Colours.tPalette.m3onSurface
                        }

                        StyledText {
                            text: "Tighter, faster transitions"
                            font.pixelSize: Appearance.font.sm
                            color: Appearance.anim.preset === "snappy"
                                ? Colours.palette.m3onSecondaryContainer
                                : Colours.tPalette.m3onSurfaceVariant
                        }
                    }
                }

                StateLayer {
                    radius: parent.radius
                    color: Appearance.anim.preset === "snappy"
                        ? Colours.palette.m3onSecondaryContainer
                        : Colours.palette.m3onSurface
                    clipRipple: true
                    onTapped: Config.set("appearance.anim.preset", "snappy")
                }
            }

            Item { implicitHeight: Appearance.padding.md }
        }
    }
}
