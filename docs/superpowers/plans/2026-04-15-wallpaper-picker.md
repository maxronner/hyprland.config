# Wallpaper Picker Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the external tofi-based wallpaper selector with a native QuickShell panel — a keyboard-driven horizontal filmstrip at the bottom of the screen with live wallpaper preview.

**Architecture:** New `modules/wallpaperpicker/` module following the existing overlay pattern (offsetScale animation, Scrim dismiss, PanelWindow at WlrLayer.Overlay). Internal PickerSession QtObject separates session state (original wallpaper, commit process, revert logic) from the wrapper's animation/layout concerns. Filmstrip scans `~/.local/share/wallpapers/` via Process, renders thumbnails in a horizontal ListView with keyboard navigation, and previews wallpapers via WallpaperService while committing through the existing `wl-set-wallpaper` script.

**Tech Stack:** QML (QuickShell), Quickshell.Io (Process, StdioCollector, IpcHandler), Quickshell.Wayland (WlrLayershell)

**Spec:** `docs/superpowers/specs/2026-04-15-wallpaper-picker-design.md`

---

### Task 1: Create WallpaperPicker wrapper with slide animation and scrim

**Files:**
- Create: `apps/quickshell/dot-config/quickshell/modules/wallpaperpicker/qmldir`
- Create: `apps/quickshell/dot-config/quickshell/modules/wallpaperpicker/WallpaperPicker.qml`

This task creates the outer wrapper — slide-up animation from the bottom, scrim for dismiss, keyboard handling. No filmstrip content yet — just a placeholder rectangle to verify the animation works.

- [ ] **Step 1: Create the qmldir module file**

```
// apps/quickshell/dot-config/quickshell/modules/wallpaperpicker/qmldir
WallpaperPicker 1.0 WallpaperPicker.qml
WallpaperFilmstrip 1.0 WallpaperFilmstrip.qml
```

- [ ] **Step 2: Create WallpaperPicker.qml with slide animation, scrim, and placeholder content**

```qml
// modules/wallpaperpicker/WallpaperPicker.qml
// Animated bottom-up drawer for the wallpaper filmstrip.
//
// offsetScale: 0 = fully visible, 1 = fully hidden (below viewport).
// Content slides up from the bottom using an expressive spatial curve.
// A Scrim child dims the background whenever the drawer is not fully hidden.
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import config
import services
import "../../components"

Item {
    id: root

    // 0 = visible, 1 = hidden. Driven by shell.qml.
    property real offsetScale: 1.0

    signal dismissed()

    anchors.fill: parent

    // ---- Scrim ----
    Scrim {
        id: scrim
        active: root.offsetScale < 1.0
        onDismissed: root._dismiss()
    }

    // ---- Sliding content container ----
    Item {
        id: slideContainer

        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        height: filmstrip.implicitHeight + Appearance.padding.xl * 2

        // Translate down by (height * offsetScale) to slide off screen
        transform: Translate {
            y: slideContainer.height * root.offsetScale
        }

        opacity: 1.0 - root.offsetScale * 0.3

        // Absorb clicks so they don't fall through to the Scrim
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
        }

        // ---- Filmstrip content ----
        // Placeholder until Task 3 — will become WallpaperFilmstrip
        Rectangle {
            id: filmstrip
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: Appearance.padding.xl
            }
            implicitHeight: 200
            color: Colours.tPalette.m3surfaceContainer
            radius: Appearance.rounding.md

            StyledText {
                anchors.centerIn: parent
                text: "Wallpaper picker placeholder"
                color: Colours.tPalette.m3onSurfaceVariant
            }
        }
    }

    // ---- Animation on offsetScale ----
    Behavior on offsetScale {
        NumberAnimation {
            duration: Appearance.anim.duration.expressiveDefault
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.expressiveDefaultSpatial
        }
    }

    // ---- Keyboard handling ----
    Keys.onEscapePressed: root._dismiss()

    // Accept focus so key events reach us
    focus: root.offsetScale < 1.0

    // ---- Session state ----
    property var _session: null

    function _onOpened(): void {
        if (!_session) {
            _session = _sessionComponent.createObject(root, {
                originalWallpaper: WallpaperService.current
            });
        }
    }

    function _dismiss(): void {
        if (_session && !_session.committed) {
            _session.revert();
            _session.destroy();
            _session = null;
        }
        root.dismissed();
    }

    // Create session when panel becomes visible
    onOffsetScaleChanged: {
        if (offsetScale === 0.0) _onOpened();
    }

    // ---- PickerSession component ----
    Component {
        id: _sessionComponent

        QtObject {
            id: session

            property string originalWallpaper: ""
            property bool committed: false
            property string _commitPath: ""

            property var _commitProc: Process {
                command: ["wl-set-wallpaper", session._commitPath]
                running: false
                onExited: (exitCode, exitStatus) => {
                    if (exitCode !== 0) {
                        console.warn("WallpaperPicker: wl-set-wallpaper failed, reverting");
                        WallpaperService._writeAtomic(session.originalWallpaper);
                    }
                    session.destroy();
                }
            }

            function commit(path: string): void {
                committed = true;
                _commitPath = path;
                _commitProc.running = true;
            }

            function revert(): void {
                if (!committed && originalWallpaper) {
                    WallpaperService._writeAtomic(originalWallpaper);
                }
            }
        }
    }
}
```

- [ ] **Step 3: Commit**

```bash
git add apps/quickshell/dot-config/quickshell/modules/wallpaperpicker/
git commit -m "feat(wallpaperpicker): add WallpaperPicker wrapper with slide animation and PickerSession"
```

---

### Task 2: Wire WallpaperPicker into shell.qml

**Files:**
- Modify: `apps/quickshell/dot-config/quickshell/shell.qml`

Add the visibility state, IPC handler, PanelWindow, and mutual exclusivity logic.

- [ ] **Step 1: Add import and visibility state**

At the top of `shell.qml`, add the module import:

```qml
import "modules/wallpaperpicker"
```

Add after the existing visibility properties (after line 23):

```qml
property bool wallpaperPickerVisible: false
```

Update the mutual exclusivity handlers. Replace lines 24-25:

```qml
onDashboardVisibleChanged: { if (dashboardVisible) { controlCenterVisible = false; wallpaperPickerVisible = false } }
onControlCenterVisibleChanged: { if (controlCenterVisible) { dashboardVisible = false; wallpaperPickerVisible = false } }
onWallpaperPickerVisibleChanged: { if (wallpaperPickerVisible) { dashboardVisible = false; controlCenterVisible = false } }
```

- [ ] **Step 2: Add IPC handler**

After the existing IPC handlers (after the `close-overlays` handler, around line 57), add:

```qml
IpcHandler {
    target: "toggle-wallpaper-picker"
    function toggle() { shell.wallpaperPickerVisible = !shell.wallpaperPickerVisible }
}
```

Update the `close-overlays` handler to also close the wallpaper picker. Replace the existing `close-overlays` function body:

```qml
function toggle() {
    shell.dashboardVisible = false
    shell.controlCenterVisible = false
    shell.wallpaperPickerVisible = false
}
```

- [ ] **Step 3: Add PanelWindow for the picker**

After the Control Center PanelWindow block (after line 158), add:

```qml
// --- Wallpaper Picker overlay ---
PanelWindow {
    id: wallpaperPickerPanel

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    exclusionMode: ExclusionMode.Normal
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
```

- [ ] **Step 4: Verify the panel toggles**

Run QuickShell, then test:

```bash
quickshell msg toggle-wallpaper-picker toggle
```

Expected: Panel slides up from bottom showing placeholder rectangle. Pressing Escape or clicking the scrim dismisses it. Opening dashboard or control center while picker is open closes the picker.

- [ ] **Step 5: Commit**

```bash
git add apps/quickshell/dot-config/quickshell/shell.qml
git commit -m "feat(shell): wire wallpaper picker overlay into shell with IPC and mutual exclusivity"
```

---

### Task 3: Create WallpaperFilmstrip with file scanning and thumbnail rendering

**Files:**
- Create: `apps/quickshell/dot-config/quickshell/modules/wallpaperpicker/WallpaperFilmstrip.qml`
- Modify: `apps/quickshell/dot-config/quickshell/modules/wallpaperpicker/WallpaperPicker.qml`

Build the filmstrip: scan the wallpaper directory, render thumbnails in a horizontal ListView, highlight the current wallpaper.

- [ ] **Step 1: Create WallpaperFilmstrip.qml**

```qml
// modules/wallpaperpicker/WallpaperFilmstrip.qml
// Horizontal thumbnail filmstrip for wallpaper selection.
// Scans the wallpaper directory, renders async thumbnails, and supports
// keyboard navigation with wrap-around.
pragma ComponentBehavior: Bound
import QtQuick
import QtCore
import Quickshell
import Quickshell.Io
import config
import services
import "../../components"

Item {
    id: root

    // Emitted when the user commits a wallpaper (Enter or click)
    signal wallpaperCommitted(path: string)

    // Emitted when the user navigates to a new wallpaper (for preview)
    signal wallpaperPreviewed(path: string)

    readonly property string _wallpaperDir: {
        let p = StandardPaths.writableLocation(StandardPaths.GenericDataLocation).toString();
        if (p.startsWith("file://")) p = p.substring(7);
        return p + "/wallpapers";
    }

    property bool _ready: false

    implicitHeight: 200

    // ---- File scanning ----
    ListModel { id: wallpaperModel }

    Process {
        id: scanProc
        command: [
            "find", "-L", root._wallpaperDir,
            "-maxdepth", "1", "-type", "f",
            "(", "-iname", "*.jpg",
            "-o", "-iname", "*.jpeg",
            "-o", "-iname", "*.png",
            "-o", "-iname", "*.gif",
            "-o", "-iname", "*.bmp", ")"
        ]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n").filter(l => l.length > 0);
                lines.sort();
                for (const line of lines) {
                    wallpaperModel.append({ path: line });
                }

                // Find index matching current wallpaper
                let matchIndex = 0;
                const current = WallpaperService.current;
                for (let i = 0; i < wallpaperModel.count; i++) {
                    if (wallpaperModel.get(i).path === current) {
                        matchIndex = i;
                        break;
                    }
                }
                filmstripView.currentIndex = matchIndex;

                // Enable preview handler after initial index is set
                Qt.callLater(() => { root._ready = true; });
            }
        }
    }

    // ---- Empty state ----
    StyledText {
        anchors.centerIn: parent
        visible: wallpaperModel.count === 0 && !scanProc.running
        text: "No wallpapers found"
        color: Colours.tPalette.m3onSurfaceVariant
        font.pixelSize: Appearance.font.lg
    }

    // ---- Filmstrip ListView ----
    ListView {
        id: filmstripView

        anchors.fill: parent
        orientation: ListView.Horizontal
        spacing: Appearance.spacing.sm
        clip: true
        visible: wallpaperModel.count > 0

        model: wallpaperModel

        // Pad the edges so the first/last item can be centered
        leftMargin: Appearance.padding.xl
        rightMargin: Appearance.padding.xl

        highlightMoveDuration: Appearance.anim.duration.sm

        onCurrentIndexChanged: {
            if (!root._ready) return;
            positionViewAtIndex(currentIndex, ListView.Center);
            const item = wallpaperModel.get(currentIndex);
            if (item) root.wallpaperPreviewed(item.path);
        }

        delegate: Item {
            id: del

            required property int index
            required property string path

            width: thumbnailImg.implicitWidth > 0
                ? thumbnailImg.implicitWidth
                : Math.round(filmstripView.height * 16 / 9)
            height: filmstripView.height

            // ---- Highlight border ----
            Rectangle {
                anchors.fill: parent
                anchors.margins: -3
                radius: Appearance.rounding.sm + 3
                color: "transparent"
                border.width: filmstripView.currentIndex === del.index ? 3 : 0
                border.color: Colours.tPalette.m3primary
                visible: filmstripView.currentIndex === del.index

                Behavior on border.width {
                    NumberAnimation { duration: Appearance.anim.duration.xs }
                }
            }

            // ---- Thumbnail ----
            Rectangle {
                anchors.fill: parent
                radius: Appearance.rounding.sm
                color: Colours.tPalette.m3surfaceContainerHigh
                clip: true

                Image {
                    id: thumbnailImg
                    anchors.fill: parent
                    source: "file://" + del.path
                    sourceSize.height: 180
                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop
                    cache: true
                }
            }

            // ---- Click to commit ----
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    filmstripView.currentIndex = del.index;
                    root.wallpaperCommitted(del.path);
                }
            }
        }
    }

    // ---- Keyboard navigation ----
    Keys.onPressed: event => {
        if (wallpaperModel.count === 0) return;

        if (event.key === Qt.Key_Left || event.key === Qt.Key_H) {
            filmstripView.currentIndex =
                (filmstripView.currentIndex - 1 + wallpaperModel.count) % wallpaperModel.count;
            event.accepted = true;
        } else if (event.key === Qt.Key_Right || event.key === Qt.Key_L) {
            filmstripView.currentIndex =
                (filmstripView.currentIndex + 1) % wallpaperModel.count;
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            const item = wallpaperModel.get(filmstripView.currentIndex);
            if (item) root.wallpaperCommitted(item.path);
            event.accepted = true;
        }
    }
}
```

- [ ] **Step 2: Replace the placeholder in WallpaperPicker.qml with WallpaperFilmstrip**

In `WallpaperPicker.qml`, replace the placeholder `Rectangle` block (the `id: filmstrip` block) with:

```qml
        // ---- Filmstrip content ----
        WallpaperFilmstrip {
            id: filmstrip
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: Appearance.padding.xl
            }
            focus: root.offsetScale < 1.0

            onWallpaperPreviewed: path => {
                WallpaperService._writeAtomic(path);
            }

            onWallpaperCommitted: path => {
                if (root._session) {
                    root._session.commit(path);
                }
                root.dismissed();
            }
        }
```

Also update the `focus` line near the bottom of the file — the filmstrip should receive focus, not the root Item. Remove or change the root-level `focus` binding:

```qml
    // Focus is delegated to the filmstrip
    focus: false
```

- [ ] **Step 3: Verify the filmstrip renders**

Run QuickShell and toggle the wallpaper picker:

```bash
quickshell msg toggle-wallpaper-picker toggle
```

Expected: Panel slides up showing thumbnail images from `~/.local/share/wallpapers/`. Current wallpaper is highlighted with a primary-colored border. If the directory is empty or missing, "No wallpapers found" text is shown.

- [ ] **Step 4: Commit**

```bash
git add apps/quickshell/dot-config/quickshell/modules/wallpaperpicker/
git commit -m "feat(wallpaperpicker): add WallpaperFilmstrip with file scanning, thumbnails, and keyboard nav"
```

---

### Task 4: Wire up preview and commit flow

**Files:**
- Modify: `apps/quickshell/dot-config/quickshell/modules/wallpaperpicker/WallpaperPicker.qml`

This task verifies the full preview → commit → revert lifecycle. The wiring was done in Task 3 step 2, but we need to verify the behavior end-to-end and fix any issues.

- [ ] **Step 1: Test preview on navigate**

Run QuickShell and open the picker:

```bash
quickshell msg toggle-wallpaper-picker toggle
```

Navigate with Left/Right/h/l. Expected: each navigation triggers a wallpaper crossfade behind the panel (the background changes). The color scheme (M3 palette) should NOT change during navigation — only the wallpaper image changes.

- [ ] **Step 2: Test commit with Enter**

Navigate to a wallpaper, press Enter. Expected: panel dismisses immediately, `wl-set-wallpaper` runs in the background (triggers thememanager for palette regen), color scheme updates after a moment.

- [ ] **Step 3: Test revert with Escape**

Open picker, navigate to a different wallpaper (background changes), press Escape. Expected: panel dismisses, wallpaper reverts to the original one from before the picker was opened.

- [ ] **Step 4: Test scrim dismiss (revert)**

Open picker, navigate to a different wallpaper, click the dark scrim area above the filmstrip. Expected: same revert behavior as Escape.

- [ ] **Step 5: Commit any fixes**

If any fixes were needed:

```bash
git add apps/quickshell/dot-config/quickshell/modules/wallpaperpicker/
git commit -m "fix(wallpaperpicker): fix preview/commit/revert lifecycle"
```

---

### Task 5: Update Hyprland keybind

**Files:**
- Modify: `apps/hyprland/dot-config/hypr/hyprland.conf:137`

- [ ] **Step 1: Change the keybind**

Replace line 137:

```
bind = $mod, O, exec, wl-select-wallpaper
```

with:

```
bind = $mod, O, exec, quickshell msg toggle-wallpaper-picker toggle
```

- [ ] **Step 2: Reload Hyprland config**

```bash
hyprctl reload
```

- [ ] **Step 3: Test the keybind**

Press `$mod+O`. Expected: wallpaper picker slides up from the bottom. Press Escape to dismiss. Press `$mod+O` again — should toggle open/close.

- [ ] **Step 4: Commit**

```bash
git add apps/hyprland/dot-config/hypr/hyprland.conf
git commit -m "feat(hyprland): bind mod+O to native wallpaper picker instead of tofi"
```

---

### Task 6: Final verification

No files to change — end-to-end test of the complete feature.

- [ ] **Step 1: Full lifecycle test**

1. Press `$mod+O` — picker opens, current wallpaper highlighted
2. Navigate with arrow keys — wallpaper crossfades behind panel, palette stays stable
3. Navigate with h/l — same behavior
4. Navigate past the last item — wraps to first
5. Navigate before the first item — wraps to last
6. Click a thumbnail — commits, panel closes, thememanager runs
7. Press `$mod+O` again — new wallpaper is highlighted
8. Navigate away, press Escape — reverts to the wallpaper from step 6

- [ ] **Step 2: Mutual exclusivity test**

1. Open dashboard (`quickshell msg toggle-dashboard toggle`)
2. Press `$mod+O` — dashboard closes, picker opens
3. Open control center while picker is open — picker closes

- [ ] **Step 3: Edge case test**

1. Open picker, immediately press Escape before any navigation — should close cleanly, no revert needed (wallpaper didn't change)
2. Open picker, commit with Enter, quickly press `$mod+O` again — new session should start with the committed wallpaper as the original
