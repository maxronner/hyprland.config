// modules/bar/widgets/Battery.qml
// Battery level icon with charging indicator. Popup for power profile selection.
// Hidden when no battery device is present. Data from UPower.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import config
import services
import "../../../components"

WidgetContainer {
    id: root

    visible: UPower.displayDevice.isPresent
    interactive: true

    readonly property real percentage: UPower.displayDevice.percentage * 100
    readonly property bool charging: UPower.displayDevice.state === UPowerDeviceState.Charging ||
                                     UPower.displayDevice.state === UPowerDeviceState.FullyCharged
    property string activeProfile: "balanced"

    tooltip: {
        let pct = Math.round(percentage);
        if (UPower.displayDevice.state === UPowerDeviceState.FullyCharged) return "Battery: " + pct + "% (full)";
        if (charging) return "Battery: " + pct + "% (charging)";
        let tip = "Battery: " + pct + "%";
        let secs = UPower.displayDevice.timeToEmpty;
        if (secs > 0) {
            let h = Math.floor(secs / 3600);
            let m = Math.floor((secs % 3600) / 60);
            tip += " (" + h + "h " + m + "m remaining)";
        }
        return tip;
    }

    onClicked: popup.visible = !popup.visible

    readonly property string _icon: {
        if (charging) return "battery_charging_full";
        let p = percentage;
        if (p > 90) return "battery_full";
        if (p > 70) return "battery_6_bar";
        if (p > 50) return "battery_4_bar";
        if (p > 20) return "battery_2_bar";
        return "battery_alert";
    }

    readonly property color _color: {
        if (charging) return Colours.palette.m3success;
        if (percentage < 15) return Colours.palette.m3error;
        if (percentage < 30) return Colours.palette.m3tertiary;
        return Colours.palette.m3onSurface;
    }

    MaterialIcon {
        anchors.centerIn: parent
        icon: root._icon
        size: Appearance.font.xl
        color: root._color
    }

    // Read current power profile
    PollingProcess {
        id: getProfile
        command: ["powerprofilesctl", "get"]
        interval: 15000
        onResult: text => { root.activeProfile = text.trim(); }
    }

    // Set profile process
    Process {
        id: setProfile
        property string target: "balanced"
        command: ["powerprofilesctl", "set", target]
        running: false
        onExited: getProfile.run()
    }

    function setProfileTo(name) {
        setProfile.target = name;
        setProfile.running = true;
        popup.visible = false;
    }

    // Power profile popup
    PopupWindow {
        id: popup
        anchor.item: root
        anchor.edges: Edges.Right
        anchor.gravity: Edges.Right
        anchor.rect.x: root.width + 8
        anchor.rect.y: (root.height - popupContent.height) / 2
        anchor.rect.width: 1
        anchor.rect.height: 1
        anchor.adjustment: PopupAdjustment.Slide
        visible: false
        color: "transparent"
        implicitWidth: popupContent.width
        implicitHeight: popupContent.height

        Rectangle {
            id: popupContent
            width: popupLayout.implicitWidth + Appearance.padding.lg * 2
            height: popupLayout.implicitHeight + Appearance.padding.md * 2
            color: Colours.tPalette.m3surfaceContainerHigh
            radius: Appearance.rounding.md
            border.color: Colours.tPalette.m3outlineVariant
            border.width: 1

            HoverHandler {
                id: popupHover
                onHoveredChanged: {
                    if (!hovered) dismissTimer.start();
                    else dismissTimer.stop();
                }
            }

            Timer {
                id: dismissTimer
                interval: 200
                onTriggered: popup.visible = false
            }

            ColumnLayout {
                id: popupLayout
                anchors.centerIn: parent
                spacing: Appearance.spacing.sm

                // Battery status line
                StyledText {
                    text: root.tooltip
                    color: Colours.tPalette.m3onSurface
                    font.pixelSize: Appearance.font.md
                }

                // Power profile label
                StyledText {
                    text: "Power profile: " + root.activeProfile
                    color: Colours.tPalette.m3onSurfaceVariant
                    font.pixelSize: Appearance.font.sm
                }

                // Profile selector
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: profileRow.implicitWidth + Appearance.padding.sm * 2
                    height: profileRow.implicitHeight + Appearance.padding.sm * 2
                    radius: height / 2
                    color: Colours.tPalette.m3surfaceContainerHighest

                    RowLayout {
                        id: profileRow
                        anchors.centerIn: parent
                        spacing: Appearance.spacing.xs

                        Repeater {
                            model: [
                                { name: "power-saver",  icon: "battery_saver" },
                                { name: "balanced",     icon: "balance" },
                                { name: "performance",  icon: "speed" }
                            ]

                            Rectangle {
                                required property var modelData
                                width: 32
                                height: 32
                                radius: Appearance.rounding.xs
                                color: root.activeProfile === modelData.name
                                    ? Colours.tPalette.m3primaryContainer
                                    : "transparent"

                                Behavior on color { CAnim {} }

                                MaterialIcon {
                                    anchors.centerIn: parent
                                    icon: parent.modelData.icon
                                    size: Appearance.font.lg
                                    color: root.activeProfile === parent.modelData.name
                                        ? Colours.tPalette.m3onPrimaryContainer
                                        : Colours.tPalette.m3onSurfaceVariant
                                }

                                StateLayer {
                                    color: Colours.palette.m3onSurface
                                    radius: parent.radius
                                    clipRipple: true

                                    onTapped: root.setProfileTo(parent.modelData.name)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
