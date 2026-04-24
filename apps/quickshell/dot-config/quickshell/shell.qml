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

    property bool activeWindowFullscreen: false

    property var _fullscreenQueryProc: Process {
        command: ["hyprctl", "activewindow", "-j"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                shell._applyActiveWindowFullscreen(this.text.trim())
            }
        }
    }

    function _coerceFullscreenFlag(value) {
        if (typeof value === "boolean") {
            return value;
        }
        if (typeof value === "number") {
            return value !== 0;
        }
        if (typeof value === "string") {
            const asNumber = Number(value);
            if (!isNaN(asNumber)) {
                return asNumber !== 0;
            }
            return value === "true";
        }
        return false;
    }

    function _applyActiveWindowFullscreen(rawOutput) {
        if (rawOutput === "") {
            activeWindowFullscreen = false;
            return;
        }

        try {
            const payload = JSON.parse(rawOutput);
            if (!payload || typeof payload !== "object") {
                activeWindowFullscreen = false;
                return;
            }

            const fullscreenRaw = payload.fullscreenClient !== undefined
                ? payload.fullscreenClient
                : payload.fullscreen !== undefined
                ? payload.fullscreen
                : payload.fullscreenMode;

            activeWindowFullscreen = _coerceFullscreenFlag(fullscreenRaw);
        } catch (_err) {
            console.warn("shell: failed to parse active window state", _err);
            activeWindowFullscreen = false;
        }
    }

    function _resyncActiveWindowFullscreen() {
        if (_fullscreenQueryProc.running) {
            _fullscreenQueryProc.running = false;
        }
        _fullscreenQueryProc.running = true;
    }

    property var _hyprlandEvents: Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name === "fullscreen"
                    || event.name === "activewindow"
                    || event.name === "activewindowv2"
                    || event.name === "workspace"
                    || event.name === "workspacev2"
                    || event.name === "focusedmon"
                    || event.name === "focusedmonv2") {
                shell._resyncActiveWindowFullscreen();
            }
        }
    }

    readonly property real leftFrameWidth:
        Math.max(Appearance.sizes.bar, Appearance.inset.gapOuter)

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
        sourceComponent: Background {
            leftInset: shell.leftFrameWidth
        }
    }

    Loader {
        active: (Config.pending.background?.enabled ?? true) && !shell.activeWindowFullscreen
        sourceComponent: FrameOverlay {
            leftWidth: shell.leftFrameWidth
        }
    }

    // --- Reserved gutter ---
    PanelWindow {
        id: barReservePanel

        anchors {
            top: true
            left: true
            bottom: true
        }

        implicitWidth: shell.leftFrameWidth

        margins {
            top: 0
            bottom: 0
        }

        exclusionMode: ExclusionMode.Normal
        exclusiveZone: Math.round(shell.leftFrameWidth)
        WlrLayershell.layer: WlrLayer.Bottom
        focusable: false
        visible: true

        color: "transparent"
    }

    // --- Bar ---
    PanelWindow {
        id: barPanel

        anchors {
            top: true
            left: true
            bottom: true
        }

        implicitWidth: shell.leftFrameWidth

        margins {
            top: 0
            bottom: 0
        }

        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        focusable: false
        visible: shell.barVisible && !shell.activeWindowFullscreen

        color: "transparent"

        BarWrapper {
            id: barWrapper
            anchors.fill: parent
            dashboardVisible: shell.dashboardVisible
            fullscreen: shell.activeWindowFullscreen || !shell.barVisible
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
    Component.onCompleted: _resyncActiveWindowFullscreen()

    NotificationPopup {}

    // --- Submap hint ---
    // SubmapHint is itself a PanelWindow (persistent, anchored bottom).
    // It manages its own visibility and slide animation internally.
    SubmapHint {
        id: submapHint
        visible: Hypr.activeSubmap !== ""
    }
}
