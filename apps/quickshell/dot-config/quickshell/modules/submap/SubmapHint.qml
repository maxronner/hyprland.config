// modules/submap/SubmapHint.qml
// Bottom-center submap keybind hint panel.
// Persistent PanelWindow (show/hide via visible) with slide-up entry animation.
//
// Animation contract:
//   - Enter: content slides from +height to 0 over 350ms (expressiveFast).
//   - Exit:  content slides from 0 to +height over 350ms (expressiveFast).
//   - If a new submap activates during the exit animation, the exit is cancelled
//     and the enter begins from the content's current y-offset (not reset to +height).
//
// Null guard: submapData is a local property updated only just before visible
// becomes true, so content always has valid data when rendered.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import config
import services
import "../../components"

PanelWindow {
    id: root

    // ---- PanelWindow geometry ----
    anchors {
        left: true
        right: true
        bottom: true
    }
    // Height is driven by content; the panel expands upward from bottom.
    // We use a fixed height that is tall enough for any submap, driven by content implicitHeight.
    implicitHeight: card.implicitHeight + bottomMargin

    exclusionMode: ExclusionMode.Normal
    WlrLayershell.layer: WlrLayer.Overlay
    focusable: false

    color: "transparent"

    // ---- Submap definitions ----
    readonly property var submaps: ({
        resize: {
            title: "Resize",
            binds: [
                { key: "H",   icon: "west",         label: "Shrink left"  },
                { key: "J",   icon: "south",         label: "Grow down"    },
                { key: "K",   icon: "north",         label: "Shrink up"    },
                { key: "L",   icon: "east",          label: "Grow right"   },
                { key: "↵",   icon: "check",         label: "Confirm"      },
                { key: "Esc", icon: "close",         label: "Exit"         },
            ]
        },
        system: {
            title: "System",
            binds: [
                { key: "L",   icon: "lock",          label: "Lock"                },
                { key: "E",   icon: "logout",        label: "Exit Hyprland"       },
                { key: "S",   icon: "bedtime",       label: "Suspend"             },
                { key: "R",   icon: "restart_alt",   label: "Reboot"              },
                { key: "⇧S",  icon: "power_settings_new", label: "Shutdown"       },
                { key: "⇧R",  icon: "developer_board", label: "Reboot to firmware"},
                { key: "Esc", icon: "close",         label: "Exit"                },
            ]
        }
    })

    // ---- Visibility state ----
    // visible is driven from shell.qml based on Hypr.activeSubmap.
    // submapData is updated before visible becomes true to avoid null bindings.
    property var submapData: null

    // Track whether we are in the enter or exit phase.
    // true = entering/entered, false = exiting/exited
    property bool entering: false

    onVisibleChanged: {
        if (visible) {
            // Latch current submap data before showing
            const key = Hypr.activeSubmap
            submapData = submaps[key] ?? null
            if (!submapData) console.warn("SubmapHint: no definition for submap '" + key + "'")
            const wasExiting = !entering && slideAnim.running
            entering = true
            slideAnim.stop()
            slideAnim.to = Appearance.padding.xl
            // Mid-exit interruption: continue from current y. Fresh enter: start from bottom.
            const startY = wasExiting ? contentCol.y : (card.implicitHeight + root.bottomMargin)
            // On first open, card.implicitHeight may be 0 — ensure we start offscreen
            slideAnim.from = startY > 0 ? startY : 100
            slideAnim.start()
        } else {
            entering = false
            slideAnim.stop()
            slideAnim.to = card.implicitHeight + bottomMargin
            slideAnim.from = contentCol.y
            slideAnim.start()
        }
    }

    // ---- Layout constants ----
    readonly property int bottomMargin: Appearance.spacing.xl

    // ---- Drop-shadow (elevation level 3) ----
    Rectangle {
        id: shadowRect
        z: -1
        anchors.centerIn: card
        width:  card.implicitWidth  + 12
        height: card.implicitHeight + 12
        radius: Appearance.rounding.md + 6
        color:  "transparent"
        border.color: Qt.alpha(Colours.palette.m3shadow, 0.20)
        border.width: 1
    }

    // ---- Card surface ----
    Rectangle {
        id: card

        // Content-driven width, min 320px, capped at 40% of monitor width
        implicitWidth:  Math.max(320, Math.min(contentCol.implicitWidth  + Appearance.padding.xl * 2,
                                 parent.width * 0.40))
        implicitHeight: contentCol.implicitHeight + Appearance.padding.xl + Appearance.padding.md

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.bottomMargin

        color:  Colours.tPalette.m3surfaceContainer
        // Top corners only — panel hugs the bottom, so bottom corners are hidden
        topLeftRadius:  Appearance.rounding.md
        topRightRadius: Appearance.rounding.md

        Behavior on color { CAnim {} }
        Behavior on implicitWidth {
            NumberAnimation {
                duration: Appearance.anim.duration.expressiveFast
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.expressiveFastSpatial
            }
        }

        // ---- Slide clip ----
        clip: true

        // ---- Content column (slide target) ----
        ColumnLayout {
            id: contentCol

            // y is animated: padding.xl = visible, +height = hidden (slid below card bottom)
            y: card.implicitHeight + root.bottomMargin   // start hidden (overridden by slideAnim)

            anchors.left:  parent.left
            anchors.right: parent.right
            anchors.leftMargin:  Appearance.padding.xl
            anchors.rightMargin: Appearance.padding.xl
            anchors.topMargin:   Appearance.padding.xl

            spacing: Appearance.spacing.xs

            // ---- Title ----
            StyledText {
                text: root.submapData?.title ?? ""
                font.pixelSize: Appearance.font.md
                font.bold: true
                color: Colours.tPalette.m3onSurface
                Layout.bottomMargin: Appearance.spacing.xs
            }

            // ---- Divider ----
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Colours.tPalette.m3outlineVariant
                Layout.bottomMargin: Appearance.spacing.xs
            }

            // ---- Keybind rows ----
            Repeater {
                model: root.submapData?.binds ?? []

                // Each row: m3surfaceContainerLow card
                Rectangle {
                    required property var modelData
                    required property int index

                    Layout.fillWidth: true
                    implicitHeight: rowLayout.implicitHeight + Appearance.padding.sm * 2

                    radius: Appearance.rounding.sm
                    color:  Colours.tPalette.m3surfaceContainerLow

                    Behavior on color { CAnim {} }

                    RowLayout {
                        id: rowLayout
                        anchors {
                            left:   parent.left
                            right:  parent.right
                            top:    parent.top
                            bottom: parent.bottom
                            leftMargin:   Appearance.padding.md
                            rightMargin:  Appearance.padding.md
                            topMargin:    Appearance.padding.sm
                            bottomMargin: Appearance.padding.sm
                        }
                        spacing: Appearance.spacing.sm

                        // Action icon
                        MaterialIcon {
                            icon:  modelData.icon
                            size:  Appearance.font.lg
                            color: Colours.tPalette.m3onSurface
                        }

                        // Label
                        StyledText {
                            text: modelData.label
                            font.pixelSize: Appearance.font.sm
                            color: Colours.tPalette.m3onSurface
                            Layout.fillWidth: true
                        }

                        // Key badge
                        Rectangle {
                            implicitWidth:  keyText.implicitWidth + Appearance.padding.sm * 2
                            implicitHeight: keyText.implicitHeight + Appearance.padding.xs * 2
                            radius: Appearance.rounding.xs

                            // Color by key category:
                            //   action  (h/j/k/l, Enter, ↵) → m3primary tint
                            //   modifier(Shift ⇧, Ctrl)     → m3secondary tint
                            //   exit    (Esc)                → m3error tint
                            readonly property string _k: modelData.key.toLowerCase()
                            readonly property bool _isExit:     _k === "esc"
                            readonly property bool _isMod:      _k.startsWith("⇧") || _k.startsWith("ctrl")
                            readonly property bool _isAction:   ["h","j","k","l","↵","enter"].includes(_k)

                            color: _isExit   ? Qt.alpha(Colours.tPalette.m3error,     0.20)
                                 : _isMod    ? Qt.alpha(Colours.tPalette.m3secondary,  0.20)
                                 : _isAction ? Qt.alpha(Colours.tPalette.m3primary,    0.20)
                                 :             Colours.tPalette.m3surfaceContainerHigh

                            Behavior on color { CAnim {} }

                            StyledText {
                                id: keyText
                                anchors.centerIn: parent
                                text: modelData.key
                                font.pixelSize: Appearance.font.sm
                                font.bold: true
                                color: parent._isExit   ? Colours.palette.m3error
                                     : parent._isMod    ? Colours.palette.m3secondary
                                     : parent._isAction ? Colours.palette.m3primary
                                     :                    Colours.tPalette.m3onSurfaceVariant
                            }
                        }
                    }
                }
            }
        }
    }

    // ---- Slide animation ----
    // Animates contentCol.y. Runs for both enter (to 0) and exit (to +height).
    NumberAnimation {
        id: slideAnim
        target: contentCol
        property: "y"
        duration: Appearance.anim.duration.expressiveFast   // 350 ms
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.anim.expressiveFastSpatial
    }
}
