// panes/Session.qml
// Session pane: power actions grid + inline confirmation dialog.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import config
import services
import "../../../components"
import "../../../components/controls"

Item {
    id: root

    // ---- Confirmation dialog state ----
    property string _pendingAction: ""  // "shutdown" | "reboot"
    property bool _confirmVisible: false

    function _requestConfirm(action) {
        root._pendingAction = action
        root._confirmVisible = true
    }

    function _cancelConfirm() {
        root._confirmVisible = false
        root._pendingAction = ""
    }

    function _executeAction(action) {
        root._confirmVisible = false
        root._pendingAction = ""
        switch (action) {
            case "shutdown":  shutdownProc.running = true;  break
            case "reboot":    rebootProc.running = true;    break
            case "lock":      lockProc.running = true;      break
            case "logout":    logoutProc.running = true;    break
            case "suspend":   suspendProc.running = true;   break
        }
    }

    // ---- Processes ----
    Process { id: shutdownProc; command: ["systemctl", "poweroff"]; running: false }
    Process { id: rebootProc;   command: ["systemctl", "reboot"];   running: false }
    Process { id: lockProc;     command: ["loginctl", "lock-session"];               running: false }
    Process { id: logoutProc;   command: ["hyprctl", "dispatch", "exit"];             running: false }
    Process { id: suspendProc;  command: ["systemctl", "suspend"];  running: false }

    // ---- Main content ----
    Item {
        anchors.fill: parent
        anchors.margins: Appearance.padding.lg

        ColumnLayout {
            anchors.fill: parent
            spacing: Appearance.spacing.md

            StyledText {
                text: "Session"
                font.pixelSize: Appearance.font.xl
                color: Colours.tPalette.m3onSurface
            }

            // ---- Power action grid ----
            GridLayout {
                id: actionGrid
                Layout.fillWidth: true
                columns: 2
                rowSpacing: Appearance.spacing.md
                columnSpacing: Appearance.spacing.md

                // Lock
                SessionButton {
                    Layout.fillWidth: true
                    label: "Lock"
                    icon: "lock"
                    accentType: "normal"
                    onActivated: root._executeAction("lock")
                }

                // Logout
                SessionButton {
                    Layout.fillWidth: true
                    label: "Log Out"
                    icon: "logout"
                    accentType: "normal"
                    onActivated: root._executeAction("logout")
                }

                // Suspend
                SessionButton {
                    Layout.fillWidth: true
                    label: "Suspend"
                    icon: "bedtime"
                    accentType: "normal"
                    onActivated: root._executeAction("suspend")
                }

                // Reboot
                SessionButton {
                    Layout.fillWidth: true
                    label: "Reboot"
                    icon: "restart_alt"
                    accentType: "error"
                    onActivated: root._requestConfirm("reboot")
                }

                // Shutdown (spans full width)
                SessionButton {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    label: "Shut Down"
                    icon: "power_settings_new"
                    accentType: "error"
                    onActivated: root._requestConfirm("shutdown")
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    // ---- Inline confirmation dialog ----
    Scrim {
        active: root._confirmVisible
        onDismissed: root._cancelConfirm()
    }

    // Centered confirmation card
    Item {
        anchors.fill: parent
        visible: root._confirmVisible
        opacity: root._confirmVisible ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: Appearance.anim.duration.sm }
        }

        Rectangle {
            id: dialogCard
            anchors.centerIn: parent
            width: Math.min(parent.width - Appearance.padding.xl * 2, 280)
            implicitHeight: dialogLayout.implicitHeight + Appearance.padding.xl * 2
            radius: Appearance.rounding.lg
            color: Colours.tPalette.m3surfaceContainerHigh

            // Dialog pops in — orients user and emphasizes the weight of the decision.
            scale: root._confirmVisible ? 1.0 : 0.94
            Behavior on scale {
                NumberAnimation {
                    duration: Appearance.anim.duration.md
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.anim.emphasizedDecel
                }
            }

            ColumnLayout {
                id: dialogLayout
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Appearance.padding.xl
                }
                spacing: Appearance.spacing.md

                MaterialIcon {
                    Layout.alignment: Qt.AlignHCenter
                    icon: "warning"
                    size: Appearance.font.xxl
                    color: Colours.palette.m3error
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: root._pendingAction === "shutdown" ? "Shut down?" : "Reboot?"
                    font.pixelSize: Appearance.font.lg
                    color: Colours.tPalette.m3onSurface
                    font.weight: Font.Medium
                }

                StyledText {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    text: root._pendingAction === "shutdown"
                        ? "Your system will power off."
                        : "Your system will restart."
                    font.pixelSize: Appearance.font.sm
                    color: Colours.tPalette.m3onSurfaceVariant
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.sm

                    // Cancel (tonal) — default focus; Return/Escape dismisses.
                    Rectangle {
                        id: cancelBtn
                        Layout.fillWidth: true
                        implicitHeight: Appearance.sizes.button
                        radius: Appearance.rounding.full
                        color: Colours.tPalette.m3secondaryContainer

                        focus: root._confirmVisible
                        // Fixed width + color fade avoids layout shift when focus enters/leaves.
                        border.width: 2
                        border.color: activeFocus ? Colours.palette.m3onSecondaryContainer : "transparent"
                        Behavior on border.color { ColorAnimation { duration: Appearance.anim.duration.xs } }

                        scale: cancelLayer.pressed ? 0.97 : 1.0
                        Behavior on scale { NumberAnimation { duration: Appearance.anim.duration.xs; easing.type: Easing.OutQuad } }

                        StyledText {
                            anchors.centerIn: parent
                            text: "Cancel"
                            color: Colours.palette.m3onSecondaryContainer
                        }

                        StateLayer {
                            id: cancelLayer
                            radius: parent.radius
                            color: Colours.palette.m3onSecondaryContainer
                            clipRipple: true
                            onTapped: root._cancelConfirm()
                        }

                        Keys.onReturnPressed: root._cancelConfirm()
                        Keys.onEscapePressed: root._cancelConfirm()
                    }

                    // Confirm (filled error) — no keyboard activation; intentional friction.
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: Appearance.sizes.button
                        radius: Appearance.rounding.full
                        color: Colours.palette.m3error

                        scale: confirmLayer.pressed ? 0.97 : 1.0
                        Behavior on scale { NumberAnimation { duration: Appearance.anim.duration.xs; easing.type: Easing.OutQuad } }

                        StyledText {
                            anchors.centerIn: parent
                            text: "Confirm"
                            color: Colours.palette.m3onError
                        }

                        StateLayer {
                            id: confirmLayer
                            radius: parent.radius
                            color: Colours.palette.m3onError
                            clipRipple: true
                            onTapped: root._executeAction(root._pendingAction)
                        }
                    }
                }
            }
        }
    }

    Keys.onEscapePressed: {
        if (root._confirmVisible)
            root._cancelConfirm()
    }

    // ---- Inline SessionButton component ----
    component SessionButton: Rectangle {
        id: btn

        property string label: ""
        property string icon: ""
        // "normal" | "error"
        property string accentType: "normal"

        signal activated()

        implicitWidth: 0
        implicitHeight: btnLayout.implicitHeight + Appearance.padding.lg * 2
        radius: Appearance.rounding.md

        color: accentType === "error"
            ? Qt.alpha(Colours.palette.m3errorContainer, 0.6)
            : Colours.tPalette.m3surfaceContainerHigh

        Behavior on color { CAnim {} }

        scale: btnLayer.pressed ? 0.97 : 1.0
        Behavior on scale { NumberAnimation { duration: Appearance.anim.duration.xs; easing.type: Easing.OutQuad } }

        ColumnLayout {
            id: btnLayout
            anchors.centerIn: parent
            spacing: Appearance.spacing.xs

            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                icon: btn.icon
                size: Appearance.font.xxl
                color: btn.accentType === "error"
                    ? Colours.palette.m3error
                    : Colours.tPalette.m3onSurface
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: btn.label
                font.pixelSize: Appearance.font.sm
                color: btn.accentType === "error"
                    ? Colours.palette.m3error
                    : Colours.tPalette.m3onSurface
            }
        }

        StateLayer {
            id: btnLayer
            radius: parent.radius
            color: btn.accentType === "error"
                ? Colours.palette.m3error
                : Colours.palette.m3onSurface
            clipRipple: true
            onTapped: btn.activated()
        }
    }
}
