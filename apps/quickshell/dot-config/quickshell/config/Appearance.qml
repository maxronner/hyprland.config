// config/Appearance.qml
// Design token singleton. Every shell component binds to these properties
// for consistent rounding, spacing, padding, typography, animation, and transparency.
pragma Singleton

import QtQuick
import config

QtObject {
    id: root

    // --- Config access ---
    // Each section reads directly from Config.pending.appearance to avoid
    // cascading re-evaluations through a shared intermediary.
    readonly property var _app: Config.pending.appearance

    // --- Rounding ---
    readonly property QtObject rounding: QtObject {
        readonly property real scale: root._app.rounding?.scale ?? 1.0
        readonly property real xs:   Math.round(8  * scale)
        readonly property real sm:   Math.round(12 * scale)
        readonly property real md:   Math.round(17 * scale)
        readonly property real lg:   Math.round(25 * scale)
        readonly property real xl:   Math.round(38 * scale)
        readonly property real full: 1000
    }

    // --- Spacing ---
    readonly property QtObject spacing: QtObject {
        readonly property real scale: root._app.spacing?.scale ?? 1.0
        readonly property real xs:   Math.round(4  * scale)
        readonly property real sm:   Math.round(7  * scale)
        readonly property real md:   Math.round(12 * scale)
        readonly property real lg:   Math.round(15 * scale)
        readonly property real xl:   Math.round(20 * scale)
    }

    // --- Padding ---
    readonly property QtObject padding: QtObject {
        readonly property real scale: root._app.padding?.scale ?? 1.0
        readonly property real xs:   Math.round(4  * scale)
        readonly property real sm:   Math.round(5  * scale)
        readonly property real md:   Math.round(10 * scale)
        readonly property real lg:   Math.round(12 * scale)
        readonly property real xl:   Math.round(15 * scale)
    }

    // --- Typography ---
    readonly property QtObject font: QtObject {
        readonly property QtObject family: QtObject {
            readonly property string sans:  "Rubik"
            readonly property string mono:  "JetBrainsMono NF"
            readonly property string icons: "Material Symbols Rounded"
        }
        readonly property real scale: root._app.font?.sizeScale ?? 1.0
        readonly property real sm:    Math.round(11 * scale)
        readonly property real md:    Math.round(13 * scale)
        readonly property real lg:    Math.round(15 * scale)
        readonly property real xl:    Math.round(18 * scale)
        readonly property real xxl:   Math.round(28 * scale)
    }

    // --- Animation ---
    readonly property QtObject anim: QtObject {
        id: animObj
        readonly property string preset: root._app.anim?.preset ?? "m3"

        // Cubic-bezier control points [x1, y1, x2, y2] as BezierSpline-compatible arrays.
        // Two presets: "m3" (Material Design 3 expressive curves) and "snappy" (tighter).
        readonly property QtObject curves: QtObject {
            // M3 curves
            readonly property var m3: QtObject {
                readonly property var standard:              [0.2, 0.0, 0.0, 1.0]
                readonly property var standardAccel:         [0.3, 0.0, 1.0, 1.0]
                readonly property var standardDecel:         [0.0, 0.0, 0.0, 1.0]
                readonly property var emphasized:            [0.2, 0.0, 0.0, 1.0]
                readonly property var emphasizedAccel:       [0.3, 0.0, 0.8, 0.15]
                readonly property var emphasizedDecel:       [0.05, 0.7, 0.1, 1.0]
                readonly property var expressiveFastSpatial:    [0.1, 0.9, 0.0, 1.0]
                readonly property var expressiveDefaultSpatial: [0.1, 0.9, 0.0, 1.0]
                readonly property var expressiveSlowSpatial:    [0.1, 0.9, 0.0, 1.0]
            }
            // Snappy curves — shorter ease-ins, snappier feel
            readonly property var snappy: QtObject {
                readonly property var standard:              [0.4, 0.0, 0.2, 1.0]
                readonly property var standardAccel:         [0.4, 0.0, 1.0, 1.0]
                readonly property var standardDecel:         [0.0, 0.0, 0.2, 1.0]
                readonly property var emphasized:            [0.4, 0.0, 0.2, 1.0]
                readonly property var emphasizedAccel:       [0.4, 0.0, 0.9, 0.2]
                readonly property var emphasizedDecel:       [0.1, 0.8, 0.2, 1.0]
                readonly property var expressiveFastSpatial:    [0.2, 0.9, 0.1, 1.0]
                readonly property var expressiveDefaultSpatial: [0.2, 0.9, 0.1, 1.0]
                readonly property var expressiveSlowSpatial:    [0.2, 0.9, 0.1, 1.0]
            }
        }

        // Active curve set, resolved from preset name.
        readonly property var activeCurves: preset === "snappy" ? curves.snappy : curves.m3

        // Convenience aliases for the active preset.
        readonly property var standard:              activeCurves.standard
        readonly property var standardAccel:         activeCurves.standardAccel
        readonly property var standardDecel:         activeCurves.standardDecel
        readonly property var emphasized:            activeCurves.emphasized
        readonly property var emphasizedAccel:       activeCurves.emphasizedAccel
        readonly property var emphasizedDecel:       activeCurves.emphasizedDecel
        readonly property var expressiveFastSpatial:    activeCurves.expressiveFastSpatial
        readonly property var expressiveDefaultSpatial: activeCurves.expressiveDefaultSpatial
        readonly property var expressiveSlowSpatial:    activeCurves.expressiveSlowSpatial

        // Durations (ms) — preset-dependent.
        readonly property QtObject duration: QtObject {
            readonly property bool _snappy: animObj.preset === "snappy"
            readonly property int xs:  _snappy ?  50 : 150
            readonly property int sm:  _snappy ?  75 : 200
            readonly property int md:  _snappy ? 150 : 400
            readonly property int lg:  _snappy ? 200 : 600
            readonly property int xl:  _snappy ? 350 : 1000
            readonly property int expressiveFast:    _snappy ? 100 : 350
            readonly property int expressiveDefault: _snappy ? 150 : 500
            readonly property int expressiveSlow:    _snappy ? 200 : 650
        }
    }

    // --- Transparency ---
    readonly property QtObject transparency: QtObject {
        readonly property bool enabled: root._app.transparency?.enabled ?? false
        readonly property real base:    root._app.transparency?.base    ?? 0.85
    }

    // Ensure Config is initialized before any binding fires.
    Component.onCompleted: Config.ensureInitialized()
}
