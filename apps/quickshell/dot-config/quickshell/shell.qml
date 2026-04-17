import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import services
import config
import "modules/bar"
import "modules/dashboard"
import "modules/controlcenter"
import "modules/submap"
import "modules/notifications"
import "modules/background"
import "modules/wallpaperpicker"

ShellRoot {
    id: shell

    // Touch HyprSync singleton so it initializes and writes the gaps config.
    readonly property var _hyprSync: HyprSync

    // --- Overlay visibility state ---
    property bool dashboardVisible: false
    property bool controlCenterVisible: false
    property bool barVisible: true
    property bool wallpaperPickerVisible: false

    // Mutual exclusivity: opening one overlay closes the others
    onDashboardVisibleChanged: { if (dashboardVisible) { controlCenterVisible = false; wallpaperPickerVisible = false } }
    onControlCenterVisibleChanged: { if (controlCenterVisible) { dashboardVisible = false; wallpaperPickerVisible = false } }
    onWallpaperPickerVisibleChanged: { if (wallpaperPickerVisible) { dashboardVisible = false; controlCenterVisible = false } }

    // --- IPC handlers ---
    IpcHandler {
        target: "toggle-dashboard"
        function toggle() { shell.dashboardVisible = !shell.dashboardVisible }
    }

    IpcHandler {
        target: "toggle-controlcenter"
        function toggle() { shell.controlCenterVisible = !shell.controlCenterVisible }
    }

    IpcHandler {
        target: "toggle-bar"
        function toggle() { shell.barVisible = !shell.barVisible }
    }

    IpcHandler {
        target: "open-controlcenter-pane"
        function open(index: int): void {
            ccWrapper._activeIndex = index;
            shell.controlCenterVisible = true;
        }
    }

    IpcHandler {
        target: "toggle-wallpaper-picker"
        function toggle() { shell.wallpaperPickerVisible = !shell.wallpaperPickerVisible }
    }

    IpcHandler {
        target: "close-overlays"
        function toggle() {
            shell.dashboardVisible = false
            shell.controlCenterVisible = false
            shell.wallpaperPickerVisible = false
        }
    }

    IpcHandler {
        target: "reload-theme"
        function reload() { Colours._reloadPalette() }
    }

    // --- Background wallpaper ---
    Loader {
        active: Config.pending.background?.enabled ?? true
        sourceComponent: Background {}
    }

    // --- Bar ---
    PanelWindow {
        id: barPanel

        anchors {
            top: true
            left: true
            bottom: true
        }

        implicitWidth: Appearance.sizes.bar

        margins {
            top: Appearance.spacing.xs
            bottom: Appearance.spacing.xs
        }

        exclusionMode: ExclusionMode.Normal
        exclusiveZone: Appearance.sizes.bar
        WlrLayershell.layer: WlrLayer.Bottom
        focusable: false
        visible: shell.barVisible

        color: "transparent"

        BarWrapper {
            anchors.fill: parent
            dashboardVisible: shell.dashboardVisible
            onDashboardToggleRequested: shell.dashboardVisible = !shell.dashboardVisible
        }
    }

    // --- Dashboard overlay ---
    PanelWindow {
        id: dashboardPanel

        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        focusable: true
        visible: shell.dashboardVisible || dashWrapper.offsetScale < 1.0

        color: "transparent"

        DashWrapper {
            id: dashWrapper
            anchors.fill: parent

            // 0 = visible, 1 = hidden
            offsetScale: shell.dashboardVisible ? 0.0 : 1.0

            onDismissed: shell.dashboardVisible = false
        }
    }

    // --- Control Center overlay ---
    PanelWindow {
        id: controlCenterPanel

        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        focusable: true
        visible: shell.controlCenterVisible || ccWrapper.offsetScale < 1.0

        color: "transparent"

        ControlCenter {
            id: ccWrapper
            anchors.fill: parent

            // 0 = visible, 1 = hidden
            offsetScale: shell.controlCenterVisible ? 0.0 : 1.0

            onDismissed: shell.controlCenterVisible = false
        }
    }

    // --- Wallpaper Picker overlay ---
    PanelWindow {
        id: wallpaperPickerPanel

        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        focusable: true
        visible: shell.wallpaperPickerVisible || pickerWrapper.offsetScale < 1.0

        color: "transparent"

        WallpaperPicker {
            id: pickerWrapper
            anchors.fill: parent

            // 0 = visible, 1 = hidden
            offsetScale: shell.wallpaperPickerVisible ? 0.0 : 1.0

            onDismissed: shell.wallpaperPickerVisible = false
        }
    }

    // --- Notification toasts ---
    NotificationPopup {}

    // --- Submap hint ---
    // SubmapHint is itself a PanelWindow (persistent, anchored bottom).
    // It manages its own visibility and slide animation internally.
    SubmapHint {
        id: submapHint
        visible: Hypr.activeSubmap !== ""
    }
}
