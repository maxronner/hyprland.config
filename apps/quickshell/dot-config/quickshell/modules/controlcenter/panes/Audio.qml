// panes/Audio.qml
// Audio pane: output/input volume sliders + device selection lists.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import config
import services
import "../../../components"
import "../../../components/controls"

Item {
    id: root

    // ---- Scrollable content ----
    Flickable {
        anchors.fill: parent
        anchors.margins: Appearance.padding.lg
        contentHeight: layout.implicitHeight
        clip: true

        ColumnLayout {
            id: layout
            width: parent.width
            spacing: Appearance.spacing.md

            // ---- Section label ----
            StyledText {
                text: "Audio"
                font.pixelSize: Appearance.font.xl
                color: Colours.tPalette.m3onSurface
            }

            // ======== OUTPUT ========
            StyledText {
                text: "Output"
                font.pixelSize: Appearance.font.md
                color: Colours.tPalette.m3onSurfaceVariant
            }

            // Output mute + volume row
            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.sm

                IconButton {
                    type: "tonal"
                    icon: AudioService.muted ? "volume_off" : "volume_up"
                    checked: !AudioService.muted
                    onClicked: AudioService.toggleMute()
                }

                StyledSlider {
                    Layout.fillWidth: true
                    value: AudioService.muted ? 0 : AudioService.volume
                    from: 0.0
                    to: 1.0
                    onMoved: newVal => AudioService.setVolume(newVal)
                }
            }

            // Output device list
            StyledText {
                text: "Output Devices"
                font.pixelSize: Appearance.font.sm
                color: Colours.tPalette.m3onSurfaceVariant
                visible: AudioService.sinkList.length > 0
            }

            Repeater {
                model: AudioService.sinkList

                delegate: Rectangle {
                    required property var modelData

                    Layout.fillWidth: true
                    implicitHeight: Appearance.sizes.listItem
                    radius: Appearance.rounding.sm
                    readonly property bool _isDefault: modelData.name === AudioService.defaultOutput?.name

                    color: _isDefault
                        ? Colours.tPalette.m3secondaryContainer
                        : "transparent"

                    Behavior on color { CAnim {} }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Appearance.padding.sm
                        spacing: Appearance.spacing.sm

                        MaterialIcon {
                            icon: "speaker"
                            size: Appearance.font.lg
                            color: parent.parent._isDefault
                                ? Colours.palette.m3onSecondaryContainer
                                : Colours.tPalette.m3onSurface
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: modelData.description || modelData.name || "Unknown Device"
                            color: parent.parent._isDefault
                                ? Colours.palette.m3onSecondaryContainer
                                : Colours.tPalette.m3onSurface
                            elide: Text.ElideRight
                        }
                    }

                    StateLayer {
                        radius: parent.radius
                        color: _isDefault
                            ? Colours.palette.m3onSecondaryContainer
                            : Colours.palette.m3onSurface
                        onTapped: AudioService.setDefaultSink(modelData)
                    }
                }
            }

            // ======== INPUT ========
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Colours.tPalette.m3outlineVariant
                opacity: 0.5
            }

            StyledText {
                text: "Input"
                font.pixelSize: Appearance.font.md
                color: Colours.tPalette.m3onSurfaceVariant
            }

            // Input mute + volume row
            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.sm

                IconButton {
                    type: "tonal"
                    icon: AudioService.inputMuted ? "mic_off" : "mic"
                    checked: !AudioService.inputMuted
                    onClicked: AudioService.toggleInputMute()
                }

                StyledSlider {
                    Layout.fillWidth: true
                    value: AudioService.inputMuted ? 0 : AudioService.inputVolume
                    from: 0.0
                    to: 1.0
                    onMoved: newVal => AudioService.setInputVolume(newVal)
                }
            }

            // Input device list
            StyledText {
                text: "Input Devices"
                font.pixelSize: Appearance.font.sm
                color: Colours.tPalette.m3onSurfaceVariant
                visible: AudioService.sourceList.length > 0
            }

            Repeater {
                model: AudioService.sourceList

                delegate: Rectangle {
                    required property var modelData

                    Layout.fillWidth: true
                    implicitHeight: Appearance.sizes.listItem
                    radius: Appearance.rounding.sm
                    readonly property bool _isDefault: modelData.name === AudioService.defaultInput?.name

                    color: _isDefault
                        ? Colours.tPalette.m3secondaryContainer
                        : "transparent"

                    Behavior on color { CAnim {} }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Appearance.padding.sm
                        spacing: Appearance.spacing.sm

                        MaterialIcon {
                            icon: "mic"
                            size: Appearance.font.lg
                            color: parent.parent._isDefault
                                ? Colours.palette.m3onSecondaryContainer
                                : Colours.tPalette.m3onSurface
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: modelData.description || modelData.name || "Unknown Device"
                            color: parent.parent._isDefault
                                ? Colours.palette.m3onSecondaryContainer
                                : Colours.tPalette.m3onSurface
                            elide: Text.ElideRight
                        }
                    }

                    StateLayer {
                        radius: parent.radius
                        color: _isDefault
                            ? Colours.palette.m3onSecondaryContainer
                            : Colours.palette.m3onSurface
                        onTapped: AudioService.setDefaultSource(modelData)
                    }
                }
            }

            // Bottom spacer
            Item { implicitHeight: Appearance.padding.md }
        }
    }
}
