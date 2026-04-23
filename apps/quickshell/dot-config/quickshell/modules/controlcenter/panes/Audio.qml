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

    PaneScaffold {
        anchors.fill: parent
        title: "Audio"

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

            delegate: SelectableCardRow {
                    required property var modelData

                    implicitHeight: Appearance.sizes.listItem
                    readonly property bool _isDefault: modelData.name === AudioService.defaultOutput?.name
                    selected: _isDefault
                    unselectedColor: "transparent"
                    icon: "speaker"
                    primaryText: modelData.description || modelData.name || "Unknown Device"
                    onTapped: AudioService.setDefaultSink(modelData)
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

            delegate: SelectableCardRow {
                    required property var modelData

                    implicitHeight: Appearance.sizes.listItem
                    readonly property bool _isDefault: modelData.name === AudioService.defaultInput?.name
                    selected: _isDefault
                    unselectedColor: "transparent"
                    icon: "mic"
                    primaryText: modelData.description || modelData.name || "Unknown Device"
                    onTapped: AudioService.setDefaultSource(modelData)
                }
            }

        // Bottom spacer
        Item { implicitHeight: Appearance.padding.md }
    }
}
