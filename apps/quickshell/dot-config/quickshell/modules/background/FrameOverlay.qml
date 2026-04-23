// modules/background/FrameOverlay.qml
// Per-screen top-layer frame strips that render above normal windows.
// Intentionally not fullscreen: only top/right/bottom frame areas are drawn.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import config
import services

Variants {
    id: root

    property real leftWidth: Appearance.sizes.bar

    model: Quickshell.screens

    Item {
        id: frame

        required property ShellScreen modelData

        // Keep geometry sourced from existing Appearance/Config bindings.
        readonly property real leftWidth: root.leftWidth
        readonly property real gapOuter: Appearance.inset.gapOuter
        readonly property real radius: Appearance.inset.radius
        readonly property color surfaceColor: Colours.palette.m3surface

        PanelWindow {
            screen: frame.modelData
            WlrLayershell.layer: WlrLayer.Top
            exclusionMode: ExclusionMode.Ignore
            focusable: false
            color: Colours.palette.m3surface

            anchors {
                top: true
                left: true
                bottom: true
            }

            implicitWidth: frame.leftWidth
        }

        PanelWindow {
            screen: frame.modelData
            WlrLayershell.layer: WlrLayer.Top
            exclusionMode: ExclusionMode.Ignore
            focusable: false
            color: Colours.palette.m3surface

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: frame.gapOuter

            margins {
                left: frame.leftWidth
                right: frame.gapOuter
            }
        }

        // Corner caps preserve the same inner radius as the wallpaper opening.
        PanelWindow {
            screen: frame.modelData
            WlrLayershell.layer: WlrLayer.Top
            exclusionMode: ExclusionMode.Ignore
            focusable: false
            color: "transparent"

            implicitWidth: frame.radius
            implicitHeight: frame.radius

            anchors {
                left: true
                top: true
            }

            margins {
                left: frame.leftWidth
                top: frame.gapOuter
            }

            Item {
                id: topLeftCorner
                width: frame.radius
                height: frame.radius

                Canvas {
                    id: topLeftCanvas
                    anchors.fill: parent
                    antialiasing: true

                    onPaint: {
                        const ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);
                        ctx.fillStyle = frame.surfaceColor;
                        ctx.fillRect(0, 0, width, height);
                        ctx.globalCompositeOperation = "destination-out";
                        ctx.beginPath();
                        ctx.moveTo(width, height);
                        ctx.arc(width, height, width, Math.PI, 1.5 * Math.PI, false);
                        ctx.closePath();
                        ctx.fill();
                        ctx.globalCompositeOperation = "source-over";
                    }

                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()
                }
            }
        }

        PanelWindow {
            screen: frame.modelData
            WlrLayershell.layer: WlrLayer.Top
            exclusionMode: ExclusionMode.Ignore
            focusable: false
            color: "transparent"

            implicitWidth: frame.radius
            implicitHeight: frame.radius

            anchors {
                top: true
                right: true
            }

            margins {
                right: frame.gapOuter
                top: frame.gapOuter
            }

            Item {
                id: topRightCorner
                width: frame.radius
                height: frame.radius

                Canvas {
                    id: topRightCanvas
                    anchors.fill: parent
                    antialiasing: true

                    onPaint: {
                        const ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);
                        ctx.fillStyle = frame.surfaceColor;
                        ctx.fillRect(0, 0, width, height);
                        ctx.globalCompositeOperation = "destination-out";
                        ctx.beginPath();
                        ctx.moveTo(0, height);
                        ctx.arc(0, height, width, 1.5 * Math.PI, 0, false);
                        ctx.closePath();
                        ctx.fill();
                        ctx.globalCompositeOperation = "source-over";
                    }

                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()
                }
            }
        }

        PanelWindow {
            screen: frame.modelData
            WlrLayershell.layer: WlrLayer.Top
            exclusionMode: ExclusionMode.Ignore
            focusable: false
            color: "transparent"

            implicitWidth: frame.radius
            implicitHeight: frame.radius

            anchors {
                left: true
                bottom: true
            }

            margins {
                left: frame.leftWidth
                bottom: frame.gapOuter
            }

            Item {
                id: bottomLeftCorner
                width: frame.radius
                height: frame.radius

                Canvas {
                    id: bottomLeftCanvas
                    anchors.fill: parent
                    antialiasing: true

                    onPaint: {
                        const ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);
                        ctx.fillStyle = frame.surfaceColor;
                        ctx.fillRect(0, 0, width, height);
                        ctx.globalCompositeOperation = "destination-out";
                        ctx.beginPath();
                        ctx.moveTo(width, 0);
                        ctx.arc(width, 0, width, 0.5 * Math.PI, Math.PI, false);
                        ctx.closePath();
                        ctx.fill();
                        ctx.globalCompositeOperation = "source-over";
                    }

                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()
                }
            }
        }

        PanelWindow {
            screen: frame.modelData
            WlrLayershell.layer: WlrLayer.Top
            exclusionMode: ExclusionMode.Ignore
            focusable: false
            color: "transparent"

            implicitWidth: frame.radius
            implicitHeight: frame.radius

            anchors {
                right: true
                bottom: true
            }

            margins {
                right: frame.gapOuter
                bottom: frame.gapOuter
            }

            Item {
                id: bottomRightCorner
                width: frame.radius
                height: frame.radius

                Canvas {
                    id: bottomRightCanvas
                    anchors.fill: parent
                    antialiasing: true

                    onPaint: {
                        const ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);
                        ctx.fillStyle = frame.surfaceColor;
                        ctx.fillRect(0, 0, width, height);
                        ctx.globalCompositeOperation = "destination-out";
                        ctx.beginPath();
                        ctx.moveTo(0, 0);
                        ctx.arc(0, 0, width, 0, 0.5 * Math.PI, false);
                        ctx.closePath();
                        ctx.fill();
                        ctx.globalCompositeOperation = "source-over";
                    }

                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()
                }
            }
        }

        onSurfaceColorChanged: {
            topLeftCanvas.requestPaint();
            topRightCanvas.requestPaint();
            bottomLeftCanvas.requestPaint();
            bottomRightCanvas.requestPaint();
        }

        PanelWindow {
            screen: frame.modelData
            WlrLayershell.layer: WlrLayer.Top
            exclusionMode: ExclusionMode.Ignore
            focusable: false
            color: Colours.palette.m3surface

            anchors {
                top: true
                right: true
                bottom: true
            }

            implicitWidth: frame.gapOuter
        }

        PanelWindow {
            screen: frame.modelData
            WlrLayershell.layer: WlrLayer.Top
            exclusionMode: ExclusionMode.Ignore
            focusable: false
            color: Colours.palette.m3surface

            anchors {
                left: true
                right: true
                bottom: true
            }

            implicitHeight: frame.gapOuter

            margins {
                left: frame.leftWidth
                right: frame.gapOuter
            }
        }
    }
}
