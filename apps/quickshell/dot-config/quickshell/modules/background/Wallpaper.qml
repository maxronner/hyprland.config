// modules/background/Wallpaper.qml
// Dual-image crossfade wallpaper renderer.
// Two CachingImage instances alternate. On wallpaper change, the inactive
// one loads the new path. On Image.Ready, it crossfades in (opacity).
// On load failure, the current wallpaper stays visible.
pragma ComponentBehavior: Bound

import QtQuick
import config
import services
import "../../components"

Item {
    id: root

    property string source: WallpaperService.current
    property var _current: null
    property bool _initialized: false

    onSourceChanged: {
        if (!source) {
            _current = null;
            return;
        }
        if (!_initialized) return;
        if (_current === one) two._load(source);
        else one._load(source);
    }

    Component.onCompleted: {
        if (source) {
            Qt.callLater(() => {
                one._load(source);
                _initialized = true;
            });
        } else {
            _initialized = true;
        }
    }

    // Fallback: shown only when no wallpaper has ever loaded
    Rectangle {
        anchors.fill: parent
        color: Colours.palette.m3surface
        visible: root._current === null && root._initialized

        StyledText {
            anchors.centerIn: parent
            text: "No wallpaper set"
            color: Colours.palette.m3onSurfaceVariant
            font.pixelSize: Appearance.font.lg
        }
    }

    Img { id: one }
    Img { id: two }

    component Img: CachingImage {
        id: img

        function _load(newPath) {
            if (path === newPath) {
                root._current = this;
            } else {
                path = newPath;
            }
        }

        anchors.fill: parent
        opacity: 0

        onStatusChanged: {
            if (status === Image.Ready) {
                root._current = this;
            } else if (status === Image.Error) {
                console.warn("Wallpaper: failed to load", path);
            }
        }

        states: [
            State {
                name: "visible"
                when: root._current === img
                PropertyChanges { img.opacity: 1 }
            },
            State {
                name: "hidden"
                when: root._current !== img
                PropertyChanges { img.opacity: 0 }
            }
        ]

        transitions: [
            // Fade in
            Transition {
                to: "visible"
                NumberAnimation {
                    property: "opacity"
                    duration: Appearance.anim.duration.expressiveDefault
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.anim.expressiveDefaultSpatial
                }
            },
            // Fade out
            Transition {
                to: "hidden"
                SequentialAnimation {
                    // Delay fade-out slightly so new image is partially visible first
                    PauseAnimation { duration: 100 }
                    NumberAnimation {
                        property: "opacity"
                        duration: Appearance.anim.duration.expressiveDefault
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.anim.expressiveDefaultSpatial
                    }
                }
            }
        ]

        // Release texture after fade-out completes
        onOpacityChanged: {
            if (opacity === 0 && root._current !== this && path !== "") {
                path = "";
            }
        }
    }
}
