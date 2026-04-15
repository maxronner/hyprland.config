// Elevation.qml
// M3 elevation shadow using RectangularShadow (QtQuick.Effects).
// Requires Qt 6.8+ (RectangularShadow was added in 6.8).
// Lookup table maps level (0-5) to blur, spread, and y-offset values.
import ".."
import QtQuick
import QtQuick.Effects
import services

RectangularShadow {
    id: root

    property int level: 0

    // Lookup tables for each shadow parameter indexed by level (0-5)
    readonly property var _blurTable:   [0, 4,    8,    14,   18,   24  ]
    readonly property var _spreadTable: [0, 0,   -0.5,  -1.0, -1.2, -1.6]
    readonly property var _yOffTable:   [0, 0.5,  1.5,   3.0,  4.0,  6.0]

    readonly property int _idx: Math.max(0, Math.min(5, level))

    color: Qt.alpha(Colours.palette.m3shadow, 0.7)
    blur: _blurTable[_idx]
    spread: _spreadTable[_idx]
    offset.y: _yOffTable[_idx]

    Behavior on blur {
        Anim {}
    }
    Behavior on spread {
        Anim {}
    }
    Behavior on offset.y {
        Anim {}
    }
}
