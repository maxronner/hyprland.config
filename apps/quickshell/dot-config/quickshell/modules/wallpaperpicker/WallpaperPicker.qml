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

    // Focus is delegated to the filmstrip
    focus: false

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
        if (_session) {
            if (!_session.committed) {
                _session.revert();
                _session.destroy();
            }
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
