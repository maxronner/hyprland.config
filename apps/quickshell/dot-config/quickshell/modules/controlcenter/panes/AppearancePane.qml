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
                    value: Appearance.rounding.scale
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
                    value: Appearance.font.scale
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
            SelectableCardRow {
                selected: Appearance.anim.preset === "m3"
                icon: "animation"
                iconFill: selected ? 1 : 0
                primaryText: "M3 Default"
                secondaryText: "Expressive spatial curves"
                onTapped: Config.set("appearance.anim.preset", "m3")
            }

            // Snappy preset row
            SelectableCardRow {
                selected: Appearance.anim.preset === "snappy"
                icon: "speed"
                iconFill: selected ? 1 : 0
                primaryText: "Snappy"
                secondaryText: "Tighter, faster transitions"
                onTapped: Config.set("appearance.anim.preset", "snappy")
            }

            // ======== WALLPAPER FRAME ========
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Colours.tPalette.m3outlineVariant
                opacity: 0.5
            }

            StyledText {
                text: "Wallpaper Frame"
                font.pixelSize: Appearance.font.md
                color: Colours.tPalette.m3onSurfaceVariant
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.sm

                StyledText {
                    text: "Outer gap"
                    color: Colours.tPalette.m3onSurface
                }

                StyledSlider {
                    Layout.fillWidth: true
                    value: Appearance.inset.gapOuter
                    from: 0
                    to: 40
                    stepSize: 1
                    onMoved: newVal => Config.set("background.inset.gapOuter", newVal)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.sm

                StyledText {
                    text: "Inner gap"
                    color: Colours.tPalette.m3onSurface
                }

                StyledSlider {
                    Layout.fillWidth: true
                    value: Appearance.inset.gapInner
                    from: 0
                    to: 40
                    stepSize: 1
                    onMoved: newVal => Config.set("background.inset.gapInner", newVal)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.sm

                StyledText {
                    text: "Radius"
                    color: Colours.tPalette.m3onSurface
                }

                StyledSlider {
                    Layout.fillWidth: true
                    value: Appearance.inset.radius
                    from: 0
                    to: 60
                    stepSize: 1
                    onMoved: newVal => Config.set("background.inset.radius", newVal)
                }
            }

            // ======== DESKTOP CLOCK ========
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Colours.tPalette.m3outlineVariant
                opacity: 0.5
            }

            StyledText {
                text: "Desktop Clock"
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
                    checked: Config.pending.background?.desktopClock?.enabled ?? false
                    onToggled: Config.set("background.desktopClock.enabled", !checked)
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.sm
                enabled: Config.pending.background?.desktopClock?.enabled ?? false
                opacity: enabled ? 1.0 : 0.38

                Behavior on opacity { NumberAnimation { duration: 150 } }

                StyledText {
                    text: "Position"
                    color: Colours.tPalette.m3onSurface
                }

                GridLayout {
                    Layout.alignment: Qt.AlignHCenter
                    columns: 3
                    rowSpacing: Appearance.spacing.xs
                    columnSpacing: Appearance.spacing.xs

                    Repeater {
                        model: [
                            "top-left", "top-center", "top-right",
                            "middle-left", "middle-center", "middle-right",
                            "bottom-left", "bottom-center", "bottom-right"
                        ]

                        Rectangle {
                            id: cell
                            required property string modelData
                            readonly property bool selected:
                                (Config.pending.background?.desktopClock?.position ?? "bottom-right") === modelData

                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 28
                            radius: Appearance.rounding.sm
                            color: selected
                                ? Colours.tPalette.m3secondaryContainer
                                : Colours.tPalette.m3surfaceContainerHigh

                            Behavior on color { CAnim {} }

                            Rectangle {
                                width: 8
                                height: 8
                                radius: 2
                                color: cell.selected
                                    ? Colours.palette.m3onSecondaryContainer
                                    : Colours.tPalette.m3onSurfaceVariant

                                readonly property var parts: cell.modelData.split("-")
                                anchors {
                                    top: parts[0] === "top" ? parent.top : undefined
                                    bottom: parts[0] === "bottom" ? parent.bottom : undefined
                                    verticalCenter: parts[0] === "middle" ? parent.verticalCenter : undefined
                                    left: parts[1] === "left" ? parent.left : undefined
                                    right: parts[1] === "right" ? parent.right : undefined
                                    horizontalCenter: parts[1] === "center" ? parent.horizontalCenter : undefined
                                    margins: 4
                                }
                            }

                            StateLayer {
                                radius: parent.radius
                                color: cell.selected
                                    ? Colours.palette.m3onSecondaryContainer
                                    : Colours.palette.m3onSurface
                                clipRipple: true
                                onTapped: Config.set("background.desktopClock.position", cell.modelData)
                            }
                        }
                    }
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
                        value: Config.pending.background?.desktopClock?.scale ?? 1.0
                        from: 0.5
                        to: 2.0
                        stepSize: 0.25
                        onMoved: newVal => Config.set("background.desktopClock.scale", newVal)
                    }
                }
            }

            Item { implicitHeight: Appearance.padding.md }
        }
    }
}
