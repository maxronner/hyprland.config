// panels/Sparkline.qml
// Canvas sparkline component. Migrated from dashboard/Sparkline.qml.
// Recolored with M3 tokens: lineColor accepts any color, gridColor uses outlineVariant.
pragma ComponentBehavior: Bound
import QtQuick
import config
import services

Canvas {
    id: root

    property var   values:    []
    property real  maxValue:  100
    property color lineColor: Colours.tPalette.m3primary
    property color fillColor: Qt.rgba(lineColor.r, lineColor.g, lineColor.b, 0.15)
    property color gridColor: Colours.tPalette.m3outlineVariant
    property real  lineWidth: 1.5

    onValuesChanged:    requestPaint()
    onWidthChanged:     requestPaint()
    onHeightChanged:    requestPaint()
    onLineColorChanged: requestPaint()
    onGridColorChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)

        // Horizontal grid lines at 25/50/75%
        ctx.save()
        ctx.strokeStyle = gridColor.toString()
        ctx.lineWidth   = 0.5
        for (var i = 0; i < 3; i++) {
            var gy = [0.25, 0.50, 0.75][i] * height
            ctx.beginPath()
            ctx.moveTo(0, gy)
            ctx.lineTo(width, gy)
            ctx.stroke()
        }
        ctx.restore()

        if (values.length < 2) return

        var step = width / (values.length - 1)

        function mapY(v) {
            return height - (Math.min(v, maxValue) / maxValue) * height
        }

        // Filled area
        ctx.save()
        ctx.fillStyle = fillColor.toString()
        ctx.beginPath()
        ctx.moveTo(0, height)
        for (var j = 0; j < values.length; j++)
            ctx.lineTo(j * step, mapY(values[j]))
        ctx.lineTo((values.length - 1) * step, height)
        ctx.closePath()
        ctx.fill()
        ctx.restore()

        // Line
        ctx.save()
        ctx.strokeStyle = lineColor.toString()
        ctx.lineWidth   = root.lineWidth
        ctx.lineJoin    = "round"
        ctx.lineCap     = "round"
        ctx.beginPath()
        ctx.moveTo(0, mapY(values[0]))
        for (var k = 1; k < values.length; k++)
            ctx.lineTo(k * step, mapY(values[k]))
        ctx.stroke()
        ctx.restore()
    }
}
