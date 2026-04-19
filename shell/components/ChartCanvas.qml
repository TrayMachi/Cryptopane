import QtQuick

Canvas {
    id: canvas

    property var closes: []
    property var ema20: []
    property var bbUpper: []
    property var bbMid: []
    property var bbLower: []

    property real leftPadding: 10
    property real rightPadding: 10
    property real topPadding: 12
    property real bottomPadding: 16

    property color gridColor: "#1F94A3B8"
    property color closeColor: "#FF38BDF8"
    property color emaColor: "#FFF59E0B"
    property color upperBandColor: "#FF60A5FA"
    property color midBandColor: "#AAA78BFA"
    property color lowerBandColor: "#FF818CF8"
    property color fillColor: "#1F60A5FA"
    property color markerColor: "#FFBAE6FD"

    contextType: "2d"
    renderStrategy: Canvas.Cooperative

    onClosesChanged: requestPaint()
    onEma20Changed: requestPaint()
    onBbUpperChanged: requestPaint()
    onBbMidChanged: requestPaint()
    onBbLowerChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    function isValuePlottable(value) {
        return value !== null && value !== undefined && !isNaN(value)
    }

    function collectRange(seriesList) {
        var minValue = Infinity
        var maxValue = -Infinity

        for (var seriesIndex = 0; seriesIndex < seriesList.length; seriesIndex++) {
            var series = seriesList[seriesIndex]

            for (var pointIndex = 0; pointIndex < series.length; pointIndex++) {
                var value = series[pointIndex]

                if (!isValuePlottable(value)) {
                    continue
                }

                minValue = Math.min(minValue, value)
                maxValue = Math.max(maxValue, value)
            }
        }

        if (minValue === Infinity || maxValue === -Infinity) {
            return null
        }

        if (minValue === maxValue) {
            minValue -= 1
            maxValue += 1
        }

        var padding = (maxValue - minValue) * 0.12
        return {
            min: minValue - padding,
            max: maxValue + padding
        }
    }

    function plotWidth() {
        return Math.max(1, width - leftPadding - rightPadding)
    }

    function plotHeight() {
        return Math.max(1, height - topPadding - bottomPadding)
    }

    function xForIndex(index, count) {
        if (count <= 1) {
            return leftPadding + plotWidth() / 2
        }

        return leftPadding + (plotWidth() * index) / (count - 1)
    }

    function yForValue(value, range) {
        var normalized = (value - range.min) / (range.max - range.min)
        return height - bottomPadding - (normalized * plotHeight())
    }

    function drawGrid(ctx) {
        ctx.save()
        ctx.strokeStyle = gridColor
        ctx.lineWidth = 1

        for (var row = 0; row < 4; row++) {
            var y = topPadding + (plotHeight() * row) / 3
            ctx.beginPath()
            ctx.moveTo(leftPadding, y)
            ctx.lineTo(width - rightPadding, y)
            ctx.stroke()
        }

        ctx.restore()
    }

    function drawSeries(ctx, series, range, strokeStyle, lineWidth) {
        var started = false
        ctx.save()
        ctx.strokeStyle = strokeStyle
        ctx.lineWidth = lineWidth
        ctx.lineJoin = "round"
        ctx.lineCap = "round"
        ctx.beginPath()

        for (var index = 0; index < series.length; index++) {
            var value = series[index]

            if (!isValuePlottable(value)) {
                started = false
                continue
            }

            var x = xForIndex(index, series.length)
            var y = yForValue(value, range)

            if (!started) {
                ctx.moveTo(x, y)
                started = true
            } else {
                ctx.lineTo(x, y)
            }
        }

        ctx.stroke()
        ctx.restore()
    }

    function drawBandFill(ctx, upper, lower, range) {
        var firstUpper = -1
        var firstLower = -1
        var lastUpper = -1
        var lastLower = -1

        for (var index = 0; index < upper.length; index++) {
            if (isValuePlottable(upper[index])) {
                firstUpper = index
                break
            }
        }

        for (index = 0; index < lower.length; index++) {
            if (isValuePlottable(lower[index])) {
                firstLower = index
                break
            }
        }

        for (index = upper.length - 1; index >= 0; index--) {
            if (isValuePlottable(upper[index])) {
                lastUpper = index
                break
            }
        }

        for (index = lower.length - 1; index >= 0; index--) {
            if (isValuePlottable(lower[index])) {
                lastLower = index
                break
            }
        }

        if (firstUpper === -1 || firstLower === -1 || lastUpper === -1 || lastLower === -1) {
            return
        }

        var startIndex = Math.max(firstUpper, firstLower)
        var endIndex = Math.min(lastUpper, lastLower)

        if (startIndex >= endIndex) {
            return
        }

        ctx.save()
        ctx.fillStyle = fillColor
        ctx.beginPath()

        for (index = startIndex; index <= endIndex; index++) {
            if (!isValuePlottable(upper[index]) || !isValuePlottable(lower[index])) {
                continue
            }

            var upperX = xForIndex(index, upper.length)
            var upperY = yForValue(upper[index], range)

            if (index === startIndex) {
                ctx.moveTo(upperX, upperY)
            } else {
                ctx.lineTo(upperX, upperY)
            }
        }

        for (index = endIndex; index >= startIndex; index--) {
            if (!isValuePlottable(lower[index]) || !isValuePlottable(upper[index])) {
                continue
            }

            ctx.lineTo(xForIndex(index, lower.length), yForValue(lower[index], range))
        }

        ctx.closePath()
        ctx.fill()
        ctx.restore()
    }

    function drawLastMarker(ctx, series, range) {
        for (var index = series.length - 1; index >= 0; index--) {
            if (!isValuePlottable(series[index])) {
                continue
            }

            var x = xForIndex(index, series.length)
            var y = yForValue(series[index], range)

            ctx.save()
            ctx.fillStyle = markerColor
            ctx.beginPath()
            ctx.arc(x, y, 3.5, 0, Math.PI * 2, false)
            ctx.fill()
            ctx.restore()
            return
        }
    }

    onPaint: {
        var ctx = getContext("2d")
        var range = collectRange([closes, ema20, bbUpper, bbMid, bbLower])

        ctx.clearRect(0, 0, width, height)

        if (!range) {
            return
        }

        drawGrid(ctx)
        drawBandFill(ctx, bbUpper, bbLower, range)
        drawSeries(ctx, bbUpper, range, upperBandColor, 1.2)
        drawSeries(ctx, bbMid, range, midBandColor, 1.1)
        drawSeries(ctx, bbLower, range, lowerBandColor, 1.2)
        drawSeries(ctx, ema20, range, emaColor, 2)
        drawSeries(ctx, closes, range, closeColor, 2.6)
        drawLastMarker(ctx, closes, range)
    }
}
